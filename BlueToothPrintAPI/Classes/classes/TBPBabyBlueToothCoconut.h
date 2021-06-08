//
//  BabyBlueToothCoconut.h
//  POSCoconut
//
//  Created by youjunjie on 16/8/3.
//  Copyright © 2016年 youjunjie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBPBlueToothVisitor.h"

@interface TBPBabyBlueToothCoconut : NSObject <TBPBlueToothVisitor>
{
    
}

//单利
- (void)shareInstance;

@end
