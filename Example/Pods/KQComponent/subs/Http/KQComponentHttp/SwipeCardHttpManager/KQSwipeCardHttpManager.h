//
//  KQSwipeCardHttpManager.h
//  KQBusiness
//
//  Created by building wang on 2018/9/17.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQHttpDelegate.h"
#import "KQHttpUIDelegate.h"
#import "KQHttpSecureDelegate.h"
#import "KQHttpCertDelegate.h"
#import "KQSwipeCardHttpDataSource.h"
#import "KQPSwipeCardSecureDelegate.h"
#import "KQHttpDataSource.h"
#import "KQHttpConfigDelegate.h"

#define SwipeCardHttpManager [KQSwipeCardHttpManager sharedKQSwipeCardHttpManager]

@class KQHttpSwipeCardRequestData;

@interface KQSwipeCardHttpServiceConfig : NSObject

/**
 对应服务器类型
 */
@property (nonatomic, assign) KQSwipeCardHttpServiceType serviceType;

/**
 对应的url
 */
@property (nonatomic, strong, nonnull) NSString *url;

/**
 包含的bizType数组
 */
@property (nonatomic, strong, nullable) NSArray *bizTypeArray;

+ (nonnull instancetype)serviceConfig:(KQSwipeCardHttpServiceType)serviceType url:(NSString * __nonnull)url bizTypeArray:(NSArray * __nonnull)bizTypeArray;

@end


@interface KQSwipeCardHttpResponseData : NSObject

/**
 *  错误码
 */
@property (nonatomic, strong, nonnull) NSString *errorCode;

/**
 *  错误消息
 */
@property (nonatomic, strong, nullable) NSString *errorMessage;

/**
 *  返回的body对象
 */
@property (nonatomic, strong, nullable) id responseBody;

/**
 请求消耗的时间
 */
@property (nonatomic, assign) NSTimeInterval costTime;

@end

@interface KQSwipeCardHttpManager : NSObject

@property (nonatomic, weak, nullable) id<KQHttpUIDelegate> uiDelegate;
@property (nonatomic, weak, nullable) id<KQSwipeCardHttpDataSource> swipeCardDataSource;
@property (nonatomic, weak, nullable) id<KQPSwipeCardSecureDelegate> swipeCardSecureDelegate;
@property (nonatomic, weak, nullable) id<KQHttpConfigDelegate> configDelegate;

+ (nonnull KQSwipeCardHttpManager *)sharedKQSwipeCardHttpManager;

/**
 网络请求数组
 */
@property (nonatomic, strong , nullable) NSMutableArray *requestArray;

- (void)registerSwipeCardServiceData:(NSDictionary *_Nonnull)serviceDictionary;

/**
 发送一个网络请求
 
 @param requestData 请求对象
 */
- (void)sendRequest:(KQHttpSwipeCardRequestData * __nonnull)requestData;

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
- (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)model bizeTypeArray:(NSArray *__nullable)bizeTypeArray;
@end
