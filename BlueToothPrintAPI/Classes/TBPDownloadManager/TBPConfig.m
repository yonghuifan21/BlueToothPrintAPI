 //  RNConfig.m
//
//  jiahui_health
//
//  Created by 刘冰洋(liuby) on 2020/3/31.
//  Copyright © 2020 刘冰洋. All rights reserved.
//

#import "TBPConfig.h"
//#import "ZYCommonTools.h"
#import <SSZipArchive/SSZipArchive.h>
#import "TBPHotUpdateTool.h"
#import "NSObject+Add.h"

#define SDKVERSION @"0.1.0"

#define H5PRINTVERSION @"0.0.1"

//#define DOWNLOADPATH @"https://static-yh.yonghui.cn/app/esc-pos-parser/version.json"

@implementation TBPConfig

+ (instancetype)sharedInstance {
    static TBPConfig *rnConfig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!rnConfig) {
            rnConfig = [[TBPConfig alloc] init];
            rnConfig.sdkVersion = SDKVERSION;
            rnConfig.debugEnable = YES;
        }
    });
    return rnConfig;
}
//获取bundle离线路径
- (NSString *)h5BundlePath {
    if (_h5BundlePath == nil) {
        // 离线包
        NSString *offBundlePath = [self getOfflineBundlePath];
        // 判断文件是否存在
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:offBundlePath];
        if (!blHave) {
            offBundlePath = nil;
        }
        _h5BundlePath = offBundlePath;
        
    }
    return _h5BundlePath;
}

/// 打印的域名
- (NSString *)printDataURL{
    return @"http://cp-kptxpdy-prod.printer-server.apis.yonghui.cn";
}


#pragma mark - 切换RN路径


#pragma mark - 获取本地路径  doc/版本号/bundle文件
- (NSString *)getOfflineBundlePath
{
    // 获取本地路径  doc/版本号/bundle文件
//    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",DOCUMENTPATH ,PTBasePath(self.h5Version)];
    NSString *bundlePath = [self getBundlePathForDownload:self.h5Version];
    // 判断文件是否存在
    BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath];

    if (blHave) {
        return bundlePath;
    } else {
        // 去查询APP内有没有index.html
        // 1.获取jsbundle路径
//        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"BlueToothPrintAPI" withExtension:@"bundle"];
        NSBundle *bundle = [NSBundle bundleForClass: [self class]];
        NSURL *bundleUrl = [bundle URLForResource:@"BlueToothPrintAPI" withExtension:@"bundle"];
        bundle = [NSBundle bundleWithURL: bundleUrl];
        NSString *tempBundlePath = [bundle pathForResource:HTMLNAME ofType: HTMLTYPE];
        return tempBundlePath;
    }
}

//根据版本号，获取对应的index.html文件
- (NSString *)getBundlePathForDownload: (NSString *)version{
    // 获取本地路径  doc/版本号/bundle文件
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@/%@",DOCUMENTPATH, PTBaseHtmlFolder,(version)];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSArray *subPaths = [filemanager subpathsAtPath: bundlePath];
    if(subPaths.count > 0){
        bundlePath = [bundlePath stringByAppendingPathComponent: [NSString stringWithFormat:@"%@/%@", subPaths[0], PTBaseHtmlName]];
    }
    return bundlePath;
}

#pragma mark - 设置默认RN版本号
- (NSString *)h5Version
{
    if (_h5Version == nil) {
        NSString *rnVersion = ZYGetValueForUserDefaults(H5VERSIONKEY);
        if (![rnVersion isExist]) {
            if (![rnVersion isExist]) {
                _h5Version = H5PRINTVERSION;
                ZYSetValueToUserDefaults(H5VERSIONKEY, _h5Version);
            }
        }else{
            _h5Version = rnVersion;
        }
    }
    return _h5Version;
}

- (NSString *)zipMD5
{
    if (_zipMD5 == nil) {
        NSString *zipMD5 = ZYGetValueForUserDefaults(ZIPMD5KEY);
        _zipMD5 = zipMD5;
    }
    return _zipMD5;
}
@end
