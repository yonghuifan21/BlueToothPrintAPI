//
//  BlueToothVisitor.h
//  POSCoconut
//
//  Created by youjunjie on 16/8/3.
//  Copyright © 2016年 youjunjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


//事件通知名称
static NSString *const kkBTNoticeCentralManagerState = @"RCTNoticeCentralManagerState";//蓝牙状态通知
static NSString *const kkBTNoticeScanForPeripheralsState = @"RCTNoticeScanForPeripheralsState";//打开扫描设备状态通知
static NSString *const kkBTNoticeCancelScanState = @"RCTNoticeCancelScanState";//关闭扫描设备状态通知
static NSString *const kkBTNoticeDiscoverPeripheralState = @"RCTNoticeDiscoverPeripheralState";//发现外围设备状态通知
static NSString *const kkBTNoticeConnectPeripheralState = @"RCTNoticeConnectPeripheralState";//连接外围设备状态通知
static NSString *const kkBTNoticePrintState = @"RCTNoticePrintState";//打印状态通知
static NSString *const kkBTNoticeDidDisconnectPeripheralState = @"RCTNoticeDidDisconnectPeripheralState";//断开连接通知
static NSString *const kkBTNoticePrintErrorState = @"RCTNoticePrintErrorState";//打印异常通知

//事件通知name
static NSString *const kkBTPeripheralName = @"name";//发现外围设备状态 蓝牙名称
static NSString *const kkBTPeripheralUUID = @"uuid";//发现外围设备状态 uuid
static NSString *const kkBTPeripheralAdvertisement = @"advertisement";//advertisement
static NSString *const kkBTPeripheralState = @"peripheralState";//连接状态
static NSString *const kkBTPeripheralServiceUUID = @"peripheralServiceUUID";//连接状态


//status
static NSString *const kkStateName = @"state";//状态名称
static NSString *const kkStateMsgName = @"message";//返回结果的状态连接
static NSString *const kkStateSucess = @"0";//0代表成功
static NSString *const kkStateFail = @"1";//1代表失败
static NSString *const kkStateConnect = @"1";//连接状态
static NSString *const kkStateDisconnect = @"";//未连接状态

static NSString *const kkEVT_BT_ERROR = @"EvtBtErr";//初始化错误
static NSString *const kkEVT_BT_CLOSE = @"EvtBtClose";//蓝牙按钮关闭（ios端无法获到）
static NSString *const kkEVT_SCAN_START = @"EvtScanStart";//搜索开始
static NSString *const kkEVT_SCAN_STOP = @"EvtScanStop";//搜索停止
static NSString *const kkEVT_DEVICE_FOUND = @"EvtDeviceFound";//蓝牙发现
static NSString *const kkEVT_DEVICE_CONNECT_STATE = @"EvtDeviceConnectState";//蓝牙连接
static NSString *const kkEVT_PRINT_ERROR = @"EvtPrintError" ; //打印异常

//didDiscoverCharacteristicsForService
static NSString *const kkEVT_DISCOVER_CHARACTER_DEVICE = @"EvtDiscoverCharacteristicsForDevice";//蓝牙连接



@protocol BlueToothVisitorDelegate;


@protocol TBPBlueToothVisitor <NSObject>

/**
 *  //供外部调用获取回调
 */
@property (nonatomic,weak)id<BlueToothVisitorDelegate> delegate;

/**
 *  中心设备管理
 */
@property (nonatomic, strong) CBCentralManager *centralManager;
/**
 *  存放外设的数组
 */
@property (nonatomic, strong) NSMutableArray *peripherals;
/**
 *  外设
 */
@property (nonatomic, strong) CBPeripheral *peripheral;
/**
 *  特性
 */
@property (nonatomic, strong) CBCharacteristic *characteristicInfo;


//初始化蓝牙设备，可获取到本机蓝牙设备状态
- (void)initCentralManager;

//开始扫描外围设备
- (void)scanForPeripherals;

//停止扫描外围设备
- (void)cancelScan;

//连接外围设备
- (void)connectPeripheral:(CBPeripheral *)peripheral options:options;

//断开外围设备
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;

//断开所有连接
- (void)cancelAllPeripheralsConnection;

//写入蓝牙值
- (void)writeValue:(NSData *)data;

//统一的事件通知代理，通知返回状态状态给js
- (void)noticeEventAgent:(NSString *)eventName
                    body:(NSDictionary *)bodyDic;

@end







//访问蓝牙代理
@protocol BlueToothVisitorDelegate <NSObject>


- (void)blueToothVisitor:(id<TBPBlueToothVisitor>)visitor peripheral:(CBPeripheral *)peripheral  didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

//扫描发现设备
- (void)blueToothVisitor:(id<TBPBlueToothVisitor>)visitor centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral;

@end
