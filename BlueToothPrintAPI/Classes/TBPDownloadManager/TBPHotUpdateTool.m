//
//  RNHotUpdateTool.m
//  大文件下载和解压
//
//  Created by 刘冰洋 on 2020/12/28.
//  Copyright © 2020 liuby. All rights reserved.
//

#import "TBPHotUpdateTool.h"
#import <SSZipArchive/SSZipArchive.h>
#import <CommonCrypto/CommonDigest.h>

@interface TBPHotUpdateTool ()
/// 下载和请求json工具类
@property (nonatomic,strong) TBPDowloadTool *downloadTool;

@end
@implementation TBPHotUpdateTool
static TBPHotUpdateTool *downLoadTool;//单例
static dispatch_once_t token;//用于销毁单例


#pragma mark - 根据路径下载zip

/// 根据路径下载zip
/// @param urlstr 请求地址
/// @param success 成功回调，返回路径
/// @param failure 失败回调
- (void)downloadResourcesWithUrlstr:(NSString *)urlstr ResultSuccess:(Success)success Failure:(Failure)failure
{
    [self.downloadTool downloadResourcesWithUrlstr:urlstr ResultSuccess:success Failure:failure];

}

#pragma mark - 下载带进度条
- (void)prodownloadResourcesWithUrlstr:(NSString *)urlString Process:(ProcessBack)processBack Success:(Success)success Failure:(Failure)failure
{
    [self.downloadTool prodownloadResourcesWithUrlstr:urlString Process:processBack Success:success Failure:failure];
}

#pragma mark - get请求
- (void)get:(NSString *)urlString requestBack:(void (^)(NSDictionary * responseDict))success Failure:(Failure)failure
{
    [self.downloadTool get:urlString requestBack:success Failure:failure];
}

#pragma mark - post请求
- (void)post:(NSString *)urlString postBody:(NSDictionary *)body requestBack:(void (^)(NSDictionary * responseDict))success Failure:(Failure)failure
{
    [self.downloadTool post:urlString postBody:body requestBack:success Failure:failure];
}

#pragma mark - zip解压
- (BOOL)unzipWithZipPath:(NSString *)zipPath andDestDir:(nonnull NSString *)destDir
{
    //判断是否有资源路径
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:zipPath];
    if (blHave) {

        //移除目录内原有文件
        if([[NSFileManager defaultManager] fileExistsAtPath:destDir]){
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:destDir] error:nil];
        }else{
            //创建目标路径
            BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:destDir
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:nil];
            if(!success){
                NSLog(@"创建解压目录失败");
                return NO;
            }
        }

        //Caches路径
        //        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        //        NSString *toPath = [NSString stringWithFormat:@"%@/%@",cachesPath,folderName];
                
        //解压
        NSError *err;
        BOOL isSuccess = [SSZipArchive unzipFileAtPath:zipPath toDestination:destDir overwrite:YES password:nil error:&err];
        if (isSuccess) {
            return YES;
        }else{
            NSLog(@"解压失败：%@",err);
        }
    }else{
        NSLog(@"路径不存在");
    }
    return NO;
}

#pragma mark - 获取MD5
- (NSString *)getMd5WithFile:(NSString *)fliePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //保证文件存在
    if( [fileManager fileExistsAtPath:fliePath isDirectory:nil] )
    {
        NSData *data = [NSData dataWithContentsOfFile:fliePath];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];

        // TODO:[answer] ios 13之后方法不安全，不建议用于加密,但可以使用
        CC_MD5( data.bytes, (CC_LONG)data.length, digest );
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        return output;
    }else{
        return @"";
    }
}

#pragma mark - 下载图片
- (void)downloadImageWithUrlstr:(NSString *)urlString  Success:(void(^)(UIImage * _Nullable image))success Failure:(Failure)failure
{
    //url使用utf8解码并转码防止有汉字
    NSString *dowUrlstring = [urlString stringByRemovingPercentEncoding];
    NSString *dowUTF8Urlstring = [dowUrlstring stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:dowUTF8Urlstring]];
        NSError *error = nil;
        [NSData dataWithContentsOfURL:[NSURL URLWithString:dowUTF8Urlstring] options:NSDataReadingMappedIfSafe error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    if (success) {
                        success(image);
                    }
                }else{
                    NSError *errr = [NSError errorWithDomain:@"图片不存在" code:404 userInfo:nil];//i18nExamine_Disable
                    failure(errr);
                }

            }else{
                if (failure) {
                    failure(error);
                }
            }
        });
    });
}



#pragma mark - 懒加载
- (TBPDowloadTool *)downloadTool
{
    if (_downloadTool == nil) {
        _downloadTool = [[TBPDowloadTool alloc]init];
    }
    return _downloadTool;
}
#pragma mark - 单例管理
///单例初始化
+ (instancetype)sharedRNHotUpdateTool{

    dispatch_once(&token, ^{
        if (!downLoadTool) {
            downLoadTool = [[TBPHotUpdateTool alloc]init];

        }
    });
    return downLoadTool;
}

///销毁单例
- (void)resetInstance{
    token = 0;
    downLoadTool =nil;
}
@end
