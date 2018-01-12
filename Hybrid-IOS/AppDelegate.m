//
//  AppDelegate.m
//  Hybrid-IOS
//
//  Created by 冯德旺 on 2017/12/21.
//  Copyright © 2017年 冯德旺. All rights reserved.
//

#import "AppDelegate.h"
#import "CustomWebViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

//拦截 外部scheme的唤起操作 并解析参数 进行下一步操作
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    NSLog(@"=============app被唤起===============");
    NSLog(@"唤起来源app：%@", options[@"UIApplicationOpenURLOptionsSourceApplicationKey"]);
    NSLog(@"=============scheme参数===============");
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
        
        //decode 字符串
        pageUrl = [pageUrl stringByRemovingPercentEncoding];
        
        CustomWebViewController *customController = [[CustomWebViewController alloc] init];
        customController.url = pageUrl;
        
        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
        [nav pushViewController:customController animated:YES];
    
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"程序被压入后台");

    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"程序即将进入前台");

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
