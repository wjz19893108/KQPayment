//
//  KQBOmsTool.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/15.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQPOmsMacro.h"

@class KQBOmsTabModel;

@interface KQPOmsTool : NSObject

+ (void)downloadResZipFrom:(NSString *)url
                    toFile:(NSString *)filePath
              successBlock:(DownloadSuccessBlock)block
               failedBlock:(DownloadFailedBlock)failedBlock;

////////// 删除
+ (BOOL)verifyTabRes:(NSArray *)resArr;

+ (void)downloadTabImage:(KQBOmsTabModel *)tabModel;
//////////


/// 截取文件名
+ (NSString *)resName:(NSString *)resUrl;

/// 截取文件夹名称
+ (NSString *)resDirectory:(NSString *)resUrl;

+ (void)deleteDisableFiles:(NSDictionary *)fileDic;

+ (NSString *)calcStrMD5:(NSString *)jsonFilePath;
@end
