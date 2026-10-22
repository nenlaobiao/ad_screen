# w-tts-speaker

跨平台文本转语音（TTS）UTS 插件，支持 Android / iOS / 鸿蒙平台。

### 快速开始

```uts
import { TtsSpeaker } from '@/uni_modules/w-tts-speaker';

const speaker = new TtsSpeaker({
    language: "ZH",
    callback: (res) => {
        if (res.success === 0) {
            speaker.speechMessage("你好，世界！");
        }
    }
});
```

### 支持的平台

| 平台 | 底层 API |
|------|----------|
| Android | `android.speech.tts.TextToSpeech` |
| iOS | `AVFoundation.AVSpeechSynthesizer` |
| 鸿蒙 | `@ohos.ai.textToSpeech` |

### 开发文档

- [UTS 语法](https://uniapp.dcloud.net.cn/tutorial/syntax-uts.html)
- [UTS API插件](https://uniapp.dcloud.net.cn/plugin/uts-plugin.html)
- [UTS uni-app兼容模式组件](https://uniapp.dcloud.net.cn/plugin/uts-component.html)
- [UTS 标准模式组件](https://doc.dcloud.net.cn/uni-app-x/plugin/uts-vue-component.html)
- [Hello UTS](https://gitcode.net/dcloud/hello-uts)