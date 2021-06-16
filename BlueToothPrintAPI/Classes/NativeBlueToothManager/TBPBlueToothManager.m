//
//  NativeBlueToothManager.m
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/3.
//

#import "TBPBlueToothManager.h"
#import "TBPBlueToothCoconut.h"
#import "NSString+Add.h"
#import "TBPCachePerInfoManager.h"

@interface TBPBlueToothManager()<BlueToothVisitorDelegate>
@property (nonatomic, copy)void(^searchPeripheraBlock)(NSArray<CBPeripheral *> * perials); //搜索蓝牙设备回调

@property (nonatomic, assign)BOOL isConnecting;
//@property (nonatomic, copy)void(^connectPeripheraBlock)(NSString *state, NSDictionary *info); //连接蓝牙设备回调

@end

@implementation TBPBlueToothManager

+ (instancetype)shareInstance{
    static TBPBlueToothManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
        [[TBPBlueToothCoconut shareInstance] initCentralManager];
    });
    return shareInstance;
}
/// 开始扫描设备
- (void)startScan{
    
    [[TBPBlueToothCoconut shareInstance] cancelScan];
    [[TBPBlueToothCoconut shareInstance] cancelAllPeripheralsConnection];
    [TBPBlueToothCoconut shareInstance].centralManager = nil;
    [[TBPBlueToothCoconut shareInstance] setDelegate: self];
    [[TBPBlueToothCoconut shareInstance] scanForPeripherals];
}

//停止扫描
- (void)stopScan{
    [[TBPBlueToothCoconut shareInstance] cancelScan];
}

///搜索到蓝牙设备，显示蓝牙的列表
- (void)searchPeripheralsBlock: (void(^__nullable)(NSArray<CBPeripheral *> * perials))result;{
    self.searchPeripheraBlock = result;
    
    NSArray <CBPeripheral *>* list = [TBPBlueToothCoconut shareInstance].peripherals;
    if(list.count > 0){
        //查找是否有连接过的蓝牙，如果有，就开始连接
        if(self.searchPeripheraBlock){
            self.searchPeripheraBlock(list);
        }
    }
}

//连接外围设备
- (void)connect: (NSString *)mac{
    NSLog(@"<RCT> connect 连接外围设备 %@",mac);
    
    NSLog(@"停止扫描.....");
    
    [[TBPBlueToothCoconut shareInstance]  cancelScan];
    
    CBPeripheral *peripheral = [TBPBlueToothCoconut shareInstance].peripheral;
    if ([NSString emptyOrNull_:mac] || peripheral) {
      //通知js
      NSDictionary *notice = @{kkStateName:kkStateFail,
                               kkStateMsgName: @"连接设备失败！mac为空或者存在已连接设备",
                               kkBTPeripheralName: @"",
                               kkBTPeripheralUUID: @"",
                               kkBTPeripheralState: kkStateDisconnect
                               };
      [TBPBlueToothManager noticeEventAgent:kkBTNoticeConnectPeripheralState body:notice];
      return;
    }
    else
    {
      //寻找可用的外围设备
      for (CBPeripheral *peripheral in [TBPBlueToothCoconut shareInstance].peripherals) {
        
        NSString *findUUID = peripheral.identifier.UUIDString;
        if ([mac isEqualToString:findUUID]) {
          
          //如果找到对应的设备，则连接
          [[TBPBlueToothCoconut shareInstance]  connectPeripheral:peripheral options:nil];
          
          NSLog(@"RCT connect 开始连接蓝牙设备 %@ %@",peripheral.name,mac);
          return;
        }
      }
      //通知js
      NSDictionary *notice = @{kkStateName:kkStateFail,
                               kkStateMsgName: @"连接设备失败！未找到",
                               kkBTPeripheralName: @"",
                               kkBTPeripheralUUID: mac,
                               kkBTPeripheralState: kkStateDisconnect
                               };
      [TBPBlueToothManager noticeEventAgent:kkBTNoticeConnectPeripheralState body:notice];
    }
}

//连接已经连接的设备
- (void)onlyConnect: (NSString *)mac {
    
    NSLog(@"<RCT> connect 连接外围设备 %@",mac);
    
    NSLog(@"停止扫描.....");
    
    
    CBPeripheral *peripheral = [TBPBlueToothCoconut shareInstance].peripheral;
    if ([NSString emptyOrNull_:mac] || peripheral) {
        //通知js
        NSDictionary *notice = @{kkStateName:kkStateFail,
                                 kkStateMsgName: @"连接设备失败！mac为空或者存在已连接设备",
                                 kkBTPeripheralName: @"",
                                 kkBTPeripheralUUID: @"",
                                 kkBTPeripheralState: kkStateDisconnect
        };
        [TBPBlueToothManager noticeEventAgent:kkBTNoticeConnectPeripheralState body:notice];
        return;
    }
    else
    {
        //寻找可用的外围设备
        for (CBPeripheral *peripheral in [TBPBlueToothCoconut shareInstance].peripherals) {
            
            NSString *findUUID = peripheral.identifier.UUIDString;
            if ([mac isEqualToString:findUUID]) {
                
                //如果找到对应的设备，则连接
                [[TBPBlueToothCoconut shareInstance]  connectPeripheral:peripheral options:nil];
                
                NSLog(@"RCT connect 开始连接蓝牙设备 %@ %@",peripheral.name,mac);
                return;
            }
        }
        //通知js
        NSDictionary *notice = @{kkStateName:kkStateFail,
                                 kkStateMsgName: @"连接设备失败！未找到",
                                 kkBTPeripheralName: @"",
                                 kkBTPeripheralUUID: mac,
                                 kkBTPeripheralState: kkStateDisconnect
        };
        [TBPBlueToothManager noticeEventAgent:kkBTNoticeConnectPeripheralState body:notice];
    }
}

