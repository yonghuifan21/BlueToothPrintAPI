//
//  WKBridgeWebView.h
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/4.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBPBridgeWebView : WKWebView
@property (nonatomic, copy)NSString*(^fetchThePrintDataStringHandler)(void);

//获取打印数据
- (void)setPrintData: (NSString *)printStr finishPrintBlock: (void(^)(NSDictionary *printDict))result; 

/// 根据打印模板号，版本号，打印数据，组装打印数据
/// @param templateNo <#templateNo description#>
/// @param version <#version description#>
/// @param data <#data description#>
- (void)printTemplateGetPrintTemplateNo: (NSInteger)templateNo version: (NSInteger)version data: (NSString *)data finishPrintBlock: (void(^)(NSDictionary *printDict))result;

@end

NS_ASSUME_NONNULL_END
