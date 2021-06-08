//
//  NSString+Category.m
//  NOAHWM
//
//  Created by youjunjie on 14/10/20.
//  Copyright (c) 2014年 Ryan. All rights reserved.
//

#import "NSString+Add.h"
#import "NSDictionary+Add.h"

@implementation NSString (Add)

#pragma mark 判断字串是否为空
+ (BOOL)emptyOrNull_:(NSString *)str
{
    return str == nil || (NSNull *)str == [NSNull null] || str.length == 0 || [str isEqualToString:@"(null)"];
}

+ (BOOL)notEmptyOrNull_:(NSString *)str
{
    BOOL emptyStatus = [self emptyOrNull_:str];
    return !emptyStatus;
}

//判断字符个数 汉字两个
+ (NSUInteger)charactersLength_: (NSString *)string
{
  if ([[self class] emptyOrNull_:string]) {
    return 0;
  }
  
  NSUInteger asciiLength = 0;
  for (NSUInteger i = 0; i < string.length; i++) {
    unichar uc = [string characterAtIndex: i];
    asciiLength += isascii(uc) ? 1 : 2;
  }
  NSUInteger unicodeLength = asciiLength;
  return unicodeLength;
}

//时间搓修改
+ (NSString *) msecToFormatTime_:(long) msec
{
  //如果13位，改为10位
  if (msec > 1000000000000) {
    msec = msec / 1000;
  }
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:msec]];
  return currentDateStr;
}

/**
 根据字符串和字体获取宽度（默认不换行）
 
 @param str str description
 @param font font description
 @return 字符串宽度
 */
+ (CGFloat)stringWidth_:(NSString *)str
                  font:(UIFont *)font
{
  CGFloat width = 0;
  
  if (str && str.length > 0 && font) {
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:attributes
                                    context:nil];
    
    width = rect.size.width + 4;
  }
  return width;
}

//返回金额
+ (NSString *) centToYuanString_:(long)cents
{
  return [NSString stringWithFormat:@"%.2f",cents / 100.0f];
}

//返回百分数
+ (NSString *) centToNumString_:(long)cents
{
  return [NSString stringWithFormat:@"%.0f",cents / 100.0f];
}


// 对字符串URLencode编码
- (NSString *)urlEncoding_
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

// 对字符串URLdecode解码
- (NSString *)urlDecoding_
{
    NSString* result = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}


// 对字符串添加url参数
- (NSString *)stringByAddingURLParams_:(NSDictionary *)params
{
    NSString * string           = self;
    
    if (params) {
        NSMutableArray * pairArray  = [NSMutableArray array];
        
        for (NSString * key in params) {
            NSString * value        = [NSString stringWithFormat:@"%@", [params yhObjectForKey_:key] ? : @""];
            NSString * keyEscaped   = [key urlEncoding_];
            NSString * valueEscaped = [value urlEncoding_];
            NSString * pair         = [NSString stringWithFormat:@"%@=%@",keyEscaped,valueEscaped];
            [pairArray addObject:pair];
        }
        
        NSString * query            = [pairArray componentsJoinedByString:@"&"];
        string                      = [NSString stringWithFormat:@"%@?%@",self,query];
    }
    
    return string;
}

//获取url里面的参数
- (NSDictionary *)getURLParams_
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    NSRange range1  = [self rangeOfString:@"?"];
    NSRange range2  = [self rangeOfString:@"#"];
    NSRange range   ;
    if (range1.location != NSNotFound) {
        range = NSMakeRange(range1.location, range1.length);
    }else if (range2.location != NSNotFound){
        range = NSMakeRange(range2.location, range2.length);
    }else{
        range = NSMakeRange(-1, 1);
    }
    
    if (range.location != NSNotFound) {
        NSString * paramString = [self substringFromIndex:range.location+1];
        NSArray * paramCouples = [paramString componentsSeparatedByString:@"&"];
        for (int i = 0; i < [paramCouples count]; i++) {
            NSArray * param = [[paramCouples objectAtIndex:i] componentsSeparatedByString:@"="];
            if ([param count] == 2) {
                [dic setObject:[[param objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[[param objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        return dic;
    }
    return nil;
}

+ (NSString *)printDicJson_:(NSDictionary *)dict
{
    if (!dict) {
        return nil;
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
//        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",jsonString);
    }
    return jsonString;
}

//对象转json
+ (NSString*)DataTOjsonString_:(id)object
{
#if DEBUG
  NSString *jsonString = nil;
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                     options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                       error:&error];
  if (! jsonData) {
    NSLog(@"Got an error: %@", error);
  } else {
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }
  jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
  return jsonString;
#endif
  return object;
}

@end
