## 1.0.1（2026-08-26）
### 新增
- 语速控制：`TtsSpeakerOptions.speechRate`（倍率 0.5~2.0，默认 1.0）、`setSpeechRate()`、`speechMessage` 第二参数单次临时语速（`TSpeechOptions.speechRate`）
- 静音控制：`TtsSpeakerOptions.alwaysPlay`（`true`=静音也出声 / `false`=静音状态跳过播报），iOS / Android / 鸿蒙三端支持

### 修复
- iOS：播报无声问题 —— 播报前激活 `AVAudioSession`；`ambient` 类别在系统静音键下静音，`alwaysPlay=true` 切换 `playback` 类别强制出声
- iOS：`speechMessage` 声明为 `async` 导致闪退（UTS iOS 异步函数基于协程、仅 iOS 13+，且 AVFoundation 需主线程），改回同步方法
- Android：初始化回调在「语言数据丢失 / 不支持该语言」时 `success` 误报为 0，修正为 -1

### 重构
- 鸿蒙：从废弃 API `@ohos.ai.textToSpeech` 重写为 `@kit.CoreSpeechKit`（最低 API 12），语速经 `extraParams.speed` 传入，静音检测使用 `@kit.AudioKit` 的 `getRingerMode`

### 示例
- 示例页新增语速滑杆（0.5x~2.0x）与「静音也出声」开关
## 1.0.0（2026-06-15）
first
