//
//  NSDictionary+Category.h
//  永辉管家
//
//  Created by youjunjie on 12/04/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Add)

-(id)safeObjectForKey_:(NSString *)aKey;

- (id)safeObjectForKey_:(NSString *)aKey hintClass:(id)cls;

- (id)safeObjectForKey_:(NSString *)aKey hstringClass:(id)cls;

- (id)yhObjectForKey_:(NSString *)key;


/**
 验证类型是否为字典
 */
- (BOOL)verifyType_;


@end