//断开当前连接的外围设备
- (void)disconnect{
    
    NSLog(@"<RCT> disconnect 断开外围设备");
    CBPeripheral *peripheral = [TBPBlueToothCoconut shareInstance].peripheral;
    if (peripheral) {
      NSLog(@"<RCT> disconnect 找到连接设备，开始断开 %@",peripheral.name);
      [[TBPBlueToothCoconut shareInstance] cancelPeripheralConnection:peripheral];
    }
    else {
      NSDictionary *notice = @{kkStateName:kkStateSucess,
                               kkStateMsgName: @"断开设备成功！无连接设备",
                               kkBTPeripheralName: @"",
                               kkBTPeripheralUUID: @"",
                               };
      [TBPBlueToothManager noticeEventAgent:kkBTNoticeDidDisconnectPeripheralState body:notice];
    }
    
}

//断开所有连接的外部设备
- (void)disconnectAllPeripheral{
    
    NSLog(@"<RCT> cancelAllConnection 断开所有外围设备");
    [[TBPBlueToothCoconut shareInstance] cancelAllPeripheralsConnection];
}


//查找已经连接过的蓝牙, 然后主动连接
- (void)retrieveConnectedPeripheralsWithServices: (void(^)(BOOL isFind))resblock{
    NSArray<NativeCacheModel *> *nativeCaches = [[TBPCachePerInfoManager shareInstance] localList];
    NSArray *exitPers = [TBPBlueToothCoconut shareInstance].peripherals;
    if(nativeCaches.count == 0){
        resblock(NO);
        return;
    }
    NSString *uuidString = nativeCaches[0].uuidString;
    for(CBPeripheral *cacheModel in exitPers){
        if([cacheModel.identifier.UUIDString isEqualToString: uuidString]){
            [self onlyConnect: cacheModel.identifier.UUIDString];
            resblock(YES);
        }
    }
    resblock(NO);
}
//判断连接是否是当前的蓝牙
- (BOOL)connectThePerpheralWith: (CBPeripheral *)peripheral{
    CBPeripheral *curConnectPer = [TBPBlueToothCoconut shareInstance].peripheral;
    BOOL connect = [TBPBlueToothCoconut shareInstance].connectState.boolValue;
    if(connect && curConnectPer && [curConnectPer.identifier.UUIDString isEqualToString: peripheral.identifier.UUIDString]){
        return YES;
    }
    return  NO;;
}




//打印数据, 直接是打印指令
- (void)printDataWith: (NSData *)data;{
             
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TBPBlueToothCoconut shareInstance] writeCommadnToPrinterWthitData: data];
    });
}





