//
//  TBPCachePerInfoManager.h
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/4.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


NS_ASSUME_NONNULL_BEGIN
@class NativeCacheModel;
@interface TBPCachePerInfoManager : NSObject
+ (instancetype)shareInstance;
//缓存已经连接过的蓝牙设备
- (void)cacheTheCBPeripheralWith: (NSString *)name uuid: (NSString *)uuid serviceUUID: (NSString *)serviceUUID;
//本地缓存的所有的蓝牙设备
- (NSArray<NativeCacheModel *> *)localList;
//移除已经缓冲的设备
- (void)removeCachePeripheral: (NSString *)uuidString;
@end

NS_ASSUME_NONNULL_END

@interface NativeCacheModel : NSObject<NSCoding>
@property(nonatomic, copy)NSString * _Nullable name; //蓝牙设备名称
@property(nonatomic, copy)NSString * _Nullable uuidString; //蓝牙设备唯一识别码
@property(nonatomic, copy)NSString * _Nullable serviceUUID; //蓝牙设备服务中特性唯一识别码
//serviceUUID

- (instancetype _Nullable )initWithName:(NSString *_Nullable)name uuidString: (NSString *_Nullable)uuid serviceUUID: (NSString *_Nullable)serviceUUID;
+ (id _Nullable )nativeCacheModelWithName: (NSString *_Nullable)name uuidString: (NSString *_Nullable)uuid serviceUUID: (NSString *_Nullable)serviceUUID;
@end
