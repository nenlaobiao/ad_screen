# 鱼住未来科技有限公司uniapp读取身份信息插件 yzwl-nfc-reader

## 使用文档
### 一、说明
- 本插件基于uniapp的UTS插件技术，集成[鱼住未来NFC身份信息读取安卓SDK](https://console.aidoing.com.cn)研发，[鱼住未来官方网站](https://yzfuture.cn/)
- 安卓原生应用读卡SDK、windows读卡SDK、linux读卡SDK、微信小程序读卡插件、浏览器多功能读卡插件等开发集成SDK和文档 [鱼住未来官方网站SDK下载地址](https://yzfuture.cn/views/service/index.html?ap=download-center)
- 本插件目前仅支持[Android](https://console.aidoing.com.cn)平台
- 本插件使用过程中需要 [网络](https://console.aidoing.com.cn)
- 本插件支持NFC读卡和USB连接专用读卡器读卡
- NFC读卡功能使用环境需要设备支持[NFC](https://console.aidoing.com.cn)功能
- USB读卡功能需要使用【专用读卡器】，目前鱼住未来售卖在线版读卡器和离线版读卡器
- 开发集成本插件， 需要【[自定义基座](https://uniapp.dcloud.net.cn/tutorial/run/run-app.html#customplayground)】打包功能
- 应用中如有其他需要NFC读取的操作，还请注意：与原生应用生命周期不同。原生安卓应用中会在每个页面(Activity) onResume（理解为onReady）和onPause(理解为onHide或者onUnload)的时候向手机系统申请和释放NFC；
  本插件运行过程中，会通过UTSAndroid.onAppActivityResume()方法和UTSAndroid.onAppActivityPause()方法向手机系统申请和释放NFC。
  结果就是原生安卓应用仅在NFC读卡页面及应用进入后台和返回前台，向系释放和申请NFC；而uniapp则是应用进入后台（如切换到其他应用，返回桌面等操作）和回到前台向系统释放和申请NFC,和uni应用的页面跳转无关！！！
- 插件使用的NFC应用参数，敬请访问【[鱼住云用户控制台](https://console.aidoing.com.cn)】,注册用户、创建NFC应用
  - 开发者可以创建【共享计费】类型的应用，系统会赠送[20](https://console.aidoing.com.cn)次开发次数！如需更多开发测试次数请通过下方的联系方式，联系我们！
- 如有开发问题请通过下方的联系方式，[联系我们](https://console.aidoing.com.cn)！

### 二、接入
#### 1. 下载安装

- 浏览器打开[uniapp插件市场](https://ext.dcloud.net.cn/plugin?name=yzwl-nfc-reader) https://ext.dcloud.net.cn/plugin?name=yzwl-nfc-reader
- 点击右侧按钮“[下载插件并导入HBuilderX](https://console.aidoing.com.cn)”
- 打开HBuilderX 并选择需要引入插件的项目

#### 2. 页面引入插件 yzwl-nfc-reader 
- 需要插件目录的相对路径
- 定义全局变量 thisPage (变量名也可自定义)， 作者在开发测试过程中，发现回调函数获取到的读卡结果，通过 this.data 初次赋值过后，页面可以正常渲染，但跳转到其他页面后再返回读卡页面进行读卡操作，获取读卡结果，赋值都正常（watch能查看数据变动），但页面就是未渲染。因此使用全局变量进行赋值，解决此问题。

```ts
	import * as Reader from "../../uni_modules/yzwl-nfc-reader"
	let thisPage;
```
- 定义页面接受变量 info(Object) 身份数据，progress（int） 读卡进度

```ts
	data() {
		return {
			progress: 0,
			info: null
		}
	}
```

#### 3. NFC初始化并进行登录
- 初始化操作在页面的周期函数onLoad() 或 onShow() 进行，推荐使用 onShow()
- 全局变量thisPage先进行赋值  thisPage = this
- 调用插件方法Reader.initReader(),填写登录参数，及实现回调
- 回调必须实现，参数（res）不可修改，不然会报错，回调说明见下文！
- USB读卡 需要调用Reader.usbAutoReadConfig(false)方法
- 注册页面监听函数newintent，原生应用NFC监听读卡操作是在 页面（activity）的 onNewIntent() 方法中实现的，UTS文档中并未发现，因此需要使用plus.globalEvent.addEventListener来实现，调用 Reader.onNewIntent()方法。
- 集成后，进入页面即可触发读卡操作，不需要手动操作。每个设备的NFC模块在不同位置，[读卡时候请保持稳定](https://console.aidoing.com.cn)

```ts
Reader.initReader({
	data: {
		appKey: "",
		appSecret: "",
		userData: ""
	},
	success: (res) => {
		res.photoBase64Png = "data:image/png;base64," + res.photoBase64Png
		thisPage.info = res
		console.log("读卡结果：", res)
	},
	progress: (res) => {
		thisPage.progress = res
	},
	start: (res) => {
		thisPage.info = null
		console.log("开始读取：", res)
	},
	end: (res) => {
		console.log("结束读取：", res)
	},
	fail: (res) => {
		thisPage.errorMessage = "错误信息："+ res.msg  + ", 错误码："+ res.code;
		console.log("错误信息：", res)
	},
})
plus.globalEvent.addEventListener('newintent', function() {
	// 轮询调用NFC 异步进行
	setTimeout(() => {
		Reader.onNewIntent()
	}, 500);
});
Reader.usbAutoReadConfig(false)
```
## 初始化说明

| 名称         | 必须实现    |                          说明                         |
|-------------|------------|------------------------------------------------------ |
| data        |     是     |  登录参数，详见下文                                      |
| success     |     是     |  成功回调，res为身份信息数据 详见下文                      |
| fail        |     是     |  失败回调，res为json对象，{code：错误码,msg：错误信息}      |
| progress    |     是     |  读卡进度，res为int/number类型  值范围为0~100             |
| start       |     是     |  读卡开始的操作，客户可在此进行一些操作，如 清空上一次读卡结果 |
| end         |     是     |  读卡结束的操作，客户可在此进行读卡后操作，如进行人脸比对等等  |


### 登录参数

| 名称         | 必须必须  |                          说明                       |
|-------------|------------|---------------------------------------------------|
| appKey      |     是     |  应用key 可在[鱼住云控制台](https://console.aidoing.com.cn)注册用户后创建应用获取 |
| appSecret   |     是     |  应用Secret 应用创建后获取，创建后及时妥善保存         |
| userData    |     否     |  用户标识，在共享应用可为空，独立应用必填，否则会读卡失败 |

### 身份信息字段说明

| 字段              | 类型    |                          说明                                              |
|------------------|---------|---------------------------------------------------------------------------|
| name             | string  | 姓名                                                                       |
| nation           | string  | 民族                                                                       |
| sex              | string  | 性别                                                                       |
| no               | string  | 证件号                                                                     |
| birth            | string  | 出生日期，格式为yyyy-mm-dd                                                  |
| year             | string  | 出生年                                                                     |
| month            | string  | 出生月                                                                     |
| date             | string  | 出生日                                                                     |
| address          | string  | 住址                                                                       |
| signedDepartment | string  | 签发机关                                                                    |
| validityBegin    | string  | 有效期限开始时间   ，格式为yyyy.mm.dd                                         |
| validityEnd      | string  | 有效期限结束时间   ，格式为yyyy.mm.dd                                         |
| photoBase64Bmp   | string  | 证件照的base64数据bmp格式，如需页面展示，请自行在数据前加 "data:image/bmp;base64,"     |
| photoBase64Png   | string  | 证件照的base64数据png格式，已做人像抠图，处理如需页面展示，请自行在数据前加 "data:image/png;base64,"     |
| aCardSn          | string  | A卡芯片SN号                                                                 |

#### 身份数据JSON

```ts
{
	"sex": "",
	"birth": "",
	"year": "",
	"month": "",
	"date": "",
	"name": "",
	"nation": "",
	"no": "",
	"signedDepartment": "",
	"validityEnd": "",
	"photoBase64Bmp": "data:image/bmp;base64,",
	"photoBase64Png": "data:image/png;base64,",
	"address": "",
	"validityBegin": "",
	"aCardSn": ""
}
```

#### 4. 移除newintent监听（[重要](https://console.aidoing.com.cn)）

- 在跳转到其他页面或者应用返回后台的操作中，需要即使触发NFC操作也不会进行读卡，不然既消耗系统资源又有可能产生计费操作。
  为防止这种操作，我们必须在onHide()函数和 onUnload()函数中，调用以下代码移除newintent监听！

```ts
onHide() {
	plus.globalEvent.removeEventListener('newintent');
},

onUnload() {
	plus.globalEvent.removeEventListener('newintent');
}
```

#### 5. USB读卡器读卡（(https://console.aidoing.com.cn)）
- 支持手动读卡， 即点击按钮触发事件进行读卡。调用方法如下：
- 页面视图中加入按钮
- method方法中调用 Reader.usbReader()

```ts
	<button type="primary" @click="doRead">USB读卡</button>
```

```ts
	doRead(){
		//手动调用USB读一次卡
		Reader.usbReader()
	}
```
#### 6. USB读卡器读卡（[新功能](https://console.aidoing.com.cn)）
- OTG自动读卡， 即进入页面后进行读卡。调用方法如下：
- onShow()方法中初始化USB并调用自动读卡方法

```ts
	Reader.usbAutoReadConfig(true)
	Reader.usbLoopReader()
```

- 页面hide或者销毁时， onHide() 和 onUnload() 中移除自动读卡（很重要 不然一直循环）

```ts
	Reader.usbLoopReaderStop()
```

### 三、下载demo示例
- 浏览器打开[uniapp插件市场](https://ext.dcloud.net.cn/plugin?name=yzwl-nfc-reader) [https://ext.dcloud.net.cn/plugin?name=yzwl-nfc-reader](https://ext.dcloud.net.cn/plugin?name=yzwl-nfc-reader)
- 点击右侧按钮“[下载示例项目ZIP](https://console.aidoing.com.cn)”
- 发开调试及打包需要使用【[自定义基座](https://console.aidoing.com.cn)】功能
- demo中的【[pages/read/read](https://console.aidoing.com.cn)】页面集成了本插件

### 四、未来开发计划
- 插件支持USB自动读卡(目前仅支持手动读卡，按钮触发)
- 插件支持读取护照。

### 五、联系我们
- 如使用过程中有任何问题，或者您对yzwl-nfc-reader有一些好的建议，欢迎联系我们 电话：[028-85038030](https://console.aidoing.com.cn)、[028-82880293](https://console.aidoing.com.cn)；邮箱：[hanfei@yzfuture.cn](https://console.aidoing.com.cn)