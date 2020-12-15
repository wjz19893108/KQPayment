//
//  KQHttpService.h
//  kuaiQianbao
//
//  Created by xy on 15/8/16.
//
//
#import "KQHttpMacro.h"

@interface KQHttpService : NSObject

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock;

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock;

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode;

+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode;

/**
 *  发送网络请求
 *
 *  @param requestDic   请求参数
 *  @param bizType      业务类型
 *  @param successBlock 成功回调
 *  @param failedBlock  失败回调
 *  @param showWaitMode   是否显示等待框
 *  @param timeout      超时时间，0为默认超时时间
 */
+ (void)request:(NSDictionary *)requestDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode timeout:(NSInteger)timeout;


+ (void)uploadFileData:(NSData * )fileData
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
             failBlock:(void (^)(NSData *responseData, NSError *error, NSString *errorMsg))failBlock;

+ (void)uploadFileData:(NSData * )fileData
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
             failBlock:(void (^)(NSData *responseData, NSError *error, NSString *errorMsg))failBlock
        uploadProgress:(void (^)(double progress))progressBlock;

/**
 *  上传文件
 *
 *  @param fileData        文件数据
 *  @param urlStr              上传目标url
 *  @param fileName         上传文件名，eg：xxx.jpg、xxx.txt
 *  @param successBlock     成功回调
 *  @param failBlock      失败回调
 *  @param progressBlock   上传进度
 */
+ (void)uploadFileData:(NSData * )fileData
                   url:(NSString *)urlStr
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
             failBlock:(void (^)(NSData *responseData, NSError *error, NSString *errorMsg))failBlock
        uploadProgress:(void (^)(double progress))progressBlock;


+ (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock;

/**
 *  下载文件
 *  @param url              下载目标url
 *  @param filePath         下载文件路径
 *  @param successBlock     成功回调
 *  @param failedBlock      失败回调
 *  @param progressBlock    下载进度
 */
+ (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
          downloadProgress:(void (^)(double progress))progressBlock;

+ (void)downloadFileFrom:(NSString *)url
                bodyData:(NSData *)bodyData
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
        downloadProgress:(void (^)(double progress))progressBlock;

/** 取消网络请求 */
+ (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)model;
+ (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)model bizeTypeArray:(NSArray *)bizeTypeArray;
@end
