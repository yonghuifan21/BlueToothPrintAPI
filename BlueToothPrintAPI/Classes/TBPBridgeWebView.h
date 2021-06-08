//
//  WKBridgeWebView.h
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/4.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBPBridgeWebView : WKWebView
@property (nonatomic, copy)NSString*(^fetchThePrintDataStringHandler)(void); //获取打印数据
- (void)setPrintData: (NSString *)printStr finishPrintBlock: (void(^)(BOOL success, NSString *message))result; //打印结果

@end

NS_ASSUME_NONNULL_END
