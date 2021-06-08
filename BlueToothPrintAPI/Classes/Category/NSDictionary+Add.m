//
//  NSDictionary+Category.m
//  永辉管家
//
//  Created by youjunjie on 12/04/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "NSDictionary+Add.h"
#import "NSString+Add.h"

@implementation NSDictionary (Add)



-(id)safeObjectForKey_:(NSString *)aKey
{
  id object = [self objectForKey:aKey];
  
  if (object == [NSNull null]) {
    object = nil;
  }
  
  return object;
}

- (id)safeObjectForKey_:(NSString *)aKey hintClass:(id)cls
{
  id obj = [self safeObjectForKey_:aKey];
  if (cls && [obj isKindOfClass:cls])
  {
    return obj;
  }
  return nil;
}

- (id)safeObjectForKey_:(NSString *)aKey hstringClass:(id)cls
{
  id obj = [self safeObjectForKey_:aKey];
  if (cls && [obj isKindOfClass:cls])
  {
    return obj;
  }else if (cls && [obj isKindOfClass:[NSNumber class]])
  {
    return [obj stringValue];
  }
  return nil;
}

//用于数据解析，返回对象为字符串或值类型，数组和字典不要用此方法
- (id)yhObjectForKey_:(NSString *)key
{
    if (key == nil || [NSString emptyOrNull_:key]) {
        return nil;
    }
    id object = [self objectForKey:key];
    if (object == nil || object == [NSNull null]) {
        return @"";
    }
    return object;
}

- (BOOL)verifyType_
{
    if ([self isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    return NO;
}


@end
