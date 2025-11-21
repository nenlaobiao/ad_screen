# usb-serial

>插件说明

####  本插件参考于[usb-serial-for-android](https://github.com/mik3y/usb-serial-for-android)项目

usb转串口支持如下USB转串口转换芯片：
+ FTDI FT232R, FT232H, FT2232H, FT4232H, FT230X, FT231X, FT234XD
+ Prolific PL2303
+ Silabs CP2102, CP210*
+ Qinheng CH340, CH341A, CH9102

更多信息参考[usb-serial-for-android](https://github.com/mik3y/usb-serial-for-android)
***
>已实现功能

- [x] 获取设备列表
- [x] 打开指定设备
- [x] 设置参数
- [x] 读取数据
- [x] 监听数据
- [x] 写入数据
- [x] 插入设备提示、唤起app
- [x] 流控，支持``NONE``、``RTS/CTS``、``DTR/DSR``
  
***
>使用方法

1、导入插件，**``打包自定义基座``**

2、引入插件 —— ``UsbSerial``类
``` JavaScript
import { UsbSerial } from '@/uni_modules/shmily-usb-serial';
```
3、初始化实例
``` JavaScript
const usbSerial = new UsbSerial();
```
4、查询设备
``` JavaScript
const list = usbSerial.getDeviceList();
```
示例如下：
```JavaScript
[
    {
        "productName": "USB 10/100 LAN",
        "deviceId": 1006,
        "deviceName": "/dev/bus/usb/001/006",
        "vendorId": 3034,
        "productId": 33106
    },
    {
        "productName": "USB-RS485\u0000",
        "deviceId": 1008,
        "deviceName": "/dev/bus/usb/001/008",
        "vendorId": 4292,
        "productId": 60000
    },
    {
        "productName": "CP2102N USB to UART Bridge Controller",
        "deviceId": 1007,
        "deviceName": "/dev/bus/usb/001/007",
        "vendorId": 4292,
        "productId": 60000
    },
    {
        "productName": "USB Serial",
        "deviceId": 1009,
        "deviceName": "/dev/bus/usb/001/009",
        "vendorId": 6790,
        "productId": 29987
    }
]
```
5、打开设备并设置参数
``` JavaScript
usbSerial.connect({
    vendorId: 6790, // vendorId，请填写实际值
    productId: 29987, // productId，请填写实际值
    baudRate: 115200, // 波特率，请填写实际值
    dataBits: 8, // 数据位，请填写实际值
    stopBits: 1, // 停止位，请填写实际值
    parity: 0,   // 校验位，请填写实际值
}, ({ success, message}) =>{
      
    }
  );
//  根据success判断是否打开成功
```
6、读取数据（``不建议，优先使用消息订阅``）
``` JavaScript
// HEX 或者 ASCII 是固定写法，不要改成其他值
const { success, data, message } = usbSerial.read('HEX');
// data: 32 2E 33 39 0D 0A 
```
or
``` JavaScript
const { success, data, message } = usbSerial.read('ASCII');
// data: 2.38\r\n

// 根据success判断是否读取成功，data是读取到的数据
// 如果读取失败，message返回的是原因，比如：Serial port is not connected
```
7、发送数据
``` JavaScript
// 字节数组格式
// 如果设备指定是0D(\r)结束，请手动拼接，默认是0A(\n)
// usbSerial.sendBytes('hello world\r');
usbSerial.sendBytes('hello world'); // 等同于usbSerial.sendBytes('hello world\n')
// 16进制格式
usbSerial.sendHex('5A 04 01 5F');
```
8、订阅、取消订阅消息（``推荐``）
``` JavaScript
// 订阅
usbSerial.subscribe({
  dataType: 'HEX',
  bufferSize: 64 // 如果出现丢失数据的情况，可以适当调整下大小
}, (data) => {});
```
or
``` JavaScript
usbSerial.subscribe({
  dataType: 'ASCII',
  bufferSize: 64
}, (data) => {});
// data是监听到的数据，格式同read
```
``` JavaScript
// 取消订阅
usbSerial.unsubscribe();
```
9、订阅、取消订阅设备
``` JavaScript
// 订阅
usbSerial.registerUsbAttach((action) => {
// action: true表示设备插入   false表示设备移除
});
// 取消订阅
usbSerial.unregisterUsbAttach();
```
10、关闭连接
``` JavaScript
usbSerial.disconnect(({success, message}) => {
   
});
// 根据success判断是否关闭成功
```
11、持续授权（``如果没有这样的需求，不要设置``）

``第一步``：项目根目录下创建AndroidManifest.xml文件，写入以下内容：
  
  ```Xml
  <?xml version="1.0" encoding="utf-8"?>
  <manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools"
    package="app包名">
    <application>
      <activity android:name="io.dcloud.PandoraEntry">
        <intent-filter>
          <action android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" />
        </intent-filter>
        <meta-data android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" android:resource="@xml/device_filter" />
      </activity>
    </application>
  </manifest>
  ```
  将 ``app包名``替换成你app实际的Android包名， 包名可以在打包页面查看。

  ``第二步``：将示例工程根目录下面的``nativeResources``目录复制到你的项目根目录下，确保 ``nativeResources/res/xml/device_filter.xml`` 存在，至此配置完成，重新打包自定义基座后生效。

  #### ``在第一次打开设备授权时勾选 "[√]连接xxx后一律打开xxx" 即可实现持续授权，app重启或者USB设备重新插拔也不需要申请权限。但是如果系统重启了，需要重新授权！！！``
  #### ``注意：配置持续授权后，设备插入时会自动唤起app，如果app处于后台，会自动切换到前台。如果app未启动，会自动打开app。``

12、多设备通信

如果需要同时读写多个设备，只需创建多个实例即可：

（``如果多个设备的productName和productId一致，暂时不能区分设备``）
```JavaScript
// 实例1，和设备a通信
const usbSerial1 = new UsbSerial();
usbSerial1.connect({
  // ...
  // 填写参数1
});
// 实例2，和设备b通信
const usbSerial2 = new UsbSerial();
usbSerial2.connect({
  // ...
  // 填写参数2
});
```
其他的操作参考前面的步骤，注意使用对应的实例就行了。

***
> 提供的其他方法

```JavaScript
// 设备是否已打开
const isConnect = usbSerial.isConnect();
// true or false
```
```JavaScript
// 设置流控
// true or false
const success = usbSerial.setDTR();
const success = usbSerial.getDSR(); 
const success = usbSerial.setRTS(); 
const success = usbSerial.getCTS(); 
```
***
>类型参考

```JavaScript
/**
 * @param deviceName 设备名称
 * @param deviceId 设备id
 * @param vendorId 供应商id
 * @param productId 产品id
 * @param productName 产品名称
 */
type IDeviceItem = {
  deviceName : string,
  deviceId : number,
  vendorId : number,
  productId : number,
  productName ?: string
}

/**
 * @param vendorId 供应商id
 * @param productId 产品id
 * @param baudRate 波特率
 * @param dataBits 数据位
 * @param stopBits 停止位
 * @param parity 校验位
 */
type IConnectOptions = {
  vendorId : number,
  productId : number,
  baudRate : number,
  dataBits : number,
  stopBits : number,
  parity : number,
}

/**
 * @param data 数据
 * @param success 操作是否成功
 * @param message 错误信息
 */
export type IOperData = {
  data ?: any,
  success : boolean,
  message ?: string
}

/**
 * 数据类型：16进制或者ASCII字符
 */
type IDataType = 'HEX' | 'ASCII';
```
