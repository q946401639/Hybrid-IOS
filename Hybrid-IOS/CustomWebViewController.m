//
//  CustomWebViewController.m
//  Hybrid-IOS
//
//  Created by 冯德旺 on 2017/12/21.
//  Copyright © 2017年 冯德旺. All rights reserved.
//

#import "CustomWebViewController.h"

#define ScreenWidth   [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface CustomWebViewController ()

//webview层
@property (nonatomic, strong) WKWebView *customWebView;

//进度条
@property (nonatomic, strong) UIProgressView *progress;

//顶部导航条 返回按钮
@property (nonatomic, strong) UIBarButtonItem *backBtn;

//顶部关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeBtn;

//顶部刷新按钮
@property (nonatomic, strong) UIBarButtonItem *reloadBtn;

//resume队列
@property (nonatomic, strong) NSMutableArray *resumeQueue;

//pause队列
@property (nonatomic, strong) NSMutableArray *pauseQueue;

@end

@implementation CustomWebViewController

- (UIBarButtonItem *)backBtn{
    if(!_backBtn){
        UIImage *backImg = [[UIImage imageNamed:@"backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *backHLImg = [[UIImage imageNamed:@"backItemImage_hl"] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
        
        UIButton *backB = [[UIButton alloc] init];
        [backB setTitle:@"返回" forState:UIControlStateNormal];
        [backB setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backB setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backB.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backB setImage:backImg forState:UIControlStateNormal];
        [backB setImage:backHLImg forState:UIControlStateHighlighted];
        [backB sizeToFit];
        
        [backB addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        
        _backBtn = [[UIBarButtonItem alloc] initWithCustomView:backB];
        
    }
    
    return _backBtn;
    
}

- (UIBarButtonItem *)closeBtn{
    if(!_closeBtn){
        
        _closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
        
    }
    return _closeBtn;
}

- (UIBarButtonItem *)reloadBtn{
    if(!_reloadBtn){
        _reloadBtn = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(reloadAction)];
    }
    return _reloadBtn;
}


- (UIProgressView *)progress{
    if(!_progress){
        
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 20 + self.navigationController.navigationBar.frame.size.height, ScreenWidth, 2)];
        
//        [_progress setAlpha:0.0f];
    }
    
    return _progress;
}

- (WKWebView *)customWebView{
    if(!_customWebView){
        
        //设置网页的配置文件
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        config.allowsAirPlayForMediaPlayback = YES;//允许视频播放
        config.allowsInlineMediaPlayback = YES;// 允许在线播放
        config.selectionGranularity = YES;// 允许可以与网页交互，选择视图
        config.processPool = [[WKProcessPool alloc] init];// web内容处理池
        
        //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        [userContentController addScriptMessageHandler:self name:@"JSBridge"];
        
        // 是否支持记忆读取
        config.suppressesIncrementalRendering = YES;
        
        // 允许用户更改网页的设置
        config.userContentController = userContentController;
        
        _customWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _customWebView.backgroundColor = [UIColor whiteColor];
        
        // 设置代理
        _customWebView.UIDelegate = self;
        _customWebView.navigationDelegate = self;
        
        //开启手势触摸
        // 设置 可以前进 和 后退
        _customWebView.allowsBackForwardNavigationGestures = YES;
        
        [_customWebView sizeToFit];
        
        //设置自定义代理  貌似低版本的ios（ios8）不支持
        [[NSUserDefaults standardUserDefaults] synchronize]; //设置同步
        [_customWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError * _Nullable error) {

            NSString *newUserAgent = [NSString stringWithFormat:@"%@ %@", result, @"JSBridgeDemoUserAgent"];
            [_customWebView setCustomUserAgent:newUserAgent];
            
        }];
        
        
        
        
    }
    
    return _customWebView;
}

