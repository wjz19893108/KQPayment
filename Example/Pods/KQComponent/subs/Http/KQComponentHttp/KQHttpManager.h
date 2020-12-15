//
//  KQHttpManager.h
//  kuaiQianbao
//
//  Created by xy on 15/8/16.
//
//

#import <Foundation/Foundation.h>
#import "KQHttpDelegate.h"
#import "KQHttpUIDelegate.h"
#import "KQHttpUserDelegate.h"
#import "KQHttpDataSource.h"
#import "KQHttpSecureDelegate.h"
#import "KQHttpCertDelegate.h"
#import "KQHttpConfigDelegate.h"

#define HttpManager     [KQHttpManager sharedKQHttpManager]

@class KQHttpBaseRequestData;
@interface KQHttpManager : NSObject

@property (nonatomic, weak, nullable) id<KQHttpDelegate> delegate;
@property (nonatomic, weak, nullable) id<KQHttpUIDelegate> uiDelegate;
@property (nonatomic, weak, nullable) id<KQHttpUserDelegate> userDelegate;
@property (nonatomic, weak, nullable) id<KQHttpDataSource> dataSource;
@property (nonatomic, weak, nullable) id<KQHttpSecureDelegate> secureDelegate;
@property (nonatomic, weak, nullable) id<KQHttpCertDelegate> certDelegate;
@property (nonatomic, weak, nullable) id<KQHttpConfigDelegate> configDelegate;


+ (nonnull KQHttpManager *)sharedKQHttpManager;

/**
 网络请求数组
 */
@property (nonatomic, strong , nullable) NSMutableArray *requestArray;

/**
 发送一个网络请求

 @param requestData 请求对象
 */
- (void)sendRequest:(KQHttpBaseRequestData * __nonnull)requestData;

/**
 上传文件

 @param fileData 文件数据流
 @param urlStr 目标服务器地址
 @param fileName 目标文件名称
 @param successBlock 成功回调
 @param failBlock 失败回调
 @param progressBlock 进度
 */
- (void)uploadFileData:(NSData *__nonnull)fileData
                    url:(NSString *__nonnull)urlStr
               fileName:(NSString *__nonnull)fileName
           successBlock:(void (^__nonnull)(NSString *__nonnull responseStr, NSData *__nonnull responseData))successBlock
              failBlock:(void (^__nonnull)(NSData *__nonnull responseData, NSError *__nonnull error, NSString *__nonnull errorMsg))failBlock
         uploadProgress:(void (^__nonnull)(double progress))progressBlock;


/**
 下载文件
 
 @param url 目标服务器地址
 @param bodyData 上送数据
 @param filePath 保存到本地路径
 @param successBlock 成功回调
 @param failedBlock 失败回调
 @param progressBlock 进度
 */
- (void)downloadFileFrom:(NSString *__nonnull)url
                bodyData:(NSData *__nonnull)bodyData
                  toFile:(NSString *__nonnull)filePath
            successBlock:(void (^__nonnull)(NSString *__nonnull responseStr, NSData *__nonnull responseData))successBlock
               failBlock:(void (^__nonnull)( NSError *__nonnull error))failedBlock
        downloadProgress:(void (^__nonnull)(double progress))progressBlock;

/**
 下载文件

 @param url 目标服务器地址
 @param filePath 保存到本地路径
 @param successBlock 成功回调
 @param failedBlock 失败回调
 @param progressBlock 进度
 */
- (void)downloadFileFrom:(NSString *__nonnull)url
                  toFile:(NSString *__nonnull)filePath
            successBlock:(void (^__nonnull)(NSString *__nonnull responseStr, NSData *__nonnull responseData))successBlock
               failBlock:(void (^__nonnull)( NSError *__nonnull error))failedBlock
        downloadProgress:(void (^__nonnull)(double progress))progressBlock;

/**
 取消网络请求
 */

/**
 取消网络请求

 @param mode 网络请求模式
 @param bizeTypeArray 取消的业务号
 */
- (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)mode bizeTypeArray:(NSArray *__nullable)bizeTypeArray;

@end
