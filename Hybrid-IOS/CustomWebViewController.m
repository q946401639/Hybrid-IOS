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
        
    }
    
    return _customWebView;
}

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

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSDictionary *msgMap = [NSDictionary dictionaryWithDictionary:message.body];
    NSLog(@"JS交互参数：%@", msgMap);
    NSLog(@"name：%@", message.name);
    NSString *nativeMethod = msgMap[@"nativeMethod"];
    
    NSLog(@"nativeMethod：%@", nativeMethod);
    
    if([nativeMethod isEqualToString:@"openPage"]){ //打开新的webview页面
//        if(!msgMap[@"url"]) return;
        
        CustomWebViewController *customController = [[CustomWebViewController alloc] init];
        customController.url = msgMap[@"url"];
        
        [self.navigationController pushViewController:customController animated:YES];
        
    } else if([nativeMethod isEqualToString:@"getDeviceId"]) { //获取设备uuid 并没啥卵用
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        NSString *js = [NSString stringWithFormat:@"JSBridge.eventMap.%@(\'%@\')", msgMap[@"callback"], uuid];
        [_customWebView evaluateJavaScript:js completionHandler:nil];
        
    } else if([nativeMethod isEqualToString:@"hideTitle"]) {
        
        self.navigationController.navigationBarHidden = YES;
        
    } else if([nativeMethod isEqualToString:@"showTitle"]) {
        
        self.navigationController.navigationBarHidden = NO;
        
    } else if([nativeMethod isEqualToString:@"popPage"]) {
        int step = 1;
        if(msgMap[@"step"]){
            step = [msgMap[@"step"] intValue];
        }
        
        int totals = self.navigationController.viewControllers.count;
        int targetIndex = totals - step - 1;
        
        if(targetIndex >= 0){
            UIViewController *targetController = self.navigationController.viewControllers[targetIndex];
            [self.navigationController popToViewController:targetController animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else {
        return ;
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
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //进度条 title 添加监控
    [_customWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [_customWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
        
    [_customWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_customWebView removeObserver:self forKeyPath:@"title"];
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
