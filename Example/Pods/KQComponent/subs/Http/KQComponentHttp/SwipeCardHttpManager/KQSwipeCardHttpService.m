//
//  KQSwipeCardHttpService.m
//  KQBusiness
//
//  Created by building wang on 2018/9/18.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "KQSwipeCardHttpService.h"
#import "KQSwipeCardHttpManager.h"
#import "KQHttpSwipeCardRequestData.h"
#import "KQHttpManager.h"

@implementation KQSwipeCardHttpService

+ (void)request:(NSDictionary *)requestDic bizCode:(NSString *)bizCode successBlock:(KQNetworkSuccessBlock)successBlock{
    [KQSwipeCardHttpService request:requestDic bizCode:bizCode successBlock:successBlock showWaitMode:KQHttpServiceWaitingViewModeShowTop];
}

+ (void)request:(NSDictionary *)requestDic bizCode:(NSString *)bizCode successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock{
    [KQSwipeCardHttpService request:requestDic bizCode:bizCode successBlock:successBlock failedBlock:failedBlock showWaitMode:KQHttpServiceWaitingViewModeShowTop];
}

+ (void)request:(NSDictionary *)requestDic bizCode:(NSString *)bizCode successBlock:(KQNetworkSuccessBlock)successBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode{
    [KQSwipeCardHttpService request:requestDic bizCode:bizCode successBlock:successBlock failedBlock:NULL showWaitMode:showWaitMode];
}

+ (void)request:(NSDictionary *)requestDic bizCode:(NSString *)bizCode successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode{
    [KQSwipeCardHttpService request:requestDic bizCode:bizCode successBlock:successBlock failedBlock:failedBlock showWaitMode:showWaitMode timeout:0];
}

+ (void)request:(NSDictionary *)requestDic bizCode:(NSString *)bizCode successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode timeout:(NSInteger)timeout{
    KQSwipeCardHttpManager *manager = [KQSwipeCardHttpManager sharedKQSwipeCardHttpManager];
    KQHttpSwipeCardRequestData *requestData = [KQHttpSwipeCardRequestData requestData:requestDic bizCode:bizCode successBlock:successBlock failedBlock:failedBlock showWaitMode:showWaitMode timeOut:timeout];
    [manager sendRequest:requestData];
}

+ (void)uploadFileData:(NSData * )fileData
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr,NSData *responseData))successBlock
             failBlock:(void (^)(NSData * responseData, NSError * error, NSString *errorMsg))failBlock{
    [KQSwipeCardHttpService uploadFileData:fileData url:[HttpManager.dataSource serviceUrl:KQHttpServiceTypeUpload] fileName:fileName successBlock:successBlock failBlock:failBlock uploadProgress:nil];
}

+ (void)uploadFileData:(NSData * )fileData
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr,NSData *responseData))successBlock
             failBlock:(void (^)(NSData * responseData, NSError * error, NSString *errorMsg))failBlock
        uploadProgress:(void (^)(double progress))progressBlock{
    [KQSwipeCardHttpService uploadFileData:fileData url:[HttpManager.dataSource serviceUrl:KQHttpServiceTypeUpload]  fileName:fileName successBlock:successBlock failBlock:failBlock uploadProgress:progressBlock];
}

+ (void)uploadFileData:(NSData * )fileData
                   url:(NSString *)urlStr
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr,NSData *responseData))successBlock
             failBlock:(void (^)(NSData * responseData, NSError * error, NSString *errorMsg))failBlock
        uploadProgress:(void (^)(double progress))progressBlock{
    
    [[KQSwipeCardHttpManager sharedKQSwipeCardHttpManager] uploadFileData:fileData url:urlStr fileName:fileName successBlock:successBlock failBlock:failBlock uploadProgress:progressBlock];
}

+ (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock{
    [KQSwipeCardHttpService downloadFileFrom:url toFile:filePath successBlock:successBlock failBlock:failedBlock downloadProgress:nil];
}

+ (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
        downloadProgress:(void (^)(double progress))progressBlock{
    [[KQSwipeCardHttpManager sharedKQSwipeCardHttpManager] downloadFileFrom:url toFile:filePath successBlock:successBlock failBlock:failedBlock downloadProgress:progressBlock];
}

+ (void)downloadFileFrom:(NSString *)url
                bodyData:(NSData *)bodyData
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
        downloadProgress:(void (^)(double progress))progressBlock{
    [[KQSwipeCardHttpManager sharedKQSwipeCardHttpManager] downloadFileFrom:url bodyData:bodyData toFile:filePath successBlock:successBlock failBlock:failedBlock downloadProgress:progressBlock];
}

+ (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)model{
    [KQSwipeCardHttpService cancelRequsetWithMode:model bizeTypeArray:nil];
}

+ (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)model bizeTypeArray:(NSArray *)bizeTypeArray{
    [[KQSwipeCardHttpManager sharedKQSwipeCardHttpManager] cancelRequsetWithMode:model bizeTypeArray:bizeTypeArray];
}
@end
