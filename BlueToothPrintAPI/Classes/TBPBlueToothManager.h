//
//  NativeBlueToothManager.h
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/3.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBPBlueToothManager : NSObject

//统一的事件通知代理，通知返回状态状态给js
+ (void)noticeEventAgent:(NSString *)eventName
                    body:(NSDictionary *)bodyDic;

/// 开始扫描设备
- (void)startScan;

//停止扫描
- (void)stopScan;

//连接外围设备, 蓝牙设备连接状态回调
- (void)connect: (NSString *)mac;

//连接已经连接的设备, 不停止扫描
- (void)onlyConnect: (NSString *)mac;

//断开当前连接的外围设备
- (void)disconnect;

//打印数据, 直接是打印指令
- (void)printDataWith: (NSData *)data;

/// 单利对象
+ (instancetype)shareInstance;

///搜索到蓝牙设备，显示蓝牙的列表
- (void)searchPeripheralsBlock: (void(^__nullable)(NSArray<CBPeripheral *> * perials))result;

//查找已经连接过的蓝牙, 然后主动连接
- (void)retrieveConnectedPeripheralsWithServices: (void(^)(BOOL isFind))resblock;

//判断连接是否是当前的蓝牙
- (BOOL)connectThePerpheralWith: (CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
