//
//  RNDowloadTool.m
//  大文件下载和解压
//
//  Created by 刘冰洋 on 2020/12/28.
//  Copyright © 2020 liuby. All rights reserved.
//

#import "TBPDowloadTool.h"
@interface TBPDowloadTool ()<NSURLSessionDelegate>

///展示进度的下载需要的url
@property (nonatomic,copy) NSString *urlString;
///下载进度回调
@property (nonatomic,copy) ProcessBack processBack;
///下载成功回调
@property (nonatomic,copy) Success proSuccess;
///下载失败回调
@property (nonatomic,copy) Failure proFailure;

@end
@implementation TBPDowloadTool

#pragma mark - 根据路径下载zip

/// 根据路径下载zip
/// @param urlstr 请求地址
/// @param success 成功回调，返回路径
/// @param failure 失败回调
- (void)downloadResourcesWithUrlstr:(NSString *)urlstr ResultSuccess:(Success)success Failure:(Failure)failure
{
    //url使用utf8解码并转码防止有汉字
    NSString *dowUrlstring = [urlstr stringByRemovingPercentEncoding];
    NSString *dowUTF8Urlstring = [dowUrlstring stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    //1.创建请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dowUTF8Urlstring]];
    //设置网络超时
    [request setTimeoutInterval:75];
    //2.创建session
    NSURLSession *session = [NSURLSession sharedSession];
    //3.创建Task
    //该方法内部已经实现了边接受数据边写沙盒(tmp)的操作
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }else{
            //3.1 拼接文件全路径 ： 保存在tmp目录下得文件随时都回被删除，因此需要移动文件
            NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
            //判断是否有资源路径
            BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:fullPath];
            if (blHave) {//如果存在先删除
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:fullPath] error:nil];
            }
            //3.2 剪切文件到Caches
            BOOL moveSucces= [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
            if (moveSucces) {
                if (success) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success(fullPath);
                        });
                    }
                }else{
                    if (failure) {
                        NSError *errr = [NSError errorWithDomain:@"拷贝到沙盒失败" code:90901 userInfo:nil];//i18nExamine_Disable
                        if (success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                failure(errr);
                            });
                        }
                    }
                }
            }
        }
    }];
    //4.执行Task
    [downloadTask resume];
}

#pragma mark - post请求
- (void)post:(NSString *)urlString postBody:(NSDictionary *)body requestBack:(void (^)(NSDictionary * _Nonnull))success Failure:(Failure)failure
{
    //url使用utf8解码并转码防止有汉字
    NSString *utf8Urlstring = [[urlString stringByRemovingPercentEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:utf8Urlstring]];
    //请求方式
    [request setHTTPMethod:@"POST"];
    //设置超时
    [request setTimeoutInterval:30];
    //设置请求体
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:NULL];
    [request setHTTPBody:bodyData];
    
    [request setAllHTTPHeaderFields:@{@"Content-Type":@"application/json; charset=utf-8"}];
    
    //2.创建session
    NSURLSession *session = [NSURLSession sharedSession];
    //任务
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failure) {
                    failure(error);
                }
            }else{
                //json数据解析
                NSError *jsonErr;
                NSDictionary *resultDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonErr];
                if (jsonErr) {
                    if (failure) {
                        failure(error);
                    }
                }else{
                    if (success) {
                        success(resultDic);
                    }
                }
            }
        });
    }];
    //开始任务
    [sessionTask resume];
}

#pragma mark - get请求
- (void)get:(NSString *)urlString requestBack:(void (^)(NSDictionary * _Nonnull))success Failure:(Failure)failure
{
    //url使用utf8解码并转码防止有汉字
    NSString *utf8Urlstring = [[urlString stringByRemovingPercentEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:utf8Urlstring]];
    //请求方式
    [request setHTTPMethod:@"GET"];
    //设置超时
    [request setTimeoutInterval:60];
    //2.创建session
    NSURLSession *session = [NSURLSession sharedSession];
    //任务
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failure) {
                    failure(error);
                }
            }else{
                //json数据解析
                NSError *jsonErr;
                NSDictionary *resultDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonErr];
                NSString *responsJson = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                NSLog(@"%@", responsJson);
                if (jsonErr) {
                    if (failure) {
                        failure(error);
                    }
                }else{
                    if (success) {
                        success(resultDic);
                    }
                }
            }
        });
    }];
    //开始任务
    [sessionTask resume];
}

#pragma mark - 下载带进度条
- (void)prodownloadResourcesWithUrlstr:(NSString *)urlString Process:(ProcessBack)processBack Success:(Success)success Failure:(Failure)failure
{
    //url使用utf8解码并转码防止有汉字
    NSString *utf8Urlstring = [[urlString stringByRemovingPercentEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.urlString = utf8Urlstring;
    self.proSuccess = success;
    self.processBack = processBack;
    self.proFailure = failure;
    [self dowloadAndShowProcess];
}

- (void)dowloadAndShowProcess
{
    //这个要创建NSURLSessionConfiguration对象
    NSURLSessionConfiguration *scf = [NSURLSessionConfiguration defaultSessionConfiguration];
    //创建session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:scf delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    //创建一个url
    NSURL *url = [NSURL URLWithString:self.urlString];
    //创建一个任务
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
    //开始任务
    [task resume];
}


#pragma mark 下载展示进度的方法代理
//下载完成调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    
    // location : 临时文件的路径（下载好的文件）
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
    NSString *fullPath = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    //判断是否有资源路径
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    if (blHave) {//如果存在先删除
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:fullPath] error:nil];
    }
    // 将临时文件剪切或者复制Caches文件夹
    NSFileManager *mgr = [NSFileManager defaultManager];
    // AtPath : 剪切前的文件路径
    // ToPath : 剪切后的文件路径
    BOOL moveSucces= [mgr moveItemAtPath:location.path toPath:fullPath error:nil];
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        if (moveSucces) {
            if (self.proSuccess) {
                self.proSuccess(fullPath);
            }
        }else{
            if (self.proFailure) {
                NSError *errr = [NSError errorWithDomain:@"拷贝到沙盒失败" code:90901 userInfo:nil];//i18nExamine_Disable
                self.proFailure(errr);
            }
        }
    });
    
}


//下载过程中调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    double process = (double)totalBytesWritten / totalBytesExpectedToWrite;
    
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.processBack) {
            self.processBack(process);
        }
    });
}
//下载失败回调
//不管下载成功还是失败，都会来到该方法，不过下载失败的话，error有值，下载成功error为null
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            if (self.proFailure) {
                self.proFailure(error);
            }
        }
    });
}

@end
