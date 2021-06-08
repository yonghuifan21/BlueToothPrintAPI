//
//  NSString+Category.h
//  NOAHWM
//
//  Created by youjunjie on 14/10/20.
//  Copyright (c) 2014年 Ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Add)

#pragma mark 判断字串是否为空
+ (BOOL)emptyOrNull_:(NSString *)str;

+ (BOOL)notEmptyOrNull_:(NSString *)str;

//判断字符个数 汉字两个
+ (NSUInteger)charactersLength_: (NSString *)string;

//时间搓修改
+ (NSString *)msecToFormatTime_:(long) msec;

/**
 根据字符串和字体获取宽度（默认不换行）
 
 @param str str description
 @param font font description
 @return 字符串宽度
 */
+ (CGFloat)stringWidth_:(NSString *)str
                  font:(UIFont *)font;

//返回金额
+ (NSString *) centToYuanString_:(long)cents;

//返回百分数
+ (NSString *) centToNumString_:(long)cents;

// 对字符串URLencode编码
- (NSString *)urlEncoding_;
// 对字符串URLdecode解码
- (NSString *)urlDecoding_;

// 对字符串添加url参数
- (NSString *)stringByAddingURLParams_:(NSDictionary *)params;

//获取url里面的参数
- (NSDictionary *)getURLParams_;

+ (NSString *)printDicJson_:(NSDictionary *)dict;

//对象转json
+ (NSString*)DataTOjsonString_:(id)object;
@end
