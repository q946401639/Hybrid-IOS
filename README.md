## IOS Hybrid (混合式应用开发 IOS版)

### native部分设计
- AppDelegate （app的生命周期 及 钩子函数）
	- 承接从外部scheme唤起过来的事件
- ViewController （主页）
	- 扫一扫按钮
	- 跳转JSBridge示例页
- ScanViewController （扫一扫页面）
	- 提供扫一扫能力
	- 检测扫描码是否为http(s)链接，是的话 则跳转至webview页
- CustomWebViewController （自定义webview）
	- 承接前端h5的url加载
	- 设置url、scheme、alert拦截
	- 自定义UA
	- 提供native调用js的能力
	- 提供js调用native的方法
- info.plist （配置）
	- URL types --> URL Scheme 配置唤起scheme
	- App Transport Security Settings --> Allow Arbitrary Loads 配置http访问
	- Privacy - Camera Usage Description 配置相机访问权限


### js部分设计
- 封装前端JSBridge 与 Android 兼容
- 开发代码示例

### native to js
- resume、pause事件触发

### js to native
- 隐藏titleBar
- 显示titleBar
- 打开新的webview来承接url
- 关闭当前 或者 之前的几个WebViewActivity
- 注册resume事件
- 注册pause事件
- 自定义协议拦截示例

### 外部唤起app并跳转至指定页面
- {schemeName}://{host}:{port}/{path}?{query=xxx}
- schemeName全部小写

### 开发参考
- https://www.jianshu.com/p/99c3af6894f4 (iOS下JS与OC互相调用 系列文章)

