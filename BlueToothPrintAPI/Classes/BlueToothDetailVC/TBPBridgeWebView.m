//
//  WKBridgeWebView.m
//  WebViewBlueToothDemo
//
//  Created by 范国徽 Jack on 2021/6/4.
//

#import "TBPBridgeWebView.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import "TBPBlueToothManager.h"
#import "TBPCheckVersionTool.h"
#import "TBPConfig.h"
#import "TBPBlueToothCoconut.h"
#import "TBPDowloadTool.h"



#define TRANSFORMSTR @"transform"

#define JSTRANSFORMSTR @"transform"
//testJavascriptHandler
//#define JSTRANSFORMSTR @"testJavascriptHandler"
//打印数据转换
#define REPRET @"ret"
#define REPSUCCESS @"success"
#define REPFAILED @"failed"
//错误信息
#define REPMESSAGE @"message"
//数据
#define REPDATA @"data"

//html link
#define HTMLNAME @"index"
#define HTMLTYPE @"html"
#define DELAYSECONDS 1.5


#define PRINTSUCCESS 200000 //打印成功

#define TEMPLATEERROR 600000 //打印模板数据转换出错

#define TANSFORMCOMMANDERROR 700000 //打印指令转换出错

#define BLUEPRINTERROR 800000 //打印出错

#define PRINTSUCCESSINFO @"打印成功"

#define PRINTSDKRESULT(code, message) @{@"code": @(code), @"message": message}


@interface TBPBridgeWebView()<WKNavigationDelegate>

@property (nonatomic, strong)WKWebView *webview;

@property (nonatomic, strong)WebViewJavascriptBridge *bridge;

// 打印成功或者失败的回调
@property (nonatomic, copy)void(^finishPrintHandler)(BOOL success, NSString *message);

//是否加载过html文件
@property (nonatomic, assign)BOOL isLoadHtml;

@end

@implementation TBPBridgeWebView

#pragma mark ============================ Initialize UI ============================
- (WKWebView *)webview{
    if(nil == _webview){
        _webview = [[WKWebView alloc] initWithFrame: self.bounds];
        _webview.navigationDelegate = self;
        [self addSubview: _webview];
        [WebViewJavascriptBridge enableLogging];
        _bridge = [WebViewJavascriptBridge bridgeForWebView: _webview];
        [_bridge setWebViewDelegate: self];
        
    }
    
    return _webview;
}

#pragma mark ============================ Set UI ============================

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

//初始化
- (void)setUI{
//    [self addSubview: self.webview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAYSECONDS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[TBPBlueToothManager shareInstance] startScan];
        [[TBPBlueToothManager shareInstance] searchPeripheralsBlock: nil];
    });

}

//布局子视图
- (void)layoutSubviews{
    [super layoutSubviews];
    if(self.isLoadHtml){
        return;
    }
    [self loadLocalHtml];
    [self checkPrintVersion];
    //    if(!self.isLoadHtml){
//        [self loadLocalHtml];
//    }
//    [self setConstraint];
//    [self loadLocalHtml];
    

}

#pragma mark ============================ Layout Constant ============================


/// 添加约束
- (void)setConstraint{
    self.webview.frame = self.bounds;
}

#pragma mark ============================ WKNavigationDelegate ============================

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"webViewDidFinishLoad");
   
}

#pragma mark ============================ Data Combina ============================

