//
//  BlueToothDetailTableVC.h
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/3.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, BlueToothDetailModelDataType){
    BlueToothDetailModelDataTypeName = 0, //名字
    BlueToothDetailModelDataTypeUUID = 1, //uuid
    BlueToothDetailModelDataTypeDISCONNECT = 2, //断开
    BlueToothDetailModelDataTypeIGNORE = 3, //忽略
};

NS_ASSUME_NONNULL_BEGIN

@interface TBPDetailTableVC : UITableViewController
@property (nonatomic, strong)CBPeripheral *peripheral; //蓝牙设备对象
@end

NS_ASSUME_NONNULL_END

@interface BlueToothDetailModel : NSObject
@property (nonatomic, copy)NSString * _Nullable title;
@property (nonatomic, copy)NSString * _Nullable detail;
@property (nonatomic, assign)CGFloat height;
@property (nonatomic, assign)BlueToothDetailModelDataType detaType;
@end

@interface BlueToothDetailSectionModel : NSObject
@property (nonatomic, copy)NSString * _Nullable title;
@property (nonatomic, strong)NSArray<BlueToothDetailModel *> * _Nullable detailList;
@property (nonatomic, assign)CGFloat height;
@end


