//
//  RNDowloadTool.h
//  大文件下载和解压
//
//  Created by 刘冰洋 on 2020/12/28.
//  Copyright © 2020 liuby. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Success)(NSString * _Nullable loadpath);
typedef void(^Failure)(NSError * _Nullable error);
typedef void(^ProcessBack)(double process);

NS_ASSUME_NONNULL_BEGIN

@interface TBPDowloadTool : NSObject

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

- (void)post:(NSString *)urlString postBody:(NSDictionary *)body requestBack:(void (^)(NSDictionary * _Nonnull))success Failure:(Failure)failure;

@end

NS_ASSUME_NONNULL_END