//监听网页加载进度 和 截取网页title
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if([keyPath isEqualToString:@"estimatedProgress"]){
        
        if(object == _customWebView){
            [_progress setAlpha:1.0f];
            [_progress setProgress:_customWebView.estimatedProgress];
            
            if(_customWebView.estimatedProgress >= 1.0f){
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [_progress setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [_progress setAlpha:0.0f];
                }];
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
    } else if([keyPath isEqualToString:@"title"]){
        
        if(object == _customWebView){
            
            self.navigationItem.title = _customWebView.title;
            
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
    }
    
}

//js操作native的方法 拦截
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSDictionary *msgMap = [NSDictionary dictionaryWithDictionary:message.body];
    NSLog(@"JS交互参数：%@", msgMap);
    NSLog(@"name：%@", message.name);
    NSString *nativeMethod = msgMap[@"nativeMethod"];
    
    NSLog(@"nativeMethod：%@", nativeMethod);
    
    if([nativeMethod isEqualToString:@"openPage"]){ //打开新的webview页面
//        if(!msgMap[@"url"]) return;
        
        CustomWebViewController *customController = [[CustomWebViewController alloc] init];
        
        NSString *url = [self getValueForParams:@"url" forParams:msgMap[@"params"]];
        
        if(url){
            customController.url = url;
        }
        
        [self.navigationController pushViewController:customController animated:YES];
        
    } else if([nativeMethod isEqualToString:@"getDeviceId"]) { //获取设备uuid 并没啥卵用
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        NSString *js = [NSString stringWithFormat:@"JSBridge.eventMap.%@(\'%@\')", msgMap[@"callback"], uuid];
        [_customWebView evaluateJavaScript:js completionHandler:nil];
        
    } else if([nativeMethod isEqualToString:@"hideTitle"]) { //隐藏titlebar
        
        self.navigationController.navigationBarHidden = YES;
        
    } else if([nativeMethod isEqualToString:@"showTitle"]) { //显示titlebar
        
        self.navigationController.navigationBarHidden = NO;
        
    } else if([nativeMethod isEqualToString:@"popPage"]) { //关闭webview
        int step = 1;
      
        id s = [self getValueForParams:@"step" forParams:msgMap[@"params"]];
        if(s){
            step = [s intValue];
        }
        
        int totals = self.navigationController.viewControllers.count;
        int targetIndex = totals - step - 1;
        
        if(targetIndex >= 0){
            UIViewController *targetController = self.navigationController.viewControllers[targetIndex];
            [self.navigationController popToViewController:targetController animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else if([nativeMethod isEqualToString:@"addResumeEvent"]) { //resume监听 进入前台
        
        NSString *js = [NSString stringWithFormat:@"JSBridge.eventMap.%@()", msgMap[@"callback"]];
//        [_customWebView evaluateJavaScript:js completionHandler:nil]; //todo
        [_resumeQueue addObject:js];
        
    } else if([nativeMethod isEqualToString:@"addPauseEvent"]) { //pause监听 压入后台
        
        NSString *js = [NSString stringWithFormat:@"JSBridge.eventMap.%@()", msgMap[@"callback"]];
        //        [_customWebView evaluateJavaScript:js completionHandler:nil]; //todo
        [_resumeQueue addObject:js];
        
    } else {
        return ;
    }
    
}

//alert实现 webview会对js进行 alert等系统事件的拦截
- (void) webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}

//ios自定义协议拦截
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    
    //ios接收到的scheme的值 始终为小写
    if([scheme isEqualToString:@"jsbridge"]){
        
        [self handleCustomAction:url];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    
}
//自定义执行的 协议拦截方法
- (void)handleCustomAction:(NSURL *)url{
    
    NSString *host = [url host];
    NSLog(@"host: %@", host);
    NSLog(@"params: %@", [url query]);
    
    //解析query为字典
    NSArray *paramsArray = [[url query] componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < [paramsArray count]; i++){
        NSArray *step = [paramsArray[i] componentsSeparatedByString:@"="];
        
        [params setObject:step[1] forKey:step[0]];
    }
    
    if([host isEqualToString:@"openPage"]){
        
        NSString *pageUrl = params[@"url"];
//        pageUrl = [pageUrl stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        pageUrl = [pageUrl stringByRemovingPercentEncoding];
        
        CustomWebViewController *customController = [[CustomWebViewController alloc] init];
        customController.url = pageUrl;
        
        [self.navigationController pushViewController:customController animated:YES];
    }
    
}


- (void)backAction {
    if(_customWebView.canGoBack){
        [_customWebView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadAction{
    [_customWebView reload];
}

//webview加载url
- (void)loadURL {
    
    if(_url){
        NSURL *url = [NSURL URLWithString:_url];
        [self.customWebView loadRequest:[NSURLRequest requestWithURL:url]];
    } else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"JSBridgeDemo" ofType:@"html"];
        [self.customWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadURL];
    
    //设置整体背景色为白色
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.customWebView];
    
    [self.view addSubview:self.progress];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    //初始设置返回按钮 刷新按钮
    [self.navigationItem setLeftBarButtonItem:self.backBtn];
    [self.navigationItem setRightBarButtonItem:self.reloadBtn];
    
    //初始化 resumeQueue对象
    _resumeQueue = [[NSMutableArray alloc] init];
    //初始化 pauseQueue对象
    _pauseQueue = [[NSMutableArray alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //进度条 title 添加监控
    [_customWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [_customWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    //app进入前台事件监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeEvents) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //app压入后台事件监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseEvents) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //防止进度条重复监听
    [_customWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_customWebView removeObserver:self forKeyPath:@"title"];
    
    //防止resume pause重复监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    [self updateNavBarItems];
    
}

//顶部返回 关闭的设置
- (void)updateNavBarItems{
    
    if(_customWebView.canGoBack){

        [self.navigationItem setLeftBarButtonItems:@[self.backBtn, self.closeBtn]];
        
    } else {
        [self.navigationItem setLeftBarButtonItems:@[self.backBtn]];
    }
    
}

//resume方法, app进入前台
- (void)resumeEvents{
    NSLog(@"==============resumeEvents==============");
    
    //循环遍历执行注册的resume方法
    for(int i = 0; i < [_resumeQueue count]; i++){
        
        [_customWebView evaluateJavaScript:[_resumeQueue objectAtIndex:i] completionHandler:nil];
        
    }
    
}

//pause方法，app压入后台方法
- (void)pauseEvents{
    NSLog(@"==============pauseEvents==============");
    
    //循环遍历执行注册的pause方法
    for(int i = 0; i < [_pauseQueue count]; i++){
        
        [_customWebView evaluateJavaScript:[_pauseQueue objectAtIndex:i] completionHandler:nil];
        
    }
}

- (id) getValueForParams:(NSString *)key forParams:(NSString *)params{
    
    if(params == nil){
        return nil;
    }
    
    NSDictionary *queryParams = [self dictionaryWithJSONString:params];
    
    if(queryParams[key]){
        return queryParams[key];
    }
    
    return nil;
}

//JSON字符串转化为字典
- (NSDictionary *) dictionaryWithJSONString:(NSString *)jsonString{
    
    if(jsonString == nil){
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err){
        NSLog(@"json解析失败：%@", err);
        
        return nil;
    }
    
    return dic;
    
}




//todo 右侧按钮...  暂不做

//todo 侧滑菜单 和 jsbridge无关  暂不做




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
