//
//  BlueToothHandle.h
//  POSCoconut
//
//  Created by youjunjie on 16/8/3.
//  Copyright © 2016年 youjunjie. All rights reserved.
//  蓝牙控制类

#import <Foundation/Foundation.h>

#import "TBPBlueToothVisitor.h"

@interface TBPBlueToothCoconut : NSObject <TBPBlueToothVisitor>
{
    
}
@property(nonatomic,strong)NSNumber * connectState;
//单利
+ (instancetype)shareInstance;


-(void)writeCommadnToPrinterWthitData:(NSData *)data;


@end
