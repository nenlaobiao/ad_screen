# rs232-serial

>使用方法

1、从插件市场下载并导入插件

2、在页面引入插件 —— ``RS232Serial``类，然后**``打包自定义基座``**
``` JavaScript
import { RS232Serial } from '@/uni_modules/shmily-rs232-serial';
```
3、初始化实例
``` JavaScript
const serialPort = new RS232Serial();
```
4、查询设备
``` JavaScript
const list = serialPort.getDeviceList();
```
示例如下：
```JavaScript
[
    "/dev/ttyGS3",
    "/dev/ttyGS2",
    "/dev/ttyGS1",
    "/dev/ttyGS0",
    "/dev/ttyS3",
    "/dev/ttyS2",
    "/dev/ttyS1",
    "/dev/ttyS0"
]
```
5、订阅数据
``` JavaScript
serialPort.subscribe('ASCII', data => {
  console.log(data);
});
// 或者
serialPort.subscribe('HEX', data => {
  console.log(data);
});
```
6、打开设备并设置参数
``` JavaScript
serialPort.open({
  port: '/dev/ttyS0', // 填写实际值
  baudRate: 115200, // 填写实际值
  // 以下参数没有时就按照下面的传
  dataBits: 8,
  stopBits: 1,
  parity: 0,
  flowCon：0
});
```
7、关闭设备
``` JavaScript
serialPort.close();
```
8、发送数据
``` JavaScript
serialPort.sendHex('68 65 6C 6C 6F 20 77 6F 72 6C 64'); // 有无空格均可
// 或者
serialPort.sendText('hello world');
```
