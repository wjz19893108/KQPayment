//
//  KQBOmsTool.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/15.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQPOmsTool.h"
#import "KQPOmsManager.h"
#import "KQBOmsTabModel.h"
#import "KQBOmsConfigData.h"

@implementation KQPOmsTool

+ (void)downloadResZipFrom:(NSString *)url toFile:(NSString *)filePath
              successBlock:(DownloadSuccessBlock)block
               failedBlock:(DownloadFailedBlock)failedBlock{
    [KQHttpService downloadFileFrom:url toFile:filePath successBlock:^(NSString *responseStr, NSData *responseData) {
        if(![KQBFileEngine unZipFile:filePath to:[[filePath componentsSeparatedByString:@"."] firstObject]]){
            if (failedBlock) {
                failedBlock(KQOmsResStatusUnzipeFailed);
            }
            return;
        }
        if (block) {
            block();
        }
    } failBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(KQOmsResStatusDownloadFailed);
        }
    }];
}

+ (BOOL)verifyTabRes:(NSArray *)resArr {
    __block BOOL result = YES;
    [resArr enumerateObjectsUsingBlock:^(KQBOmsTabModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.selectedItem.image || !obj.unselectedItem.image ) {
            //去下载资源
            [self downloadTabImage:obj];
            result = NO;
            return;
        }
    }];
    if (resArr.count <= 0) {
        result = NO;
    }
    return result;
}

+ (void)downloadTabImage:(KQBOmsTabModel *)tabModel {
    if (!tabModel.selectedItem.image) {
        NSString *imagePath =  KQC_FORMAT(@"%@/%@%@", [KQBCacheManager directoryPath:KQCahceTypeUserOms], tabModel.selectedItem.iconHome, tabModel.selectedItem.iconDiretory);
        [KQHttpService downloadFileFrom:tabModel.selectedItem.iconUrl toFile:imagePath successBlock:^(NSString *responseStr, NSData *responseData) {
        } failBlock:^(NSError *error) {
        }];
    }
    
    
    if (!tabModel.unselectedItem.image) {
        NSString *imagePath =  KQC_FORMAT(@"%@/%@%@", [KQBCacheManager directoryPath:KQCahceTypeUserOms], tabModel.unselectedItem.iconHome, tabModel.unselectedItem.iconDiretory);
        
        [KQHttpService downloadFileFrom:tabModel.selectedItem.iconUrl toFile:imagePath successBlock:^(NSString *responseStr, NSData *responseData) {
        } failBlock:^(NSError *error) {
        }];
    }
    return;
}

/// 截取文件名
+ (NSString *)resName:(NSString *)resUrl{
    if (!resUrl) {
        return @"";
    }
    NSArray *nameArray = [resUrl componentsSeparatedByString:@"/"];
    if ([nameArray count] > 0) {
        return [nameArray lastObject];
    }
    return @"";
}

/// 截取文件夹名称
+ (NSString *)resDirectory:(NSString *)resUrl{
    NSString *resName = [self resName:resUrl];
    return [resName stringByDeletingPathExtension];
}

+ (void)deleteDisableFiles:(NSDictionary *)fileDic{
    // 异步删除，防止卡主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fileDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, KQBOmsConfigData *obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[KQBOmsConfigData class]]) {
                NSString *fileName = [KQPOmsTool resName:obj.resourceUrl];
                [KQBCacheManager removeCacheFile:fileName cacheType:KQCahceTypeUserOms];
                [KQBCacheManager removeDirectory:obj.resourceDirectory cacheType:KQCahceTypeUserOms];
            }
        }];
    });
}

+ (NSString *)calcStrMD5:(NSString *)jsonFilePath{
    if (!jsonFilePath) {
        return nil;
    }
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:NSDataReadingMappedIfSafe error:nil];
    if (!jsonData) {
        return nil;
    }
    
    NSString *srcStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *MD5Value = [KQCSecure stringFromMD5:srcStr];
    return MD5Value;
}
@end