//统一的事件通知代理，通知返回状态状态给js
+ (void)noticeEventAgent:(NSString *)eventName
                    body:(NSDictionary *)bodyDic
{
  NSString *bodyStr = [NSString DataTOjsonString_:bodyDic];
  NSLog(@"<RCT> %@ body: %@",eventName,bodyStr);
  if (!eventName || !bodyDic || ![eventName isKindOfClass:[NSString class]]) {
    return;
  }
  
  NSString *sendEventName = @"";
  NSDictionary *sendDic = nil;
  
  NSString *state = [bodyDic objectForKey:kkStateName] ? :@"";
  NSString *msg =[bodyDic objectForKey:kkStateMsgName] ? :@"";
  //设备初始化
  if ([eventName isEqualToString:kkBTNoticeCentralManagerState]) {
    
    //发送初始化失败事件
    if ([state isEqualToString:kkStateFail]) {
      sendDic = @{};
      sendEventName = kkEVT_BT_ERROR;
    }
  }
  else if ([eventName isEqualToString:kkBTNoticeScanForPeripheralsState]) {
    //开始扫描设备
    sendDic = @{};
    sendEventName = kkEVT_SCAN_START;
  }
  else if ([eventName isEqualToString:kkBTNoticeCancelScanState]) {
    //关闭发现设备
    sendDic = @{};
    sendEventName = kkEVT_SCAN_STOP;
  }
  //发现外围设备
  else if ([eventName isEqualToString:kkBTNoticeDiscoverPeripheralState]) {
    
    NSString *name = [bodyDic objectForKey:kkBTPeripheralName] ?:@"";
    NSString *mac = [bodyDic objectForKey:kkBTPeripheralUUID] ?:@"";
    NSString *connect = [bodyDic objectForKey:kkBTPeripheralState] ?:@"";;
  
    sendDic = @{@"name":name,
                @"mac":mac,
                @"connect":connect,
                };
    sendEventName = kkEVT_DEVICE_FOUND;
  }
  //连接外围设备状态通知
  else if ([eventName isEqualToString:kkBTNoticeConnectPeripheralState]) {
    
    NSString *name = [bodyDic objectForKey:kkBTPeripheralName]  ?:@"";
    NSString *mac = [bodyDic objectForKey:kkBTPeripheralUUID]  ?:@"";
    NSString *connect = [bodyDic objectForKey:kkBTPeripheralState]  ?:@"";
    NSString *connection = connect;
    
    sendDic = @{@"name":name,
                @"mac":mac,
                @"connect":connect,
                @"connection":connection,
                };
    sendEventName = kkEVT_DEVICE_CONNECT_STATE;
  }
  //打印状态通知
  else if ([eventName isEqualToString:kkBTNoticePrintState]) {
    
  }
  //断开连接通知
  else if ([eventName isEqualToString:kkBTNoticeDidDisconnectPeripheralState]) {
    
    NSString *name = [bodyDic objectForKey:kkBTPeripheralName] ?:@"";
    NSString *mac = [bodyDic objectForKey:kkBTPeripheralUUID] ?:@"";
    NSString *connect = @"";
    NSString *connection = connect;
    
    sendDic = @{@"name":name,
                @"mac":mac,
                @"connect":connect,
                @"connection":connection,
                };
    sendEventName = kkEVT_DEVICE_CONNECT_STATE;
  }
  //打印异常通知
  else if ([eventName isEqualToString:kkBTNoticePrintErrorState]) {
    
    sendDic = @{};
    sendEventName = kkEVT_PRINT_ERROR;
  }
    
  else if([eventName isEqualToString: kkEVT_DISCOVER_CHARACTER_DEVICE]){
      sendEventName = eventName;
      sendDic = bodyDic;
  }
    
    //接受到通知，需要跟js交互，这个看产品需要，如果需要就通知，不需要就不处理
//  if (instance) {
//    [instance sendRNNotice:sendEventName body:sendDic];
//  }
    [[TBPBlueToothManager shareInstance] sendRNNotice: sendEventName body: sendDic];
}

- (void)sendRNNotice:(NSString *)eventName
                body:(NSDictionary *)bodyDic
{
    NSLog(@"发送通知 name:%@ body:%@",eventName,bodyDic);
    if([eventName isEqualToString: kkEVT_DEVICE_CONNECT_STATE]){ //连接蓝牙成功
        [[NSNotificationCenter defaultCenter] postNotificationName: eventName object: bodyDic];
    }
    //发现打印机中打印特性, 开始缓存
    if([eventName isEqualToString: kkEVT_DISCOVER_CHARACTER_DEVICE]){
        //缓存蓝牙信息
        NSString *name = bodyDic[kkBTPeripheralName];
        NSString *uuid = bodyDic[kkBTPeripheralUUID];
        NSString *serviceuuid = bodyDic[kkBTPeripheralServiceUUID];
        TBPCachePerInfoManager *cacheInfoManager = [TBPCachePerInfoManager shareInstance];
        [cacheInfoManager cacheTheCBPeripheralWith: name uuid: uuid serviceUUID: serviceuuid];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: eventName object: bodyDic];
    }
    
}

#pragma mark ============================  搜索设备的时候，主动连接连接过的蓝牙设备 ============================

- (void)scanPrePeriDeviceAndConnect{
//    if(self.isConnecting || [BlueToothCoconut shareInstance].connectState.boolValue){
//        return;
//    }
    [[TBPBlueToothManager shareInstance] retrieveConnectedPeripheralsWithServices:^(BOOL isFind) {
//        if(isFind){
//            self.isConnecting = YES;
//        }
    }];
}

#pragma mark ============================  BlueToothVisitorDelegate ============================

//搜索到蓝牙设备，开始回调
- (void)blueToothVisitor:(id<TBPBlueToothVisitor>)visitor centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didDiscoverPeripheral ==== %@", peripheral.description);
    NSArray <CBPeripheral *>* list = [TBPBlueToothCoconut shareInstance].peripherals;
    //查找是否有连接过的蓝牙，如果有，就开始连接
    [self scanPrePeriDeviceAndConnect];
    if(self.searchPeripheraBlock){
        self.searchPeripheraBlock(list);
    }
}

- (void)blueToothVisitor:(id<TBPBlueToothVisitor>)visitor peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
}


@end
