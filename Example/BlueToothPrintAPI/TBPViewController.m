//
//  TBPViewController.m
//  BlueToothPrintAPI
//
//  Created by 范国徽 Jack on 06/08/2021.
//  Copyright (c) 2021 范国徽 Jack. All rights reserved.
//

#import "TBPViewController.h"
#import <TBPBridgeWebView.h>
#import <TBPBlueToothCoconut.h>
#import <TBPListTableVC.h>
#import <TBPBlueToothManager.h>

@interface TBPViewController ()
@property (strong, nonatomic)TBPBridgeWebView *webView;
@end

@implementation TBPViewController

//搜索打印机
- (IBAction)searchBlueToothAction:(id)sender {
    
//    [[NativeBlueToothManager shareInstance] startScan];

    TBPListTableVC *listVC = [[TBPListTableVC alloc] init];
    [self.navigationController pushViewController: listVC animated: YES];
}

//立即打印
- (IBAction)printAction:(id)sender {
    
//    [[NativeBlueToothManager shareInstance] print: self.inputTxtView.text];
    
    
}
- (void)refreshWebView{
//    [self.webView loadLocalHtmlAndPrint];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"mock" ofType: @"json"];
//    NSString *dataStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
////    NSString *dataStr = @"abc";
    [self.webView setPrintData:@"" finishPrintBlock:^(NSDictionary * _Nonnull printDict) {
//        NSLog(@"printResult ==== %@-%@", @(success), message);
    }];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"printjson" ofType: @"json"];
    NSString *dataStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [self.webView printTemplateGetPrintTemplateNo:1 version: 0 data:dataStr finishPrintBlock:^(NSDictionary * _Nonnull printDict) {
        
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NativeBlueToothManager shareInstance] searchPeripheralsBlock:^(NSArray<CBPeripheral *> * _Nonnull perials) {
////        self.dataList = perials;
////        [self.tableView reloadData];
////        [self scanPrePeriDeviceAndConnect];
//    }];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"蓝牙列表" style:UIBarButtonItemStylePlain target:self action:@selector(searchBlueToothAction:)];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithTitle:@"打印" style:UIBarButtonItemStylePlain target:self action:@selector(refreshWebView)];

    self.navigationItem.rightBarButtonItems = @[buttonItem, refreshItem];
    
//    [[NativeBlueToothManager shareInstance] searchPeripheralsBlock: nil];
    
    TBPBridgeWebView *webView = [[TBPBridgeWebView alloc] initWithFrame: self.view.bounds];
    
    [self.view addSubview: webView];
    _webView = webView;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        [[NativeBlueToothManager shareInstance] searchPeripheralsBlock: nil];
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"mock" ofType: @"json"];
//        NSString *dataStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        [self->_webView setPrintData: dataStr];
//    });
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
