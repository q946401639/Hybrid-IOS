//
//  ScanViewController.m
//  Hybrid-IOS
//
//  Created by 冯德旺 on 2017/12/21.
//  Copyright © 2017年 冯德旺. All rights reserved.
//

#import "ScanViewController.h"
#import "CustomWebViewController.h"



@interface ScanViewController ()

//扫一扫的那个框
@property (weak, nonatomic) IBOutlet UIView *scanView;

//会话类
@property(nonatomic, strong) AVCaptureSession *session;

//预览图层
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;


@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupScanningQRCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self startScan];
}


- (void)setupScanningQRCode {
    NSLog(@"建立扫描");
    
    //1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2、创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //3、创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //4、设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //5、设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点) 设置应该为（y, x, h, w）太坑比了
    //    output.rectOfInterest = CGRectMake((self.view.frame.size.height - _scanView.frame.size.height) / 2 / self.view.frame.size.height, _scanView.frame.origin.x / self.view.frame.size.width, _scanView.frame.size.height / self.view.frame.size.height, _scanView.frame.size.width / self.view.frame.size.width);
    output.rectOfInterest = CGRectMake(0.15, 0.24, 0.7, 0.52);
    
    
    
    //6、初始化链接对象（会话对象）
    _session = [[AVCaptureSession alloc] init];
    //高质量采集器
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //6.1、添加会话输入
    [_session addInput:input];
    
    //6.2、添加会话输出
    [_session addOutput:output];
    
    //7、设置数据类型，需要将元数据输出添加到会话后，才能制定元数据类型，否则会报错
    //设置扫码支持的编码格式（如下设置 条形码 和 二维码 兼容）
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
}

- (void) startScan{
    
    //8、实例化预览图层，传递session是为了告诉图层将来显示什么内容
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    
    //9、将视图插入到当前视图
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    //10、启动会话
    [_session startRunning];
    
}

- (void) stopScan{
    //会频繁的扫描 调用代理方法
    //1、如果扫描完成 停止会话
    [_session stopRunning];
    
    //2、删除预览图层
    [_previewLayer removeFromSuperlayer];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    [self stopScan];
   
    
    //3、设置界面扫描显示结果
    if(metadataObjects.count > 0){
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        NSLog(@"扫描结果为：%@", obj.stringValue);
        
        if([obj.stringValue hasPrefix:@"http"]){
            //todo 跳转至webview页面
            
            CustomWebViewController *customController = [[CustomWebViewController alloc] init];
            
            customController.url = obj.stringValue;
            
            [self.navigationController pushViewController:customController animated:YES];
            
        } else {
            NSString *msg = [NSString stringWithFormat:@"二维码/条形码 信息： %@", obj.stringValue];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"二维码错误提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            [alertController addAction:confirmAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }
    
}

//即将退出controller时候 停止会话
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self stopScan];
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
