//
//  RNCheckVersionTool.h
//  ClassmateUnion
//
//  Created by 刘冰洋(liuby) on 2020/12/7.
//  Copyright © 2020 泽怡. All rights reserved.
//

#define zyKeepRNCount 2

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TBPCheckVersionTool : NSObject


/// 版本号
@property (nonatomic,copy) NSString *version;

/// 下载路径
@property (nonatomic,copy) NSString *url;

/// 兼容的iOS版本号
@property (nonatomic,copy) NSString *iOSCompatibleVersion;
/// 描述文案
@property (nonatomic,copy) NSString *descriptionInfo;
/// ios的MD5
@property (nonatomic,copy) NSString *ios_bundleMD5;




+ (void)downloadH5Info:(void (^)(NSString *bundlePath))resultBlock;
@end

NS_ASSUME_NONNULL_END