//获取打印数据，然后通过桥接传给js，转换成打印指令之后进行打印, 成功或者失败之后会有回调
- (void)setPrintData: (NSString *)printStr finishPrintBlock: (void(^)(NSDictionary *printDict))result; {
    NSString *printJSONStr = printStr;
    if(printJSONStr && printJSONStr.length > 0) {
        __weak typeof(self) weakSelf = self;
        //调用js方法，转成打印指令
        [self.bridge callHandler: JSTRANSFORMSTR data: printJSONStr responseCallback:^(id responseData) {
            NSLog(@"responseData====%@", responseData);
            NSString *respStr = (NSString *)responseData;
            [weakSelf dataCompileWith: respStr finishPrintBlock: result];
        }];
    }
}
#pragma mark ============================ Method/Action ============================
//判断是否连接蓝牙
- (BOOL)checkPertheralConnect{
   NSNumber *connectState = [TBPBlueToothCoconut shareInstance].connectState;
   return connectState.boolValue;
}
// 打印数据解析
- (void)dataCompileWith: (NSString *)responseData finishPrintBlock: (void(^)(NSDictionary *printDict))result{
    NSString *errorStr = @"打印指令转换失败";
    NSInteger errorCode = TANSFORMCOMMANDERROR;
    if(responseData && [responseData isKindOfClass:[NSString class]]){ //数据转换
        
        //JSON 解析
        NSString *resAllStr = (NSString *)responseData;
        NSData *responseData = [resAllStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary *reponseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        
        if(!reponseDict){
            [self handlerRevertWith:errorCode message: errorStr finishPrintBlock: result];
            return;
        }
        // 数据转换
        NSString *resResult = reponseDict[REPRET]; //数据转换成功
        NSString *responStr = reponseDict[REPDATA]; //打印指令
        NSString *responMessage = reponseDict[REPMESSAGE]; //错误信息
        
        if([resResult isEqualToString: REPSUCCESS] && [responStr isKindOfClass:[NSString class]]){ //数据转换成功
    
            //获取打印数据
            NSData *base64Data = [[NSData alloc] initWithBase64EncodedString: responStr options: NSDataBase64DecodingIgnoreUnknownCharacters];
            NSData *printData = [[NSData alloc] initWithData: base64Data];
            if(printData){
                [self blueToothPrintData:printData finishPrintBlock: result];
            }else{
                [self handlerRevertWith:errorCode message:errorStr finishPrintBlock: result];
            }
            
        }else{ //转换失败
            [self handlerRevertWith:errorCode message:responMessage finishPrintBlock: result];
        }
    }
}

//打印出错
- (void)blueToothPrintData: (NSData *)data finishPrintBlock: (void(^)(NSDictionary *printDict))result{
    //先检测蓝牙是否连接
    BOOL connect = [self checkPertheralConnect];
    if(!connect){
        [self handlerRevertWith:BLUEPRINTERROR message:@"没有连接打印机" finishPrintBlock: result];
        return;
    }
    
    [[TBPBlueToothManager shareInstance] printDataWith: data];
    [self handlerRevertWith:PRINTSUCCESS message: @"打印成功" finishPrintBlock: result];
}

//数据回调
- (void)handlerRevertWith: (NSInteger)code message: (NSString *)message finishPrintBlock: (void(^)(NSDictionary *printDict))result; {
    if(!result){
        return;
    }
    if(code == PRINTSUCCESS){
        result(PRINTSDKRESULT(PRINTSUCCESS, PRINTSUCCESSINFO));
    }else{
        result(PRINTSDKRESULT(code, message));
    }
}

//加载html文件
- (void)loadHtmlWith: (NSString *)htmlBundlePath{
    if(self.isLoadHtml){
        return;
    }
//    NSString *htmlBundlePath1 = [[NSBundle mainBundle] pathForResource: HTMLNAME ofType: HTMLTYPE];
    NSString *appHtml = [NSString stringWithContentsOfFile: htmlBundlePath encoding: NSUTF8StringEncoding error: nil];
    NSURL *baseURL = [NSURL fileURLWithPath: htmlBundlePath];
    [self.webview loadHTMLString:appHtml baseURL: baseURL];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.21.138:8000/?eruda=true"]];
//    [self.webview loadRequest: urlRequest];
    self.isLoadHtml = YES;

}

//加载html
- (void)loadLocalHtml{
    NSString *bundlePath = [TBPConfig sharedInstance].h5BundlePath;
    [self loadHtmlWith: bundlePath];
}

//检测打印HTML和JS,如果有新版本需要下载，然后重新加载H5页面
- (void)checkPrintVersion{
    [TBPCheckVersionTool downloadH5Info:^(NSString * _Nonnull bundlePath) {
        //检查是否需要更新，更新需要清空缓存
        if(bundlePath && bundlePath.length > 0){
            [TBPConfig sharedInstance].h5BundlePath = bundlePath;
        }
    }];
}

#pragma mark ============================ Other ============================

/// 根据打印模板号，版本号，打印数据，组装打印数据
/// @param templateNo <#templateNo description#>
/// @param version <#version description#>
/// @param data <#data description#>
- (void)printTemplateGetPrintTemplateNo: (NSInteger)templateNo version: (NSInteger)version data: (NSString *)data finishPrintBlock:(nonnull void (^)(NSDictionary * _Nonnull))result{
    
    NSString *errorStr = @"打印模板数据转换出错";
    NSInteger errorCode = TEMPLATEERROR;
    
    if(data && [data length] > 0){
    }else{
        [self handlerRevertWith:errorCode message: errorStr finishPrintBlock: result];
        NSAssert(false, @"数据不能为空");
    }
   TBPDowloadTool *postTool =  [[TBPDowloadTool alloc] init];
   NSString *downloadUrl = [TBPConfig sharedInstance].printDataURL;
   downloadUrl = [downloadUrl stringByAppendingPathComponent:@"printTemplate/getPrintData"];
    __weak typeof(self) weakSelf = self;
    [postTool post:downloadUrl postBody:@{@"templateNo": @(templateNo), @"version": @(version), @"data": data} requestBack:^(NSDictionary * _Nonnull reponse) {
        NSInteger code = [reponse[@"code"] integerValue];
        NSString *message = [reponse[@"message"] stringValue];
        NSString *resultRes = [reponse[@"result"] stringValue];
        if(code == PRINTSUCCESS){
            [weakSelf setPrintData:resultRes finishPrintBlock: result];
        }else{
            if(!message){
                message = errorStr;
            }
            [self handlerRevertWith:errorCode message: message finishPrintBlock: result];
        }
        
    } Failure:^(NSError * _Nullable error) {
        [self handlerRevertWith:errorCode message: errorStr finishPrintBlock: result];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
