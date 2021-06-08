//
//  RNCheckVersionTool.m
//  ClassmateUnion
//
//  Created by 刘冰洋(liuby) on 2020/12/7.
//  Copyright © 2020 泽怡. All rights reserved.
//

#import "PrintCheckVersionTool.h"
#import "RNHotUpdateTool.h"
#import "RNDowloadTool.h"
#import "NatvieConfig.h"

//#define UPDATEINFOJSON @"http://localhost:8081/rndownloadtest/rnUpdateTest.json"
//https://static-yh.yonghui.cn/app/esc-pos-parser/version.json
#define UPDATEINFOJSON @"https://static-yh.yonghui.cn/app/esc-pos-parser/version.json"


#define VERSION @"version"
#define URL @"url"
#define iOSCOMPATIBLEVERSION @"iOSCompatibleVersion"
#define DESCRIPTION @"description"
#define IOSBUNDLEZIPMD5 @"zipMD5"

@implementation PrintCheckVersionTool

+ (void)downloadBundle:(void (^)(NSString *bundlePath))resultBlock
{
    
    RNDowloadTool *downloadTool =  [RNDowloadTool new];
    [downloadTool get: UPDATEINFOJSON requestBack:^(NSDictionary * _Nonnull responseDict) {
        NSString *version = [responseDict objectForKey: VERSION];
        NSString *url = [responseDict objectForKey: URL];
        NSString *iosCompatibleVersion = [responseDict objectForKey: iOSCOMPATIBLEVERSION];
        NSString *description = [responseDict objectForKey: DESCRIPTION];
        NSString *ios_bundleMD5 = [responseDict objectForKey: IOSBUNDLEZIPMD5];
        
        PrintCheckVersionTool *vtool = [PrintCheckVersionTool new];
        vtool.version = version;
        vtool.url = url;
        vtool.iOSCompatibleVersion = iosCompatibleVersion;
        vtool.descriptionInfo = description;
        vtool.ios_bundleMD5 = ios_bundleMD5;
        if([self isNeedUpdate: vtool]){
            [NatvieConfig sharedInstance].zipDowMD5 = vtool.ios_bundleMD5;
            [NatvieConfig sharedInstance].h5DownVersion = vtool.version;
            [self downloadWithUrl:vtool.url resultBlock:resultBlock];
        }else{
            resultBlock(@"");
        }
        
    } Failure:^(NSError * _Nullable error) {
        resultBlock(@"");
    }];
    
}

+ (void)downloadWithUrl:(NSString *)urlStr resultBlock:(void (^)(NSString *bundlePath))resultBlock
{
    [[RNHotUpdateTool sharedRNHotUpdateTool] downloadResourcesWithUrlstr:urlStr ResultSuccess:^(NSString * _Nullable loadpath) {
        
        // 校验MD5
        NSString *dowMD5 = [[RNHotUpdateTool sharedRNHotUpdateTool] getMd5WithFlie:loadpath];
        if (![dowMD5 isEqualToString:[NatvieConfig sharedInstance].zipDowMD5]) {
            resultBlock(@"");
            return;
        }
        
        //解压到缓存中
        NSString *destDir = [NSString stringWithFormat:@"%@/%@/%@",DOCUMENTPATH ,PTBaseHtmlFolder,[NatvieConfig sharedInstance].h5DownVersion];
        // 删除多余文件夹
        [self removeRNDir];
        if ([[RNHotUpdateTool sharedRNHotUpdateTool] unzipWithZipPath:loadpath andDestDir:destDir]) {
            // 删除多余文件夹
            [self removeRNDir];
            // 获取本地路径  doc/版本号/bundle文件
            NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",DOCUMENTPATH ,PTBasePath([NatvieConfig sharedInstance].h5DownVersion)];
            // 储存版本号和MD5到本地
            ZYSetValueToUserDefaults(ZIPMD5KEY, [NatvieConfig sharedInstance].zipDowMD5);
            ZYSetValueToUserDefaults(H5VERSIONKEY, [NatvieConfig sharedInstance].h5DownVersion);
            // 返回解压后的路径
            resultBlock(bundlePath);
        }else{
            resultBlock(@"");
        }
   } Failure:^(NSError * _Nullable error) {
       resultBlock(@"");
   }];
}

+ (BOOL)isNeedUpdate:(PrintCheckVersionTool *)rnvTool
{
    //先判断SDK版本, 如果sdk版本低，则不能更新
    if([self compareIsNeedUpWithCurVersion:[NatvieConfig sharedInstance].sdkVersion NetVersion: rnvTool.iOSCompatibleVersion]){
        return NO;
    }
    // 比较版本号
    if ([self compareIsNeedUpWithCurVersion:[NatvieConfig sharedInstance].h5Version NetVersion:rnvTool.version]) {
        return YES;
    }
    return NO;
}


///比较版本
+ (BOOL)compareIsNeedUpWithCurVersion:(NSString *)curVersion  NetVersion:(NSString *)netVersion
{
    
    NSArray *curArray = [curVersion componentsSeparatedByString:@"."];
    NSArray *netArray = [netVersion componentsSeparatedByString:@"."];
    NSInteger curvlue = 0;
    NSInteger netvlue = 0;
    
    NSInteger maxScale = 1;
    NSInteger maxCount = (curArray.count > netArray.count) ? curArray.count : netArray.count;
    
    for (int index = 0; index < maxCount; index++) {
        maxScale = maxScale*100;
        if (curArray.count > index) {
            curvlue = curvlue + [curArray[curArray.count - index - 1] integerValue]*maxScale;
        }
        if (netArray.count > index) {
            netvlue = netvlue + [netArray[netArray.count - index - 1] integerValue]*maxScale;
        }
        
    }
    
    return (netvlue > curvlue);
}


#pragma mark - 删除多余的RN文件夹
+ (void)removeRNDir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获取文件夹中所有文件
    NSString *superFolder = [NSString stringWithFormat:@"%@/%@",DOCUMENTPATH ,PTBaseHtmlFolder];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:superFolder error:nil];
    
    NSMutableArray *dirArray= [[NSMutableArray alloc] init];

    BOOL isDir=NO;
    //在上面那段程序中获得的fileList中列出文件夹名
    for (NSString *file in fileList) {
        NSString *path= [superFolder stringByAppendingPathComponent:file];
        [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
        if (isDir) {
            [dirArray addObject:path];
        }
        isDir=NO;
    }
    
    if (dirArray.count > zyKeepRNCount) {
        // 保留数组最后俩个
        [dirArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ((dirArray.count - idx) > zyKeepRNCount) {
                if([[NSFileManager defaultManager] fileExistsAtPath:obj]){
                    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:obj] error:nil];
                }
            }
        }];
    }
}


//+ (NSString *)getRNJsonUrl
//{
//
//
//    NSString *timeStamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970])];
//    return [NSString stringWithFormat:@"%@?%@",rnJsonUrl,timeStamp];
//
//}


#pragma mark - 给下载url增加时间戳
- (NSString *)iosBundlePath
{
    NSString *timeStamp = [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970])];
    return [NSString stringWithFormat:@"%@?%@",_url,timeStamp];
    return @"";
}
@end

