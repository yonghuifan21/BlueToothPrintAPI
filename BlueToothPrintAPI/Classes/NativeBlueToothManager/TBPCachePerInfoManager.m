//
//  TBPCachePerInfoManager.m
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/4.
//

#import "TBPCachePerInfoManager.h"
#define USERDEFAULT [NSUserDefaults standardUserDefaults]
#define LOCALMAPKEY @"local_list"


@implementation TBPCachePerInfoManager

+ (instancetype)shareInstance{
    static TBPCachePerInfoManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

//缓存已经连接过的蓝牙设备
- (void)cacheTheCBPeripheralWith: (NSString *)name uuid: (NSString *)uuid serviceUUID: (NSString *)serviceUUID{
    NSString *uuidString = uuid;
    if(!uuidString || [uuidString length] <= 0){
        //空的标识符不缓存
        return;
    }
    
    NativeCacheModel *cacheModel = [NativeCacheModel nativeCacheModelWithName: name uuidString: uuidString serviceUUID: serviceUUID];
    NSMutableArray *currentCacheModels = [NSMutableArray arrayWithArray: [self localList]];
    BOOL isFind = NO;
    //查找缓存中是否有相同标识的设备
    for(NativeCacheModel *icacheModel in currentCacheModels){
        if([icacheModel.uuidString isEqualToString: uuidString]){
            isFind = YES;
        }
    }
    if(isFind){
        return;
    }
    [currentCacheModels insertObject:cacheModel atIndex:0];
    NSArray *allCacheModels = [NSArray arrayWithArray: currentCacheModels];
    //序列化
    NSData * wData = [NSKeyedArchiver archivedDataWithRootObject:allCacheModels];
    [USERDEFAULT setObject:wData forKey: LOCALMAPKEY];
    [USERDEFAULT synchronize];
}


//本地缓存的所有的蓝牙设备
- (NSArray<NativeCacheModel *> *)localList{
    NSData *listData =  [USERDEFAULT objectForKey: LOCALMAPKEY];
    NSArray *list = [NSKeyedUnarchiver unarchiveObjectWithData: listData];
    if(!list){
        return [NSArray array];
    }else{
        return list;
    }
}

//移除已经缓冲的设备
- (void)removeCachePeripheral: (NSString *)uuidString {
    
    NSMutableArray *currentCacheModels = [NSMutableArray arrayWithArray: [self localList]];
    NSInteger findIndex = -1;
    NSInteger index = 0;
    //查找缓存中是否有相同标识的设备
    for(NativeCacheModel *icacheModel in currentCacheModels){
        if([icacheModel.uuidString isEqualToString: uuidString]){
            findIndex = index;
        }
        index += 1;
    }
    if(findIndex < 0){
        return;
    }
    [currentCacheModels removeObjectAtIndex: findIndex];
    NSArray *allCacheModels = [NSArray arrayWithArray: currentCacheModels];
    //序列化
    NSData * wData = [NSKeyedArchiver archivedDataWithRootObject:allCacheModels];
    [USERDEFAULT setObject:wData forKey: LOCALMAPKEY];
    [USERDEFAULT synchronize];
}


@end

@implementation NativeCacheModel

- (instancetype _Nullable )initWithName:(NSString *_Nullable)name uuidString: (NSString *_Nullable)uuid serviceUUID: (NSString *_Nullable)serviceUUID{
    self = [super init];
    if (self) {
        self.uuidString = uuid;
        self.name = name;
        self.serviceUUID = serviceUUID;
    }
    return self;
}

+ (id _Nullable )nativeCacheModelWithName: (NSString *_Nullable)name uuidString: (NSString *_Nullable)uuid serviceUUID: (NSString *_Nullable)serviceUUID{
    NativeCacheModel *cacheModel = [[NativeCacheModel alloc] initWithName: name uuidString: uuid serviceUUID: serviceUUID];
    return  cacheModel;
}


//写入文件时调用 -- 将需要存储的属性写在里面
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey: NSStringFromSelector(@selector(name))];
    [aCoder encodeObject:self.uuidString forKey: NSStringFromSelector(@selector(uuidString))];
    [aCoder encodeObject:self.serviceUUID forKey: NSStringFromSelector(@selector(serviceUUID))];
}

//从文件中读取时调用 -- 将需要存储的属性写在里面
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:  NSStringFromSelector(@selector(name))];
        self.uuidString = [aDecoder decodeObjectForKey: NSStringFromSelector(@selector(uuidString))];
        self.serviceUUID = [aDecoder decodeObjectForKey: NSStringFromSelector(@selector(serviceUUID))];
    }
    return self;
}

@end
