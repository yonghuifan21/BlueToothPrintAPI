 //  RNConfig.m
//
//  jiahui_health
//
//  Created by 刘冰洋(liuby) on 2020/3/31.
//  Copyright © 2020 刘冰洋. All rights reserved.
//

#import "NatvieConfig.h"
//#import "ZYCommonTools.h"
#import <SSZipArchive/SSZipArchive.h>
#import "RNHotUpdateTool.h"
#import "NSObject+Add.h"

#define SDKVERSION @"0.0.1"

#define H5PRINTVERSION @"0.0.1"

//#define DOWNLOADPATH @"https://static-yh.yonghui.cn/app/esc-pos-parser/version.json"

@implementation NatvieConfig

+ (instancetype)sharedInstance {
    static NatvieConfig *rnConfig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!rnConfig) {
            rnConfig = [[NatvieConfig alloc] init];
            rnConfig.sdkVersion = SDKVERSION;
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
////获取bundle离线路径
//- (NSString *)bunldPath {
//    if (_bunldPath == nil) {
//        //获取本地ip
//        NSString *rn_tempip = ZYGetValueForUserDefaults (@"rn_tempip");
//        if([rn_tempip isExist]) {
//            _bunldPath = [NSString stringWithFormat:@"http://%@:8081/index.bundle?platform=ios",rn_tempip];
//        }else{
//            _bunldPath = @"http://localhost:8081/index.bundle?platform=ios";
//        }
//        // 离线包
//        NSString *offBundlePath = [self getOfflineBundlePath];
//        // 判断文件是否存在
//        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:offBundlePath];
//        if (!blHave) {
//            offBundlePath = nil;
//        }
//
//#if TARGET_IPHONE_SIMULATOR
//        return _bunldPath;
//#else
//#ifdef DEBUG
//        // DEBUG 存在ip 返回离线,不存在ip,获取本地路径
//        if(![rn_tempip isExist]) {
//            _bunldPath = offBundlePath;
//        }
//#else
//        _bunldPath = offBundlePath;
//#endif
//#endif
//    }
//        return _bunldPath;
//}

#pragma mark - 切换RN路径

//// 忽略国际化
//- (void)switchRNbundlePath {
//    UIAlertController *rnPathAlert = [UIAlertController alertControllerWithTitle:@"RN路径选择" message:@"默认使用app沙盒路径" preferredStyle:UIAlertControllerStyleActionSheet];//i18nExamine_Disable
//
//    [rnPathAlert addAction:[UIAlertAction actionWithTitle:@"本地服务调试" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {//i18nExamine_Disable
//        [self setupServBundlePath];
//    }]];
//
//    [rnPathAlert addAction:[UIAlertAction actionWithTitle:@"离线加载（本地包）" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {//i18nExamine_Disable
//        [self setupOfflineBundlePath];
//    }]];
//    [rnPathAlert addAction:[UIAlertAction actionWithTitle:@"获取测试最新包（本地包）" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {//i18nExamine_Disable
//        [ZYToastTools showToastWithMessage:@"暂不支持"];//i18nExamine_Disable
//    }]];
//    [rnPathAlert addAction:[UIAlertAction actionWithTitle:@"获取生产最新包（本地包）" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {//i18nExamine_Disable
//        [ZYToastTools showToastWithMessage:@"暂不支持"];//i18nExamine_Disable
//    }]];
//    [rnPathAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];//i18nExamine_Disable
//
//    UIViewController *vc = ZYgetCurViewController();
//    [vc presentViewController:rnPathAlert animated:YES completion:nil];
//}

/////本地服务
//- (void)setupServBundlePath {
//#if !TARGET_IPHONE_SIMULATOR
//    //获取本地ip
//    NSString *rn_tempip = ZYGetValueForUserDefaults (@"rn_tempip");
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入服务IP" message:nil preferredStyle:UIAlertControllerStyleAlert];//i18nExamine_Disable
//
//    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField){
//        if (rn_tempip.length > 0) {
//            textField.placeholder = nil;
//            textField.text = rn_tempip;
//        }else{
//            textField.placeholder = @"请输入ip如（192.168.31.21)"; //i18nExamine_Disable
//        }
//        textField.keyboardType = UIKeyboardTypeDecimalPad;
//    }];
//    //添加一个确定按钮 并获取AlertView中的第一个输入框 将其文本赋值给BUTTON的title
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {//i18nExamine_Disable
//        //储存ip
//        UITextField *envirnmentNameTextField = alert.textFields.firstObject;
//        ZYSetValueToUserDefaults(@"rn_tempip", envirnmentNameTextField.text);
//        //跳转
//        NSString *tempUrl = [NSString stringWithFormat:@"http://%@:8081/index.bundle?platform=ios",envirnmentNameTextField.text];
//
//        self.bunldPath = tempUrl;
//        //在这重新加载根视图
//        [ZYCommonTools restKeyWindow:0];
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];//i18nExamine_Disable
//    //弹出提示框；
//    [ZYgetCurViewController() presentViewController:alert animated:true completion:nil];
//#else
//    self.bunldPath = @"http://localhost:8081/index.bundle?platform=ios";
//    //在这重新加载根视图
//    [ZYCommonTools restKeyWindow:0];
//#endif
//}

//- (void)setupOfflineBundlePath {
//
//    // 获取本地路径
//    NSString *bundlePath = [self getOfflineBundlePath];
//    // 判断文件是否存在
//    BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath];
//    if (blHave) {
//        self.bunldPath = bundlePath;
//        //在这重新加载根视图
////        [ZYCommonTools restKeyWindow:0];
//    } else {
////        [ZYToastTools showToastWithMessage:@"没有发现RN离线包,无法切换加载路径"]; //i18nExamine_Disable
//    }
//}

#pragma mark - 获取本地路径  doc/版本号/bundle文件
- (NSString *)getOfflineBundlePath
{
    // 获取本地路径  doc/版本号/bundle文件
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",DOCUMENTPATH ,PTBasePath(self.h5Version)];
    // 判断文件是否存在
    BOOL blHave = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath];

    if (blHave) {
        return bundlePath;
    } else {
        // 去查询APP内有没有index.html
        // 1.获取jsbundle路径
        NSString *tempBundlePath = [[NSBundle mainBundle] pathForResource:HTMLNAME ofType: HTMLTYPE];
        return tempBundlePath;
    }
}

#pragma mark - 设置默认RN版本号
- (NSString *)h5Version
{
    if (_h5Version == nil) {
        NSString *rnVersion = ZYGetValueForUserDefaults(H5VERSIONKEY);
        if (![rnVersion isExist]) {
            if (![rnVersion isExist]) {
                _h5Version = H5PRINTVERSION;
                ZYSetValueToUserDefaults(H5VERSIONKEY, H5PRINTVERSION);
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
