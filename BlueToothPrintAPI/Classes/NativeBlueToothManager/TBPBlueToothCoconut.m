//
//  BlueToothHandle.m
//  POSCoconut
//
//  Created by youjunjie on 16/8/3.
//  Copyright © 2016年 youjunjie. All rights reserved.
//

#import "TBPBlueToothCoconut.h"
#import "TBPBlueToothManager.h"


@interface TBPBlueToothCoconut () <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    NSTimer *connectTimer;
}


@end

@implementation TBPBlueToothCoconut : NSObject
@synthesize delegate=_delegate;
@synthesize centralManager = _centralManager;
@synthesize peripherals = _peripherals;
@synthesize peripheral = _peripheral;
@synthesize characteristicInfo = _characteristicInfo;

#pragma mark ---------------------属性----------------------

- (NSMutableArray *)peripherals {
    if (_peripherals == nil) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

#pragma mark ---------------------初始化----------------------

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.connectState = @NO;
      
//      if (!_centralManager) {
//        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//      }
      
    }
    return self;
}

- (void)dealloc
{
  //开一个定时器监控连接超时的情况
  if (connectTimer && connectTimer.isValid) {
    [connectTimer invalidate];//停止时钟
    connectTimer = nil;
  }
}


#pragma mark ---------------------内部方法----------------------



#pragma mark ---------------------Bluetooth代理方法----------------------


#pragma mark ---------------------CBCentralManagerDelegate----------------------

