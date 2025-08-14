# netease-pull-stream
### 开发文档
[UTS 语法](https://uniapp.dcloud.net.cn/tutorial/syntax-uts.html)
[UTS API插件](https://uniapp.dcloud.net.cn/plugin/uts-plugin.html)
[UTS 组件插件](https://uniapp.dcloud.net.cn/plugin/uts-component.html)
[Hello UTS](https://gitcode.net/dcloud/hello-uts)


```
Android demo code
vue
<template>
	<view class="content">
	    <nrtc-pull-view id="video" ref="video" class="video" :url="url">
	    </nrtc-pull-view>
		<view>
			<view class="input-wrapper">
			  <textarea id="uni-input-default" class="uni-input" name="url" :value="url"  type="text" placeholder="请设置播放云信拉流URL" @input="urlChange" />
			</view>
		</view>
		<button class="button" @click="play" type="primary">播放</button>
	    <text class="tiptitle">注意：</text>
	    <view class="tips">
	      <text class="tip">uts组件插件nrtc-pull-view需要使用自定义基座才能生效！</text>
	      <text class="tip">暂时仅支持uni-app x项目！</text>
	      <text class="tip">暂时仅支持Android平台！</text>
	    </view>
	</view>
</template>

<style scoped>
  .text {
      font-size: 15px;
      color: #353535;
      line-height: 27px;
      text-align: center;
    }
	
  .input-wrapper {
    display: flex;
    padding: 8px 13px;
    margin: 5px 0;
    flex-direction: row;
    flex-wrap: nowrap;
    background-color: #ffffff;
  }

  .uni-input {
    height: 90px;
    font-size: 15px;
    padding: 0px;
    flex: 1;
    background-color: #ffffff;
  }

  .uni-icon {
    width: 24px;
    height: 24px;
  }

  .uni-input-placeholder-class {
    font-size: 10px;
  }
</style>

<script>
	//import { VideoViewElement } from "uts.sdk.modules.uniVideo"
	 /**
	   * VideoViewElement 是uts组件对象类型名称
	   * 命名规则：组件名称以upper camel case方式命名 + Element，如这里的组件名称为 video-view，对应的uts组件对象类型名称为VideoViewElement
	   */
	  //Todo: 临时解决方案，新版本将无需import
	  //nrtc-pull-view
<!-- #ifdef APP-ANDROID -->
	import { NrtcPullViewElement } from "uts.sdk.modules.neteasePullStream"
<!-- #endif -->
	export default {
		data() {
			return {
				url: 'https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/default/%E7%BD%91%E6%98%93%E4%BA%91%E4%BF%A1%E7%94%B5%E8%A7%86%E5%A4%A7%E5%B1%8F%E6%96%B9%E6%A1%88%E5%AE%A3%E4%BC%A0%E7%89%871214.mp4'
			};
		},
		onLoad() {
		},
		
		onShow() {
			(uni.getElementById('video') as NrtcPullViewElement).appOnShow();
		},
		
		onHide() {
			(uni.getElementById('video') as NrtcPullViewElement).appOnHide();
		},
		
		methods: {		
			urlChange: function(event: UniInputEvent) {
				this.url = event.detail.value
			},
			
			play() {
				(uni.getElementById('video') as NrtcPullViewElement).play(this.url);
			}
		}
	}
</script>

<style>
	.content {
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.logo {
		height: 200rpx;
		width: 200rpx;
		margin-top: 200rpx;
		margin-bottom: 50rpx;
	}

	.title {
		font-size: 36rpx;
		color: #8f8f94;
	}
	
	.video {
	    width: 800rpx;
		height: 450rpx;
	}
	  
	.button {
	    width: 640rpx;
	    margin: 10px;
	}
	
	.tips {
	    justify-content: flex-start;
	    margin: 0px 20px;
	}
	
	.tip {
	    color: darkred;
	}
</style>

```
