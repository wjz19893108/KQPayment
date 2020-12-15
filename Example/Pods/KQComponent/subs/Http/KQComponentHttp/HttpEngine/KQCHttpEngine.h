//
//  KQHttpEngineNew.h
//  kuaiQianbao
//
//  Created by xy on 15/5/5.
//
//

#import <Foundation/Foundation.h>
#import "KQCHttpRequestModel.h"

@interface KQCHttpEngine : NSObject

//- (void)requestData:(NSData *)param url:(NSString *)url header:(NSDictionary *)header successBlock:(void (^)(NSData *responseData, NSDictionary *responseHeader))successBlock failedBlock:(void (^)(NSError *error,NSInteger httpStatusCode))failedBlock timeout:(NSInteger)timeout;

/**
 发送网络请求

 @param requestModel 请求参数
 @return session对象
 */
- (NSURLSessionTask *)sendHttpRequest:(KQCHttpRequestModel *)requestModel;

/**
 上传文件

 @param imageData 文件流
 @param urlStr 目标的url地址
 @param fileName 目标文件名
 @param successBlock 成功回调
 @param failBlock 失败回调
 @param progressBlock 上传进度
 */
- (void)uploadFileData:(NSData *)imageData
                   url:(NSString *)urlStr
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
             failBlock:(void (^)(NSData *responseData, NSError *error))failBlock
        uploadProgress:(void (^)(double progress))progressBlock
            ignoreCert:(BOOL)ignoreCert;

/**
 下载文件
 
 @param url 目标url
 @param bodyData 上送数据
 @param filePath 本地存储路径
 @param successBlock 成功回调
 @param failedBlock 失败回调
 @param progressBlock 下载进度
 */
- (void)downloadFileFrom:(NSString *)url
                bodyData:(NSData *)bodyData
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
          uploadProgress:(void (^)(double progress))progressBlock
              ignoreCert:(BOOL)ignoreCert;

/**
 下载文件

 @param url 目标url
 @param filePath 本地存储路径
 @param successBlock 成功回调
 @param failedBlock 失败回调
 @param progressBlock 下载进度
 */
- (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)(NSError *error))failedBlock
          uploadProgress:(void (^)(double progress))progressBlock
              ignoreCert:(BOOL)ignoreCert;

/**
 取消网络请求

 @param url 目标请求
 @param isUpload 是否为上传请求 YES：是 NO：否
 */
+ (void)cancelRequest:(NSString *)url isUpload:(BOOL)isUpload;
@end
