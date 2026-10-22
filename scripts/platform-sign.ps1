<#
.SYNOPSIS
  用设备平台签名重新签名 HBuilderX 打出的 APK，让 App 获得平台签名权限（静默安装、重启、截屏）。

.DESCRIPTION
  默认流程：zipalign 对齐 → apksigner 平台签名 → 验证（证书 SHA-1、清单里声明的平台权限）
  App 仍以自己的身份运行，只是签名和系统一致，系统会授予 INSTALL_PACKAGES / REBOOT / READ_FRAME_BUFFER 等
  signature 级权限（需在项目 AndroidManifest.xml 里声明）。

  -SystemUid：额外用 apktool 在清单根标签加 sharedUserId="android.uid.system"（HBuilderX 合并清单会丢掉根标签属性）。
  注意 uni-app x 启动时会用到 WebView，系统身份进程禁止使用 WebView，加了会启动即崩溃，默认不要用。

  签名文件放在 scripts/keys/（已加入 .gitignore，不会提交）；私钥只在本机使用，不要上传云打包。

.EXAMPLE
  # 自定义调试基座：直接覆盖原文件，HBuilderX 用自定义基座运行时装的就是它
  .\scripts\platform-sign.ps1 -Apk .\unpackage\debug\android_debug.apk -InPlace

.EXAMPLE
  # 正式包：输出到同目录的 xxx-platform.apk
  .\scripts\platform-sign.ps1 -Apk D:\下载\xxx.apk
#>
param(
	[Parameter(Mandatory = $true)][string]$Apk,
	# 输出路径，默认输入文件同目录的 <文件名>-platform.apk
	[string]$Out = '',
	# 处理完成后覆盖输入文件（自定义基座用）
	[switch]$InPlace,
	# 额外加 sharedUserId="android.uid.system"（uni-app x 会因 WebView 限制崩溃，默认不用）
	[switch]$SystemUid,
	# 期望的包名，打包时没改包名会给出警告
	[string]$Package = 'ming.adscreen',
	# 平台签名文件所在目录（platform.pk8 / platform.x509.pem），默认是脚本旁边的 keys 目录（已加入 .gitignore）
	[string]$KeyDir = '',
	[string]$Apktool = 'D:\tools\apktool\apktool_3.0.3.jar',
	[string]$BuildTools = 'E:\AndroidStudio\Android\SDK\build-tools\34.0.0',
	[string]$Java = 'E:\AndroidStudio\Amazon Corretto\jdk17.0.20_12\bin\java.exe'
)

# 设备 framework-res.apk 的平台证书 SHA-1，签名后必须一致
$ExpectedSha1 = '41791c9b8faf15e1acd5aaf59210fd42467d8277'
# 项目 AndroidManifest.xml 里声明的平台签名权限，打出的包里应该都有
$PlatformPermissions = @(
	'android.permission.INSTALL_PACKAGES',
	'android.permission.REBOOT',
	'android.permission.READ_FRAME_BUFFER',
	'android.permission.START_ACTIVITIES_FROM_BACKGROUND'
)

function Fail([string]$message) {
	Write-Host "失败：$message" -ForegroundColor Red
	exit 1
}
function Check-Exit([string]$step) {
	if ($LASTEXITCODE -ne 0) { Fail "$step（退出码 $LASTEXITCODE）" }
}

# ---------- 检查输入 ----------
# PowerShell 5.1 在参数默认值里拿不到 $PSScriptRoot，放到这里再算
if ($KeyDir -eq '') { $KeyDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'keys' }
if (-not (Test-Path $Apk)) { Fail "找不到 APK：$Apk" }
$Apk = (Resolve-Path $Apk).Path
$key = Join-Path $KeyDir 'platform.pk8'
$cert = Join-Path $KeyDir 'platform.x509.pem'
foreach ($file in @($key, $cert)) {
	if (-not (Test-Path $file)) { Fail "找不到文件：$file" }
}
if ($SystemUid -and -not (Test-Path $Apktool)) { Fail "找不到 apktool：$Apktool" }
if (-not (Test-Path $Java)) { $Java = 'java' }
$zipalign = Join-Path $BuildTools 'zipalign.exe'
$aapt2 = Join-Path $BuildTools 'aapt2.exe'
$apksigner = Join-Path $BuildTools 'lib\apksigner.jar'
foreach ($file in @($zipalign, $aapt2, $apksigner)) {
	if (-not (Test-Path $file)) { Fail "找不到 build-tools 文件：$file" }
}
if ($Out -eq '') {
	$Out = Join-Path (Split-Path $Apk) ([IO.Path]::GetFileNameWithoutExtension($Apk) + '-platform.apk')
}

