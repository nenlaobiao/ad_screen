## 1.1.1（2025-06-29）
+ 将消息订阅的回调发送至主线程运行
+ 新增流控相关api：``setDTR``, ``getDSR``, ``setRTS``, ``getCTS``,
+ 修复在安卓14及以上版本设备上注册广播失败的问题
+ 移除创建实例时的回调函数
## 1.1.0（2024-11-23）
+ 【注意】HBuilderX4.27版本及以后适用本次更新
+ 【重要】适配HBuilderX4.25版本及以后的回调函数参数触发一次后立即自动回收，导致订阅函数只触发一次的问题，请参考示例代码
+ 【重要】将所有promise函数修改为回调函数（``connect``和``disconnect``），以规避HBuilderX4.26版本引发的 uts：调用返回参数为promise类型的函数会报UTS: targetFunction does not exists 错误的问题，[详情](https://issues.dcloud.net.cn/pages/issues/detail?id=10051 "https://issues.dcloud.net.cn/pages/issues/detail?id=10051")， 请参考示例代码
+ 【重要】修改打开设备参数，``productName``修改为``vendorId``，避免部分设备productName后带了``\u0000``，在视觉上无法分辨导致打开设备找不到的问题，请参考示例代码
+ 发送数据时默认结束符修改为``\r\n``
+ 修改``IReadOptons``拼写错误，正确为``IReadOptions``
## 1.0.9（2024-08-22）
+ 修复代码版本不一致问题
## 1.0.8（2024-06-26）
+ 修改``sendBytes``函数内部逻辑，使用该函数发送数据时若没有控制符``\n``或者``\r``，则自动拼接``\n``，否则不处理
+ 修复同时连接多个设备时，只能打开第一个的问题
## 1.0.7（2024-06-25）
+ 修复由于上次缓冲区数据引起的数据错误问题
## 1.0.6（2024-06-25）
+ 添加类型导出，有需要可从interface.uts中导入
+ 新增设备属性vendorId（供应商id）
+ 新增``getMaxPacketSize``函数，用于获取usb每次传输最大数据量（字节）
+ 修改类型``ReturnFormat``为``IDataType``，其中``STRING``修改为``ASCII``
+ 修改``read``实现逻辑
+ 修复消息订阅函数``subscribe``传输大量数据时，数据丢失问题
## 1.0.5（2024-05-08）
+ 添加``多设备通信``说明
## 1.0.4（2024-04-18）
+ 修复``产品名称 productName``为空时无法打开设备的问题
+ 增加``持续授权``示例，USB设备重新插拔无需再次授权（系统重启后需要重新授权），详细操作请看操作说明``持续授权``部分
## 1.0.3（2024-03-26）
+ 添加数据发送 api ``sendBytes``、``sendHex``
+ 添加设备订阅 api ``registerUsbAttach``，实现设备插拔提示
+ 添加消息订阅 api ``subscribe``，实现数据监听
+ ``read`` 增加format参数，控制返回的数据格式：16进制字符串或者ASCII字符串
## 1.0.2（2024-03-26）
+ 添加``armeabi-v7a`` 、``arm64-v8a``、 ``x86``系统支持  
+ 添加USB权限判断  
+ 修改 ``getDeviceList`` 为同步方法   
+ 替换forEach、流式api等在安卓6低版本系统不支持的函数，目前插件支持Android 5到Android 13  
+ 优化数据读取、设备打开和关闭，弃用ExecutorService  
+ 感谢814***@qq.com测试发现的问题
## 1.0.1（2024-03-26）
## 1.0.0（2024-03-22）
初始版