/*
 回调方法，确认蓝牙状态，当状态为CBCentralManagerStatePoweredOn才能去扫描设备
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
  NSString * msg = nil;
  NSString *stateCode = kkStateFail;
    
    switch ([central state])
    {
      case CBCentralManagerStateUnsupported: {
        
        msg = @"central init: The platform/hardware doesn&#39;t support Bluetooth Low Energy.";
        break;
      }

      case CBCentralManagerStateUnauthorized: {
        
        msg = @"central init: The app is not authorized to use Bluetooth Low Energy.";
        break;
      }
      case CBCentralManagerStatePoweredOff: {
        
        msg = @"central init: Bluetooth is currently powered off.";
        break;
      }
        
      case CBCentralManagerStatePoweredOn: {
        msg = @"central init: work";
        stateCode = kkStateSucess;
        
        [self.peripherals removeAllObjects];
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        
        break;
      }
        case CBCentralManagerStateUnknown:
        msg = @"central init: CBCentralManagerStateUnknown";
        default:
            ;
    }
  
  //通知js
  NSDictionary *noticeDic = @{kkStateName:stateCode,
                              kkStateMsgName:msg};
  [self noticeEventAgent:kkBTNoticeCentralManagerState body:noticeDic];
  NSLog(@"初始化手机蓝牙设备Central manager code:%@ msg: %@", stateCode,msg);
}

/*
 扫描，发现设备后会调用
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral.name.length == 0) {
        return;
    }
  if (![peripheral.name hasPrefix:@"Printer"]) {
    //return;
  }

    if (![self.peripherals containsObject:peripheral]) {
        
        [self.peripherals addObject:peripheral];
        
        NSString *str = [NSString stringWithFormat:@"----------------发现蓝牙外设: peripheral: %@ rssi: %@, UUID:  advertisementData: %@ ", peripheral, RSSI,  advertisementData];
        
      NSLog(@"%@",str);
//      NSLog(@"name: %@ ",peripheral.name);
//      NSLog(@"identifier: %@ ",peripheral.identifier);
      
      
      id advertisementDataIsConnectable = [advertisementData objectForKey:CBAdvertisementDataIsConnectable];
      NSString *advertisement = [[NSString alloc]initWithFormat:@"%@",advertisementDataIsConnectable] ;
      
      //通知js
      NSString *name = @"";
      NSString *identi = [self uuidVerify:peripheral.identifier.UUIDString];
      if (identi && identi.length > 5) {
        NSString *subIdenti = [identi substringFromIndex:identi.length -4];
        name = [[NSString alloc]initWithFormat:@"%@-%@",peripheral.name,subIdenti];
      }
      else {
        name = peripheral.name;
      }
      
      NSString *connectState = kkStateDisconnect;
      if (peripheral.state == CBPeripheralStateConnected) {
        connectState = kkStateConnect;
        self.peripheral = peripheral;
      }
      NSDictionary *notice = @{kkBTPeripheralName: name,
                               kkBTPeripheralUUID: [self uuidVerify:peripheral.identifier.UUIDString],
                               kkBTPeripheralState: connectState,
                               kkBTPeripheralAdvertisement: advertisement,
                               kkStateName:kkStateSucess,
                               kkStateMsgName:@"发现蓝牙设备",
                               };
      [self noticeEventAgent:kkBTNoticeDiscoverPeripheralState body:notice];
      
        if (_delegate && [_delegate respondsToSelector:@selector(blueToothVisitor:centralManager:didDiscoverPeripheral:)]) {
            [_delegate blueToothVisitor:self centralManager:central didDiscoverPeripheral:peripheral];
        }
    }
}

/*
 连接成功后回调
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"－－－－－－－－－－－－－－－已经连接上设备: %@", peripheral);
  
    peripheral.delegate = self;
    [central stopScan];
    [peripheral discoverServices:nil];
    //成功连接设备
    [self successConnect: peripheral];
  
  //开一个定时器监控连接超时的情况
  if (connectTimer && connectTimer.isValid) {
    [connectTimer invalidate];//停止时钟
    connectTimer = nil;
  }
  
}

//连接设备成功
- (void)successConnect: (CBPeripheral *)peripheral{
    //通知js
    NSString *connectState = kkStateDisconnect;
    if (peripheral.state == CBPeripheralStateConnected) {
        connectState = kkStateConnect;
        self.peripheral = peripheral;
    }
    NSDictionary *notice = @{kkStateName:kkStateSucess,
                             kkStateMsgName:@"连接设备成功！",
                             kkBTPeripheralName: [NSString stringWithFormat:@"%@",peripheral.name],
                             kkBTPeripheralUUID: [self uuidVerify:peripheral.identifier.UUIDString],
                             kkBTPeripheralState: connectState,
                             };
    self.connectState = @YES;
    [self noticeEventAgent:kkBTNoticeConnectPeripheralState body:notice];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
  NSLog(@"－－－－－－－－－－－－－－－连接设备失败 %@",peripheral);
  [self connectPeripheralFail:peripheral];
  
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict
{
  NSLog(@"%@",dict);
}

#pragma mark ---------------------CBPeripheralDelegate----------------------

/*
 扫描到服务后回调
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"-------------------------已经发现服务了");
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    for (CBService* service in  peripheral.services) {
        NSLog(@"扫描到的serviceUUID:%@",service.UUID);
        //扫描特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/*
 扫描到特性后回调
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"－－－－－－－－－－－－－－扫描到特性了，可以开始打印了，需要写入打印的内容");
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic * cha in service.characteristics)
    {
        CBCharacteristicProperties p = cha.properties;
        if (p & CBCharacteristicPropertyBroadcast) {
        }
        if (p & CBCharacteristicPropertyRead) {
        }
        if (p & CBCharacteristicPropertyWriteWithoutResponse) {
            if(![self.peripheral isEqual: peripheral]){
                //成功连接设备
                [self successConnect: peripheral];
            }
            self.peripheral = peripheral;
            self.characteristicInfo = cha;
            
            NSLog(@"%@",peripheral);
            NSLog(@"%@",cha);
            //[[NSUserDefaults standardUserDefaults] setObject:peripheral.name forKey:@"currPeripheral"];
            
            //发现设备
            if (self.delegate && [self.delegate respondsToSelector:@selector(blueToothVisitor:peripheral:didDiscoverCharacteristicsForService:error:)]) {
                [self.delegate blueToothVisitor:self peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
            }
            //kkEVT_DISCOVER_CHARACTER_DEVICE
            //发送一个通知
            NSDictionary *notice = @{kkStateName:kkStateSucess,
                                     kkStateMsgName:@"发现蓝牙服务中的特性成功！",
                                     kkBTPeripheralName: [NSString stringWithFormat:@"%@",peripheral.name],
                                     kkBTPeripheralUUID: [self uuidVerify:peripheral.identifier.UUIDString],
                                     kkBTPeripheralServiceUUID: [service.UUID UUIDString]
                                     };
            [self noticeEventAgent:kkEVT_DISCOVER_CHARACTER_DEVICE body:notice];
            
        }
        if (p & CBCharacteristicPropertyWrite) {
            
            //                self.peripheral = peripheral;
            //                self.characteristicInfo = cha;
            //
            //                NSLog(@"%@",peripheral);
            //                NSLog(@"%@",cha);
            //[[NSUserDefaults standardUserDefaults] setObject:peripheral.name forKey:@"currPeripheral"];
            
        }
        if (p & CBCharacteristicPropertyNotify) {
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
  NSLog(@"");
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"＝＝＝＝error%@",error);
      
      //通知js
      NSDictionary *notice = @{kkStateName:kkStateFail,
                               kkStateMsgName: @"didWriteValueForCharacteristic失败",
                               };
      [self noticeEventAgent:kkBTNoticePrintState body:notice];
      
    }else{
        NSLog(@"＝＝＝＝打印成功");
      //通知js
      NSDictionary *notice = @{kkStateName:kkStateSucess,
                               kkStateMsgName:@"打印成功！",
                               };
      [self noticeEventAgent:kkBTNoticePrintState body:notice];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
  NSDictionary *notice;
  
  if (error) {
    //断开失败
    notice = @{kkStateName:kkStateFail,
               kkStateMsgName: @"断开设备失败！",
               kkBTPeripheralName: [NSString stringWithFormat:@"%@",peripheral.name],
               kkBTPeripheralUUID: [self uuidVerify:peripheral.identifier.UUIDString],
               };
  }
  else {
    //断开成功
    notice = @{kkStateName:kkStateSucess,
               kkStateMsgName: @"断开设备成功！",
               kkBTPeripheralName: [NSString stringWithFormat:@"%@",peripheral.name],
               kkBTPeripheralUUID: [self uuidVerify:peripheral.identifier.UUIDString],
               };
  }
  //通知js
  self.connectState = @NO;
  [self noticeEventAgent:kkBTNoticeDidDisconnectPeripheralState body:notice];
  _peripheral = nil;
}



#pragma mark ---------------------接口API----------------------s
//单利
+ (instancetype)shareInstance
{
  static TBPBlueToothCoconut *sharedInstance = nil;
  
  if (!sharedInstance) {
    sharedInstance = [[self alloc] init];
  }
  return sharedInstance;
    
}

#pragma mark ---------------------Visitor API----------------------

//初始化蓝牙设备，可获取到本机蓝牙设备状态
- (void)initCentralManager {
  if (!_centralManager) {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  }
}

//查找蓝牙
- (void)scanForPeripherals {
    //开始扫描
  NSLog(@"开始扫描");
  if (!_centralManager) {
    NSLog(@"初始化设备中心.....");
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  }
  else {
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
  }
  NSDictionary *notice = @{kkStateName:kkStateSucess,
                           kkStateMsgName:@"开始扫描设备！",
                           };
  [self noticeEventAgent:kkBTNoticeScanForPeripheralsState body:notice];
}

//停止扫描
- (void)cancelScan {
  NSLog(@"停止扫描");
  [self.centralManager stopScan];
  
  NSDictionary *notice = @{kkStateName:kkStateSucess,
                           kkStateMsgName:@"停止扫描设备！",
                           };
  [self noticeEventAgent:kkBTNoticeCancelScanState body:notice];
}

//连接设备
- (void)connectPeripheral:(CBPeripheral *)peripheral options:options {
  
  NSLog(@"开始连接蓝牙: %@ uuid:%@",peripheral.name,[self uuidVerify:peripheral.identifier.UUIDString]);
    if (peripheral) {

        [self.centralManager connectPeripheral:peripheral
         options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES]}];
      
      //开一个定时器监控连接超时的情况
      if (connectTimer && connectTimer.isValid) {
        [connectTimer invalidate];//停止时钟
        connectTimer = nil;
      }
      NSDictionary *peripheralDic = @{kkBTPeripheralName: [[NSString alloc]initWithFormat:@"%@",peripheral.name],
                                      kkBTPeripheralUUID: [self uuidVerify:peripheral.identifier.UUIDString],
                                      };
      connectTimer = [NSTimer timerWithTimeInterval:10.0f target:self selector:@selector(connectPeripheralTimeOut:) userInfo:peripheralDic repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:connectTimer forMode:NSRunLoopCommonModes];
      NSLog(@"设置连接定时......");
    }
    else{
      NSLog(@"未找到设备....");
    }
}

//断开设备
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
  
  NSLog(@"断开设备 %@",peripheral.name);
  if (peripheral) {
      [self.centralManager cancelPeripheralConnection:peripheral];
  }
}

//断开所有连接
- (void)cancelAllPeripheralsConnection {
  
  NSLog(@"断开所有连接....");
    for (int i=0;i<_peripherals.count;i++) {
        [_centralManager cancelPeripheralConnection:_peripherals[i]];
    }
  _peripheral = nil;
}

//写入蓝牙值
//发送指令，推荐使用
-(void)writeCommadnToPrinterWthitData:(NSData *)data
{
  NSLog(@"发送蓝牙包....");
  //数据分包
  int BLE_SEND_MAX_LEN=182;//146也是可以的，不过官方推荐用64。so.... 182最大
  NSData *sendData = [NSData data];
  for (int i = 0; i < [data length]; i += BLE_SEND_MAX_LEN)
  {
    if((i+BLE_SEND_MAX_LEN)<[data length]){
      
      NSRange range=NSMakeRange(i, BLE_SEND_MAX_LEN);
      //NSString *rangeStr=[NSString stringWithFormat:@"%i%i",i,i+BLE_SEND_MAX_LEN];
      NSData *subdata=[data subdataWithRange:range];
      sendData=subdata;
    }else{
      NSRange range=NSMakeRange(i, (int)([data length]-i));
      //NSString *rangeStr=[NSString stringWithFormat:@"%i,@%i",i,(int)([data length]-i)];
      NSData *subdata=[data subdataWithRange:range];
      sendData=subdata;
    }
    [self writeValue:sendData];
  }
}

- (void)writeValue:(NSData *)data {
    
    for (CBService* service in  _peripheral.services) {
        
        NSLog(@"扫描到的serviceUUID:%@",service.UUID);
        //扫描特征
        
        for (CBCharacteristic * cha in service.characteristics)
        {
            CBCharacteristicProperties p = cha.properties;
            if (p & CBCharacteristicPropertyBroadcast) {
            }
            if (p & CBCharacteristicPropertyRead) {
            }
            if (p & CBCharacteristicPropertyWriteWithoutResponse) {
                
                self.characteristicInfo = cha;
                
                NSLog(@"%@",cha);
                [self.peripheral writeValue:data forCharacteristic:self.characteristicInfo type:CBCharacteristicWriteWithResponse];
                
                return;
                
            }
            if (p & CBCharacteristicPropertyWrite) {
                
            }
            if (p & CBCharacteristicPropertyNotify) {
                
            }
        }
        
    }
    
//    return;
//    [self.peripheral writeValue:data forCharacteristic:self.characteristicInfo type:CBCharacteristicWriteWithResponse];
}


/**
 校验UUID，ios9上会出现多余字符
 ios9 uuis: <__NSConcreteUUID 0x1611334c0> 5F6B6BAF-3EE1-C013-9D94-75C4E33B5686ßß

 @param uuid <#uuid description#>
 @return <#return value description#>
 */
