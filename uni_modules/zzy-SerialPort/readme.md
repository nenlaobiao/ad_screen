# zzy-SerialPort
### 开发文档
[UTS 语法](https://uniapp.dcloud.net.cn/tutorial/syntax-uts.html)
[UTS API插件](https://uniapp.dcloud.net.cn/plugin/uts-plugin.html)
[UTS 组件插件](https://uniapp.dcloud.net.cn/plugin/uts-component.html)
[Hello UTS](https://gitcode.net/dcloud/hello-uts)


##引入模块
``` 
  import { serialPort } from "@/uni_modules/zzy-SerialPort"
``` 
##使用
``` 
  const mySerialPort=new serialPort()
  mySerialPort.setPath("/dev/ttyS4")//设置串口
  mySerialPort.setBaudRate(9600)//设置波特率 
  mySerialPort.setStopBits(number)//设置停止位
  mySerialPort.setParity(number)//设置校验位
  mySerialPort.setFlowCon(number)//设置流控
  mySerialPort.setFlags(number)//设置标志
  mySerialPort.open((res) => {	//打开串口
		console.log(res);
	})
  mySerialPort.setListenerHex(	//设置监听16进制
		(send) => {
			console.log(send); //发送的消息
		}, (received) => {
			console.log(received);//收到的消息
		})
  mySerialPort.close()	//关闭串口
  mySerialPort.isOpen() //串口状态
  mySerialPort.sendHex("11 12 13")//发送16进制
  mySerialPort.getAllDeviceList()//获取所有串口
  mySerialPort.getAllDevicePath()//获取所有路径
 ```
 
 如有错误，欢迎指正！