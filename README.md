open189sdk-v1.0-ios
===================

open189sdk v1.0 for ios


整体架构
1.  Open189Engine.h: Open189 API 接口类，对外提供Open189 api的调用，包括登录，API调用，音乐榜单查询等功能。
2.	Open189Request：api请求执行类，封装了回调接口，来调用Open189中的接口方法。
3.	SFHFKeychainUtils：工具类，用来存储token等授权信息。
4.	DataConversion：工具类数据类型转换。
5.	Open189Util：工具类，包括BASE64 MD5等encode，decode方法。