- (NSString *)uuidVerify:(NSString *)uuid {
  
//  if (uuid && [uuid isKindOfClass:[NSString class]]) {
//    
//    NSArray *subArray = [uuid componentsSeparatedByString:@" "];
//    if (subArray && subArray.count == 2) {
//      
//      NSString *uuisNew = [subArray objectAtIndex:1];
//      if (uuisNew && uuisNew.length > 0) {
//        return uuisNew;
//      }
//    }
//  }
  return uuid;
}

- (void)connectPeripheralFail:(CBPeripheral *)peripheral
{
  NSString *name = [[NSString alloc]initWithFormat:@"%@",peripheral.name];
  NSDictionary *peripheralDic = @{kkBTPeripheralName: name,
                                  kkBTPeripheralUUID: [self uuidVerify:peripheral.identifier.UUIDString]
                                  };
  [self connectPeripheralFailOfUserInfo:peripheralDic];
}
- (void)connectPeripheralTimeOut:(NSTimer *)timer
{
  [self connectPeripheralFailOfUserInfo:[timer userInfo]];
}
- (void)connectPeripheralFailOfUserInfo:(NSDictionary *)userInfo
{
  if (_peripheral) {
    [self cancelPeripheralConnection:_peripheral];
  }
  //通知js
  NSDictionary *notice = @{kkStateName:kkStateFail,
                           kkStateMsgName: @"连接设备失败！",
                           kkBTPeripheralName: [userInfo objectForKey:kkBTPeripheralName],
                           kkBTPeripheralUUID: [userInfo objectForKey:kkBTPeripheralUUID],
                           kkBTPeripheralState: kkStateDisconnect
                           };
  [self noticeEventAgent:kkBTNoticeConnectPeripheralState body:notice];
}

//统一的事件通知代理，通知返回状态状态给js
- (void)noticeEventAgent:(NSString *)eventName
                    body:(NSDictionary *)bodyDic
{
    [TBPBlueToothManager noticeEventAgent: eventName body: bodyDic];
}

@end
