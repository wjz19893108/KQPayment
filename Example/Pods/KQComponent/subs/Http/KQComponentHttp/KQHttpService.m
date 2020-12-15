//
//  KQHttpService.m
//  kuaiQianbao
//
//  Created by xy on 15/8/16.
//
//

#import "KQHttpService.h"
#import "KQHttpManager.h"
#import "KQHttpBaseRequestData.h"

@implementation KQHttpService

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock{
    [KQHttpService request:requestDic bizType:bizType successBlock:successBlock showWaitMode:KQHttpServiceWaitingViewModeShowTop];
}

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock{
    [KQHttpService request:requestDic bizType:bizType successBlock:successBlock failedBlock:failedBlock showWaitMode:KQHttpServiceWaitingViewModeShowTop];
}

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode{
    [KQHttpService request:requestDic bizType:bizType successBlock:successBlock failedBlock:NULL showWaitMode:showWaitMode];
}

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode{
    [KQHttpService request:requestDic bizType:bizType successBlock:successBlock failedBlock:failedBlock showWaitMode:showWaitMode timeout:0];
}

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode timeout:(NSInteger)timeout{
    KQHttpBaseRequestData *requestData = [KQHttpBaseRequestData requestData:requestDic bizType:bizType successBlock:successBlock failedBlock:failedBlock showWaitMode:showWaitMode timeOut:timeout];
    [HttpManager sendRequest:requestData];
}

+ (void)uploadFileData:(NSData * )fileData
               fileName:(NSString *)fileName
           successBlock:(void (^)(NSString *responseStr,NSData *responseData))successBlock
              failBlock:(void (^)(NSData * responseData, NSError * error, NSString *errorMsg))failBlock{
    [KQHttpService uploadFileData:fileData url:[HttpManager.dataSource serviceUrl:KQHttpServiceTypeUpload] fileName:fileName successBlock:successBlock failBlock:failBlock uploadProgress:nil];
}

+ (void)uploadFileData:(NSData * )fileData
               fileName:(NSString *)fileName
           successBlock:(void (^)(NSString *responseStr,NSData *responseData))successBlock
              failBlock:(void (^)(NSData * responseData, NSError * error, NSString *errorMsg))failBlock
         uploadProgress:(void (^)(double progress))progressBlock{
    [KQHttpService uploadFileData:fileData url:[HttpManager.dataSource serviceUrl:KQHttpServiceTypeUpload]  fileName:fileName successBlock:successBlock failBlock:failBlock uploadProgress:progressBlock];
}

+ (void)uploadFileData:(NSData * )fileData
                    url:(NSString *)urlStr
               fileName:(NSString *)fileName
           successBlock:(void (^)(NSString *responseStr,NSData *responseData))successBlock
              failBlock:(void (^)(NSData * responseData, NSError * error, NSString *errorMsg))failBlock
         uploadProgress:(void (^)(double progress))progressBlock{
    if ([NSString kqc_isBlank:urlStr]) {
        urlStr = [HttpManager.dataSource serviceUrl:KQHttpServiceTypeUpload];
    }
    [HttpManager uploadFileData:fileData url:urlStr fileName:fileName successBlock:successBlock failBlock:failBlock uploadProgress:progressBlock];
}

+ (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock{
    [KQHttpService downloadFileFrom:url toFile:filePath successBlock:successBlock failBlock:failedBlock downloadProgress:nil];
}

+ (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
        downloadProgress:(void (^)(double progress))progressBlock{
    [HttpManager downloadFileFrom:url toFile:filePath successBlock:successBlock failBlock:failedBlock downloadProgress:progressBlock];
}

+ (void)downloadFileFrom:(NSString *)url
                bodyData:(NSData *)bodyData
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
        downloadProgress:(void (^)(double progress))progressBlock{
    [HttpManager downloadFileFrom:url bodyData:bodyData toFile:filePath successBlock:successBlock failBlock:failedBlock downloadProgress:progressBlock];
}

+ (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)model{
    [KQHttpService cancelRequsetWithMode:model bizeTypeArray:nil];
}

+ (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)model bizeTypeArray:(NSArray *)bizeTypeArray{
    [[KQHttpManager sharedKQHttpManager] cancelRequsetWithMode:model bizeTypeArray:bizeTypeArray];
}
@end
