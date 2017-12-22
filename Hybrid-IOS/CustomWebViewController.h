//
//  CustomWebViewController.h
//  Hybrid-IOS
//
//  Created by 冯德旺 on 2017/12/21.
//  Copyright © 2017年 冯德旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface CustomWebViewController : UIViewController<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) NSString *url; //要加载的URL

@end
