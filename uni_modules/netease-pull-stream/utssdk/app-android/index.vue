<template>
  <view>
  </view>
</template>

<script lang="uts">
  /**
   * 引用 Android 系统库
   * [可选实现，按需引入]
   */
  import UTSContainer from "io.dcloud.uts.component.UTSContainer";
  import UTSAndroid from 'io.dcloud.uts.UTSAndroid';
  import Surface from 'android.view.Surface';
  import SurfaceView from 'android.view.SurfaceView';
  import Activity from 'android.app.Activity';
  import View from 'android.view.View';
  import Context from 'android.content.Context'
  import LinearLayout from 'android.widget.LinearLayout'
  import MeasureSpec from 'android.view.View.MeasureSpec';
  import ViewGroup from 'android.view.ViewGroup';
  import FrameLayout from 'android.widget.FrameLayout';
  import NELivePlayer from "com.netease.neliveplayer.sdk.NELivePlayer";
  import OnPreparedListener from "com.netease.neliveplayer.sdk.NELivePlayer";
  import OnCompletionListener from "com.netease.neliveplayer.sdk.NELivePlayer";
  import OnBufferingUpdateListener from "com.netease.neliveplayer.sdk.NELivePlayer";
  import OnInfoListener from "com.netease.neliveplayer.sdk.NELivePlayer";
  import OnErrorListener from "com.netease.neliveplayer.sdk.NELivePlayer";
  import OnHttpResponseInfoListener from "com.netease.neliveplayer.sdk.NELivePlayer";
  import NESDKConfig from "com.netease.neliveplayer.sdk.model.NESDKConfig";
  /**
   * 引入三方库
   * [可选实现，按需引入]
   *
   * 在 Android 平台引入三方库有以下两种方式：
   * 1、[推荐] 通过 仓储 方式引入，将 三方库的依赖信息 配置到 config.json 文件下的 dependencies 字段下。详细配置方式[详见](https://uniapp.dcloud.net.cn/plugin/uts-plugin.html#dependencies)
   * 2、直接引入，将 三方库的aar或jar文件 放到libs目录下。更多信息[详见](https://uniapp.dcloud.net.cn/plugin/uts-plugin.html#android%E5%B9%B3%E5%8F%B0%E5%8E%9F%E7%94%9F%E9%85%8D%E7%BD%AE)
   *
   * 在通过上述任意方式依赖三方库后，使用时需要在文件中 import
   * import { LottieAnimationView } from 'com.airbnb.lottie.LottieAnimationView'
   */

  /**
   * UTSAndroid 为平台内置对象，不需要 import 可直接调用其API，[详见](https://uniapp.dcloud.net.cn/uts/utsandroid.html#utsandroid)
   */

  //原生提供以下属性或方法的实现
  const tag: String = '[nrtc-pull-view] '
  export default {
    /**
     * 组件名称，也就是开发者使用的标签
     */
    name: "nrtc-pull-view",
    /**
     * 组件涉及的事件声明，只有声明过的事件，才能被正常发送
     */
	
    emits: ['play', 'appOnShow', 'appOnHide'],
    /**
     * 属性声明，组件的使用者会传递这些属性值到组件
     */
    props: {
      "url": {
        type: String,
        default: ""
      }
    },
    /**
     * 组件内部变量声明
     */
    data() {
      return {
		  rootView: null as FrameLayout | null,
		  livePlayer: null as NELivePlayer | null,
		  surfaceView : null as SurfaceView | null,
		  streamingURL_ : null as String | null,
		  hasInited : false,
		  hasStarted: false,
		  //contentLayout: null as CustomLinearLayout | null,
	  }
    },
    /**
     * 属性变化监听器实现
     */
    watch: {
    },
    /**
     * 规则：如果没有配置expose，则methods中的方法均对外暴露，如果配置了expose，则以expose的配置为准向外暴露
     * ['publicMethod'] 含义为：只有 `publicMethod` 在实例上可用
     */
    expose: ['play', 'appOnShow', 'appOnHide'],
    methods: {
      /**
       * 对外公开的组件方法
       *
       * uni-app中调用示例：
       * this.$refs["组件ref"].doSomething("uts-button");
       *
       * uni-app x中调用示例：
       * 1、引入对应Element
       * import { UtsButtonElement(组件名称以upper camel case方式命名 + Element) } from 'uts.sdk.modules.utsComponent(组件目录名称以lower camel case方式命名)';
       * 2、(this.$refs["组件ref"] as UtsButtonElement).doSomething("uts-button");
       * 或 (uni.getElementById("组件id") as UtsButtonElement).doSomething("uts-button");
       */
	  
		appOnShow: function () {
			console.log(tag + 'App Show')
			this.recoverPlayer()
		},
		
		appOnHide: function () {
			console.log(tag + 'App Hide')
			this.resetPlayer()
		},
	  
		play: function(url: string) {
			console.log(tag + 'play url:' + url)
			this.streamingURL_ = url
			this.onPlay()
		},
	  
		/**
		* 内部函数
		 * runnable切换到UI线程执行
		 */
		runOnUiThread: function (runnable : () => void) {
			(this.$androidContext as Activity).runOnUiThread(new MainRunnable(runnable));
		},
		
		reloadStreamingURL: function() {
			console.log(tag + 'reloadStreamingURL')
			this.livePlayer?.stop()
			this.livePlayer?.reset()
			this.livePlayer?.setDataSource(this.streamingURL_);
			this.livePlayer?.prepareAsync()
			this.livePlayer?.start()
		} ,
		
		initSDKInternal: function() {
			let config = new NESDKConfig();
			NELivePlayer.init(this.$androidContext, config);
			this.livePlayer = NELivePlayer.create();
			this.livePlayer?.setDisplay(this.surfaceView?.getHolder())
			let listen = new OnLivePlayerListenerImpl(this.surfaceView!, this.rootView!, this.livePlayer!)
			this.livePlayer?.setOnPreparedListener(listen)
			this.livePlayer?.setOnCompletionListener(listen)
			this.livePlayer?.setOnBufferingUpdateListener(listen)
			this.livePlayer?.setOnInfoListener(listen)
			this.livePlayer?.setOnErrorListener(listen)
			this.livePlayer?.setOnHttpResponseInfoListener(listen)
			this.livePlayer?.setOnVideoSizeChangedListener(listen)
			this.livePlayer?.setDataSource(this.streamingURL_);
			this.livePlayer?.prepareAsync()
			this.hasInited = true
			console.log(tag + 'initSDKInternal rootView:' + this.rootView + ' surfaceView:' + this.surfaceView)
		},
		
		releaseInternal: function() {
			this.livePlayer?.stop()
			this.livePlayer?.release()
			this.livePlayer = null
			this.hasStarted = false
			this.hasInited = false
			console.log(tag + 'releaseInternal livePlayer stop and release')
		},
		
		resetPlayer: function() {
			console.log(tag + 'resetPlayer')
			if (this.livePlayer?.isPlaying() == true) {
				this.livePlayer?.pause()
			} 
			this.livePlayer?.reset()
		},
		
		recoverPlayer: function() {
			console.log(tag + 'recoverPlayer this.hasStarted:' + this.hasStarted)
			if(this.hasStarted == true)  {
				setTimeout(function() {
					this.onPlay()
				}, 10);
			}
		},
		
		onPlay: function() {
			console.log(tag + 'onPlay streamingURL:' + this.streamingURL_ + ' hasInited: ' + this.hasInited)
			if(this.streamingURL_.isNullOrEmpty()) {
				console.error(tag + 'streaming url is null')
				return
			}
			
			if (this.hasInited) {
				this.releaseInternal()
			}
			
			this.initSDKInternal()
			this.livePlayer?.start()
			console.log(tag + 'onPlay livePlayer start')
			this.hasStarted = true
		},
    },
	
    /**
     * [可选实现] 组件被创建，组件第一个生命周期，
     * 在内存中被占用的时候被调用，开发者可以在这里执行一些需要提前执行的初始化逻辑
     */
    created() {
		console.log(tag + 'created')
    },
    /**
     * [可选实现] 对应平台的view载体即将被创建，对应前端beforeMount
     */
    NVBeforeLoad() {
		console.log(tag + 'NVBeforeLoad')
    },
    /**
     * [必须实现] 创建原生View，必须定义返回值类型
     * 开发者需要重点实现这个函数，声明原生组件被创建出来的过程，以及最终生成的原生组件类型
     * （Android需要明确知道View类型，需特殊校验）
     */
    NVLoad() : FrameLayout {
		this.rootView = new FrameLayout(this.$androidContext!)
		this.surfaceView = new SurfaceView(this.$androidContext!)
		this.rootView?.addView(this.surfaceView, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
		//this.rootView?.addView(this.surfaceView, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
		return this.rootView!;
    },
    /**
     * [可选实现] 原生View已创建
     */
    NVLoaded() {
		console.log(tag + 'NVLoaded rootView:' + this.rootView + ' surfaceView:' + this.surfaceView)
    },
    /**
     * [可选实现] 原生View布局完成
     */
    NVLayouted() {
		//
		console.log(tag + 'NVLayouted')
    },
    /**
     * [可选实现] 原生View将释放
     */
    NVBeforeUnload() {
		console.log(tag + 'NVBeforeUnload')
    },
    /**
     * [可选实现] 原生View已释放，这里可以做释放View之后的操作
     */
    NVUnloaded() {
		console.log(tag + 'NVUnloaded')
    },
    /**
     * [可选实现] 组件销毁
     */
    unmounted() {
		console.log(tag + 'unmounted')
		this.releaseInternal()
    },
    /**
     * [可选实现] 自定组件布局尺寸，用于告诉排版系统，组件自身需要的宽高
     * 一般情况下，组件的宽高应该是由终端系统的排版引擎决定，组件开发者不需要实现此函数
     * 但是部分场景下，组件开发者需要自己维护宽高，则需要开发者重写此函数
     */
    NVMeasure(size : UTSSize) : UTSSize {
      // size.width = 300.0.toFloat();
      // size.height = 200.0.toFloat();
      return size;
    }
  }
  
  /**
  	 * 切换到主线程
  	 */
  	class MainRunnable implements Runnable {
  
  		private runnable : (() => void) | null;
  
  		constructor(runnable : (() => void) | null) {
  			this.runnable = runnable;
  		}
  
  		override run() : void {
  			this.runnable?.invoke();
  		}
  	}
	
	class OnLivePlayerListenerImpl implements NELivePlayer.OnPreparedListener , NELivePlayer.OnCompletionListener , NELivePlayer.OnBufferingUpdateListener, NELivePlayer.OnInfoListener, NELivePlayer.OnErrorListener, NELivePlayer.OnHttpResponseInfoListener, NELivePlayer.OnVideoSizeChangedListener  {
		private surfaceView : SurfaceView;
		private rootView: FrameLayout;
		private livePlayer: NELivePlayer;
		private tag: String = tag + '[LivePlayerListener] '		
		constructor(surfaceView : SurfaceView, rootView : FrameLayout, livePlayer : NELivePlayer) {
			super();
			this.surfaceView = surfaceView;
			this.rootView = rootView;
			this.livePlayer = livePlayer;
		}
		
		override onPrepared(p0: NELivePlayer) : Unit {
			console.log(this.tag + 'onPrepared:')
		}
		
		override onCompletion(p0: NELivePlayer) : Unit {
			console.log(this.tag + 'onCompletion:')
		}
		
		override onBufferingUpdate(p0: NELivePlayer, param1Int: Int) : Unit {
			console.log(this.tag + 'onBufferingUpdate:')
		}
		
		override onInfo(p0: NELivePlayer, p1: Int, p2: Int): Boolean {
			console.log(this.tag + 'onInfo:')
			return true
		}
		
		override onError(p0: NELivePlayer, p1: Int, p2: Int): Boolean {
			console.log(this.tag + 'onError:')
			return true
		}
		
		override onHttpResponseInfo(param1Int: Int, param2: string) : Unit {
			console.log(this.tag + 'onHttpResponseInfo:')
		}
		
		override onVideoSizeChanged(mp: NELivePlayer, width: Int , height:Int,
		                                sar_num: Int , sar_den: Int ): Unit {
			console.log(this.tag + 'onVideoSizeChanged width:' + width + ', height:' + height)
			let _params: ViewGroup.LayoutParams | null = this.surfaceView.getLayoutParams();
			if (_params != null) {
				let rootParams: ViewGroup.LayoutParams = this.rootView.getLayoutParams();
				let params: FrameLayout.LayoutParams  = new FrameLayout.LayoutParams(0, 0);
				let rootViewWidth = rootParams.width
				let rootViewHeight = rootParams.height
				console.log(this.tag + 'onVideoSizeChanged rootViewWidth:' + rootViewWidth + ' rootViewHeight:' + rootViewHeight)
				params.width = rootViewHeight * width / height
				params.height = rootViewHeight
				params.leftMargin = (rootViewWidth - params.width)/2
				params.topMargin = (rootViewHeight - params.height)/2
				this.surfaceView.setLayoutParams(params);
			}
		}
	}
</script>

<style>

</style>