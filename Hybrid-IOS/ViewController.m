//
//  ViewController.m
//  Hybrid-IOS
//
//  Created by 冯德旺 on 2017/12/21.
//  Copyright © 2017年 冯德旺. All rights reserved.
//

#import "ViewController.h"
#import "CustomWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//扫一扫
- (IBAction)scanAction:(id)sender {
    NSLog(@"进入扫一扫页面");
}

//hybrid demo
- (IBAction)hybridDemoAction:(id)sender {
    NSLog(@"进入hybrid demo页面");
    
    CustomWebViewController *customController = [[CustomWebViewController alloc] init];
//    customController.url = @"https://www.baidu.com";
    [self.navigationController pushViewController:customController animated:YES];
}

@end