$work = Join-Path $env:TEMP ('platform-sign-' + (Get-Date -Format 'yyyyMMddHHmmss'))
New-Item -ItemType Directory -Force $work | Out-Null
$aligned = Join-Path $work 'aligned.apk'
$signed = Join-Path $work 'signed.apk'
Write-Host "输入：$Apk"
Write-Host "临时目录：$work"

# ---------- 可选：加 sharedUserId ----------
$toAlign = $Apk
if ($SystemUid) {
	Write-Host "`n[可选] apktool 加 sharedUserId=android.uid.system" -ForegroundColor Cyan
	$srcDir = Join-Path $work 'src'
	$unsigned = Join-Path $work 'unsigned.apk'
	& $Java -jar $Apktool d --no-src -f -o $srcDir $Apk
	Check-Exit 'apktool 解包'
	$manifestPath = Join-Path $srcDir 'AndroidManifest.xml'
	$manifest = [IO.File]::ReadAllText($manifestPath)
	if ($manifest -notmatch 'android:sharedUserId=') {
		$regex = New-Object Text.RegularExpressions.Regex '<manifest\s'
		$manifest = $regex.Replace($manifest, '<manifest android:sharedUserId="android.uid.system" ', 1)
		# 不带 BOM 的 UTF-8，避免 aapt2 解析出错
		[IO.File]::WriteAllText($manifestPath, $manifest, (New-Object Text.UTF8Encoding $false))
	}
	& $Java -jar $Apktool b $srcDir -o $unsigned
	Check-Exit 'apktool 打包'
	Remove-Item $srcDir -Recurse -Force
	$toAlign = $unsigned
}

# ---------- 1. 对齐 ----------
Write-Host "`n[1/3] zipalign 对齐" -ForegroundColor Cyan
& $zipalign -p -f 4 $toAlign $aligned
Check-Exit 'zipalign'

# ---------- 2. 平台签名 ----------
Write-Host "`n[2/3] apksigner 平台签名" -ForegroundColor Cyan
& $Java -jar $apksigner sign --key $key --cert $cert --out $signed $aligned
Check-Exit 'apksigner 签名'

# ---------- 3. 验证 ----------
Write-Host "`n[3/3] 验证" -ForegroundColor Cyan
$certs = & $Java -jar $apksigner verify --print-certs $signed
Check-Exit 'apksigner 验证'
$sha1Line = $certs | Where-Object { $_ -match 'SHA-1 digest' } | Select-Object -First 1
Write-Host $sha1Line
if ($sha1Line -notmatch $ExpectedSha1) { Fail "签名证书和设备平台证书不一致，期望 SHA-1：$ExpectedSha1" }

$packageName = (& $aapt2 dump packagename $signed | Select-Object -First 1)
if ($packageName -ne $null) { $packageName = $packageName.Trim() }
if ($packageName -eq $Package) {
	Write-Host "包名：$packageName"
} else {
	Write-Host "警告：包名是 $packageName，不是 $Package（请在 HBuilderX 打包 / 制作自定义基座时把 Android 包名改成 $Package）" -ForegroundColor Yellow
}

$manifestDump = & $aapt2 dump xmltree $signed --file AndroidManifest.xml
foreach ($permission in $PlatformPermissions) {
	if (($manifestDump | Where-Object { $_ -match [regex]::Escape($permission) }) -eq $null) {
		Write-Host "警告：清单里没有声明 $permission（项目 AndroidManifest.xml 改了之后要重新打包 / 制作基座）" -ForegroundColor Yellow
	} else {
		Write-Host "已声明：$permission"
	}
}
$shared = $manifestDump | Where-Object { $_ -match 'sharedUserId' }
if ($shared -ne $null) {
	Write-Host "注意：清单里有 sharedUserId，uni-app x 会因 WebView 限制启动崩溃" -ForegroundColor Yellow
}

# ---------- 输出 ----------
if ($InPlace) {
	$backup = Join-Path $work 'original.apk'
	Copy-Item $Apk $backup -Force
	Copy-Item $signed $Apk -Force
	Write-Host "`n完成：已覆盖 $Apk（原文件备份在 $backup）" -ForegroundColor Green
} else {
	Copy-Item $signed $Out -Force
	Write-Host "`n完成：$Out" -ForegroundColor Green
}
