//
//  NSObject+Add.m
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/5.
//

#import "NSObject+Add.h"

@implementation NSObject (Add)

- (BOOL)isExist
{
    if (nil == self)
    {
        return NO;
    }
    
    if ([NSNull null] == self)
    {
        return NO;
    }
  
    
    if ([self isKindOfClass:[NSString class]])
    {
        NSString *tempStr = (NSString *)self;
        
        if ([tempStr isEqualToString:@"<null>"]) {
             return NO;
        }
        if ([tempStr isEqualToString:@"NULL"]) {
             return NO;
        }
        if ([tempStr isEqualToString:@"nil"]) {
             return NO;
        }
        if ([tempStr isEqualToString:@"null"]) {
             return NO;
        }
        if ([tempStr isEqualToString:@"(null)"]) {
             return NO;
        }
        if ([tempStr isEqualToString:@"[null]"]) {
             return NO;
        }
        if ((tempStr.length < 1)
            || [tempStr isEqualToString:@" "]
            || [tempStr isEqualToString:@""])
        {
            return NO;
        }
        if (tempStr.length < 10 && [tempStr containsString:@"null"]) {
            return NO;
        }
        
        if ([NSNull null] == self)
        {
            return NO;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]])
    {
        NSArray *tempArr = (NSArray *)self;
        if (!(tempArr.count > 0))
        {
            return NO;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *tempDic = (NSDictionary *)self;
        if (!(tempDic.count > 0))
        {
            return NO;
        }
    }
   
    
    return YES;
    
}


@end
