//
//  RNConfig.h
//  jiahui_health
//
//  Created by 刘冰洋(liuby) on 2020/3/31.
//  Copyright © 2020 刘冰洋. All rights reserved.
//

//沙河路径
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

//html link
#define HTMLNAME @"index"
#define HTMLTYPE @"html"

#define H5VERSIONKEY @"H5Version"
#define ZIPMD5KEY @"ziph5MD5"

#define PTBaseHtmlName  [NSString stringWithFormat:@"%@.%@",HTMLNAME,HTMLTYPE]

#define PTBaseHtmlFolder @"NPrint"

#define PTBasePath(version) [NSString stringWithFormat:@"%@/%@/%@",PTBaseHtmlFolder,(version),PTBaseHtmlName]

//缓存
#define USERDEFAULT [NSUserDefaults standardUserDefaults]

#define ZYSetValueToUserDefaults(key, value) [USERDEFAULT setValue:value forKey: key]; \
[USERDEFAULT synchronize]; \

#define ZYGetValueForUserDefaults(key) [USERDEFAULT objectForKey: key]

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBPConfig : NSObject


/// 先判断是否有下载包，然后没有取初始化的目录
@property (nonatomic,copy) NSString *h5BundlePath;
/// 本地版本号
@property (nonatomic,copy) NSString *h5Version;
///  本地包MD5
@property (nonatomic,copy) NSString *zipMD5;

/// 服务端最新版本号
@property (nonatomic,copy) NSString *h5DownVersion;
/// 服务端最新包MD5
@property (nonatomic,copy) NSString *zipDowMD5;

//SDK Version
@property (nonatomic,copy) NSString *sdkVersion;

//开启Debug模式, debug模式开启，打印日志
@property (nonatomic,assign) BOOL debugEnable;

///RNBridgeManager单例
+ (instancetype)sharedInstance;

//根据版本号，获取对应的index.html文件
- (NSString *)getBundlePathForDownload: (NSString *)version;

- (NSString *)printDataURL;

@end

NS_ASSUME_NONNULL_END


