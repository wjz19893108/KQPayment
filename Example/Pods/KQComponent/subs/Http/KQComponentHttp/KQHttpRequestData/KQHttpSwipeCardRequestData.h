//
//  KQHttpSwipeCardRequestData.h
//  KQProtocol
//
//  Created by building wang on 2018/9/13.
//  Copyright © 2018年 xy. All rights reserved.
//

//#import <KQProtocol/KQProtocol.h>
//#import <KQCore/KQCHttpMacro.h>

#import "KQHttpMacro.h"
@interface KQHttpSwipeCardRequestData : NSObject

/**
 *  具体服务类型
 */
@property (nonatomic, assign) KQSwipeCardHttpServiceType serviceType;

/**
 *  请求业务类型
 */
@property (nonatomic, copy, nonnull) NSString *bizCode;

/**
 *  请求参数
 */
@property (nonatomic, copy, nullable) NSDictionary *paramDic;

/**
 *  请求地址
 */
@property (nonatomic, strong, nonnull) NSString *host;

/**
 *  成功回调
 */
@property (nonatomic, copy, nullable) KQNetworkSuccessBlock successBlock;

/**
 *  失败回调
 */
@property (nonatomic, copy, nullable) KQNetworkFailedBlock failedBlock;

/**
 *  是否需要签名,默认YES
 */
//@property (nonatomic, assign) BOOL needSign;

/**
 *  是否需要显示等待框,默认YES
 */
@property (nonatomic, assign) KQHttpServiceWaitingViewMode showWaitMode;
/**
 *  对应的请求task
 */
@property (nonatomic , strong , nullable) NSURLSessionTask *task;
/**
 *  是否可以被取消掉  YES为可以
 */
@property (nonatomic , assign) BOOL canCancel;

/**
 *  超时时间，默认为0（采用统一的超时时间）
 */
@property (nonatomic, assign) NSInteger timeout;

/**
 *  头中时间的格式
 */
@property (nonatomic, strong, readonly, nullable) NSDateFormatter *headerDateFormatter;

/**
 *  自定义的http头
 */
@property (nonatomic, strong, nullable) NSDictionary *customerHttpHeader;

/**
 *  当前消息的类型前缀
 */
@property (nonatomic, weak, nullable) NSString *messageNamePrefix;

/**
 *  当前消息的服务版本
 */
@property (nonatomic, strong, nullable) NSString *headerVersion;

/**
 记录当前的请求时间
 */
@property (nonatomic, assign) NSTimeInterval currentReqTime;

+ (nonnull instancetype)requestData:(NSDictionary * __nullable)paramDic bizCode:(NSString * __nonnull)bizCode successBlock:(KQNetworkSuccessBlock __nullable)successBlock failedBlock:(KQNetworkFailedBlock __nullable)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode timeOut:(NSInteger)timeout;

- (nonnull instancetype)initWithSwipeCardbizCode:(NSString * __nonnull)bizCode serviceType:(KQSwipeCardHttpServiceType)serviceType;

/**
 组织网络请求报文
 
 @param error 错误码
 @return 报文流
 */
- (nonnull NSData *)buildRequestData:(NSError *_Nullable*_Nullable)error;

/**
 解析网络返回报文
 
 @param responseData 服务器返回的数据流
 
 @return 解析完的对象
 */
- (nonnull id)parseResponseData:(NSData * __nonnull)responseData;

/**
 重置数据
 */
+ (void)resetData;

@end
