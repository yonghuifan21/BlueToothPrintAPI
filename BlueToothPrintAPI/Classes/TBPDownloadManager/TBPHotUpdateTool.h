//
//  RNHotUpdateTool.h
//  大文件下载和解压
//
//  Created by 刘冰洋 on 2020/12/28.
//  Copyright © 2020 liuby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBPDowloadTool.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBPHotUpdateTool : NSObject


/// 根据路径下载zip，无进度显示
/// @param urlstr 请求地址
/// @param success 成功回调，返回路径
/// @param failure 失败回调
- (void)downloadResourcesWithUrlstr:(NSString *)urlstr ResultSuccess:(Success)success Failure:(Failure)failure;


/// 根据路径下载zip，有进度显示
/// @param urlString 请求地址
/// @param processBack 进度显示
/// @param success 成功回调，返回路径
/// @param failure 失败回调
- (void)prodownloadResourcesWithUrlstr:(NSString *)urlString Process:(ProcessBack)processBack Success:(Success)success Failure:(Failure)failure;


/// get获取远端的json
/// @param urlString 远端url
/// @param success 返回，失败返回空字符串
/// @param failure 失败回调
- (void )get:(NSString *)urlString requestBack:(void (^)(NSDictionary *responseDict))success Failure:(Failure)failure;

- (void)post:(NSString *)urlString postBody:(NSDictionary *)body requestBack:(void (^)(NSDictionary * responseDict))success Failure:(Failure)failure;

/// 解压zip文件,解压成功返回路径失败返回空字符串
/// @param zipPath 需要解压的文件路径
- (BOOL)unzipWithZipPath:(NSString *)zipPath andDestDir:(nonnull NSString *)destDir;


/// 根据文件路径获取文件的md5
/// @param fliePath 文件全路径
- (NSString *)getMd5WithFile:(NSString *)fliePath;

/// 根据URL下载图片
/// @param urlString 请求地址
/// @param success 成功回调，返回UIImage
/// @param failure 失败回调
- (void)downloadImageWithUrlstr:(NSString *)urlString  Success:(void(^)(UIImage * _Nullable image))success Failure:(Failure)failure;

///RNBridgeManager单例
+ (instancetype)sharedRNHotUpdateTool;
///销毁单例
- (void)resetInstance;


@end


NS_ASSUME_NONNULL_END
