//
//  KQSwipeCardHttpManager.m
//  KQBusiness
//
//  Created by building wang on 2018/9/17.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "KQSwipeCardHttpManager.h"
#import "KQHttpSwipeCardRequestData.h"
//#import "KQBSwipeCardSecureManager.h"
//#import "KQBUserInfo.h"
//#import "KQBCityListManager.h"
#import "YYModel.h"
#import "KQCHttpEngine.h"

@implementation KQSwipeCardHttpServiceConfig

+ (instancetype)serviceConfig:(KQSwipeCardHttpServiceType)serviceType url:(NSString *)url bizTypeArray:(NSArray *)bizTypeArray{
    KQSwipeCardHttpServiceConfig *config = [[KQSwipeCardHttpServiceConfig alloc] init];
    config.serviceType = serviceType;
    config.url = url;
    config.bizTypeArray = bizTypeArray;
    return config;
}

@end

@implementation KQSwipeCardHttpResponseData

@end

@interface KQSwipeCardHttpManager() <UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isLogoutAlertShow;
@property (nonatomic, assign) BOOL isTimeCheckAlertShow;
@property (nonatomic, strong) NSDictionary *localErrorDic;
@property (nonatomic, strong) NSArray *serviceConfigArray;
@property (nonatomic, strong) NSDictionary *interfaceDic;      // 接口类

@end

@implementation KQSwipeCardHttpManager

#define SwipeCard_SERVICE_CONFIG(type, host, bizArray)   [KQSwipeCardHttpServiceConfig serviceConfig:type url:host bizTypeArray:bizArray]

SYNTHESIZE_SINGLETON_FOR_CLASS(KQSwipeCardHttpManager);

static NSInteger LogoutAlertTag = 600;
static NSInteger TimeChechAlertTag = 601;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.localErrorDic = @{kSwipeCardNetWorkErrorSecretKeyMismatchKey:@"秘钥不匹配",
                               kSwipeCardNetWorkErrorSecretKeyFailureKey:@"秘钥失效",
                               kSwipeCardNetWorkErrorParametersAbnormalKey:@"参数异常",
                               kSwipeCardNetWorkErrorRepetitiveOperationKey:@"重复操作或请求过于频繁",
                               kSwipeCardNetWorkErrorServiceNotExistKey:@"服务不存在",
                               kSwipeCardNetWorkErrorIncorrectDataFormatKey:@"数据格式不正确",
                               kSwipeCardNetWorkErrorLandingFailureKey:@"登陆失效",
                               kSwipeCardNetWorkErrorUserNotLoggedInKey:@"用户未登陆",
                               kSwipeCardNetWorkErrorTimestampCheckFailedKey:@"时间戳校验失败",
                               kSwipeCardNetWorkErrorSystemBusyKey:@"系统繁忙",
                               kNetWorkErrorNotConnectKey:@"无网络连接，请稍后再试",
                               kNetWorkErrorParseFailedKey:@"网络繁忙，请稍后再试",
                               kNetWorkErrorConnectTimeOutKey:@"网络连接超时，请稍后再试",
                               kNetWorkErrorConnectFailedKey:@"网络连接失败，请稍后再试"};
        
        self.serviceConfigArray = @[];
    }
    return self;
}

- (void)registerSwipeCardServiceData:(NSDictionary *)serviceDictionary {
    self.interfaceDic = serviceDictionary;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showWaiting:(KQHttpSwipeCardRequestData *)requestData{
    // 没有实现等待框
    if (!self.uiDelegate || ![self.uiDelegate respondsToSelector:@selector(showWatingView:)]) {
        return;
    }
    
    [self.uiDelegate showWatingView:requestData.showWaitMode];
}

- (void)hideWaiting:(KQHttpSwipeCardRequestData *)requestData{
    if (requestData.showWaitMode == KQHttpServiceWaitingViewModeNotShow) {
        return;
    }
    
    // 没有实现等待框
    if (!self.uiDelegate || ![self.uiDelegate respondsToSelector:@selector(hideWatingView:)]) {
        return;
    }
    [self.uiDelegate hideWatingView:requestData.showWaitMode];
}

- (void)sendRequest:(KQHttpSwipeCardRequestData *)requestData {
    [self showWaiting:requestData];
    
    [self doSendRequest:requestData];
}

- (void)doSendRequest:(KQHttpSwipeCardRequestData *)requestData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *buildError = nil;
        NSData *postData = [requestData buildRequestData:&buildError];
        
        KQSwipeCardHttpResponseData *responseModel = [[KQSwipeCardHttpResponseData alloc] init];
        if (!postData) {
            NSString *buildErrorCode = buildError ? KQC_FORMAT(@"%ld", (long)buildError.code) : kSwipeCardNetWorkErrorSecretKeyFailureKey;
            [self treatErrorCode:buildErrorCode responseData:responseModel];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkResponseData:responseModel requestData:requestData];
            });
            return;
        }
        
        KQCHttpRequestModel *httpRequestModel = [KQCHttpRequestModel requsetModel:requestData.host body:postData header:requestData.customerHttpHeader successBlock:^(NSData *responseData, NSDictionary *responseHeader) {
            responseModel.costTime = [NSDate date].timeIntervalSince1970 - requestData.currentReqTime;
            [self handleResponseData:responseData withHeader:responseHeader requestData:requestData responseModel:responseModel];
        } failedBlock:^(NSError *error, NSInteger httpStatusCode) {
            responseModel.costTime = [NSDate date].timeIntervalSince1970 - requestData.currentReqTime;
            [KQHttpSwipeCardRequestData resetData];
            
            NSString *errorCode = kNetWorkErrorConnectFailedKey;
            if (error.code == NSURLErrorTimedOut) {
                errorCode = kNetWorkErrorConnectTimeOutKey;
            } else if (error.code == NSURLErrorCancelled) {// 用户主动取消的错误
                errorCode = kNetWorkErrorUserCancelKey;
            }
            
            [self treatErrorCode:errorCode responseData:responseModel];
            [self checkResponseData:responseModel requestData:requestData];
        } timeout:requestData.timeout ignoreCert:[self.swipeCardDataSource ignoreNetworkCert]];
        
        KQCHttpEngine *httpEngine = [[KQCHttpEngine alloc] init];
        [httpEngine sendHttpRequest:httpRequestModel];
    });
}

- (void)uploadFileData:(NSData *)fileData
                   url:(NSString *)urlStr
              fileName:(NSString *)fileName
          successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
             failBlock:(void (^)(NSData *responseData, NSError *error, NSString *errorMsg))failBlock
        uploadProgress:(void (^)(double progress))progressBlock{
    KQCHttpEngine *httpEngine = [[KQCHttpEngine alloc] init];
    [httpEngine uploadFileData:fileData url:urlStr fileName:fileName successBlock:^(NSString *responseStr, NSData *responseData) {
        if (successBlock) {
            successBlock(responseStr, responseData);
        }
    } failBlock:^(NSData *responseData, NSError *error) {
        NSString *errorMsg = [self treatUploadOrDownloadError:error];
        
        if (failBlock) {
            failBlock(responseData, error, errorMsg);
        } else {
            [self.uiDelegate showToast:errorMsg];
//            [KQBToastView show:errorMsg];
        }
    } uploadProgress:progressBlock ignoreCert:[self.swipeCardDataSource ignoreNetworkCert]];
}

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
        downloadProgress:(void (^__nonnull)(double progress))progressBlock {
    KQCHttpEngine *httpEngine = [[KQCHttpEngine alloc] init];
    [httpEngine downloadFileFrom:url bodyData:bodyData toFile:filePath successBlock:^(NSString *responseStr, NSData *responseData) {
        if (successBlock) {
            successBlock(responseStr, responseData);
        }
    } failBlock:^(NSError *error) {
        NSString *errorMsg = [self treatUploadOrDownloadError:error];
        
        if (failedBlock) {
            failedBlock(error);
        } else {
            [self.uiDelegate showToast:errorMsg];
//            [KQBToastView show:errorMsg];
        }
    } uploadProgress:progressBlock ignoreCert:[self.swipeCardDataSource ignoreNetworkCert]];
}

- (void)downloadFileFrom:(NSString *)url
                  toFile:(NSString *)filePath
            successBlock:(void (^)(NSString *responseStr, NSData *responseData))successBlock
               failBlock:(void (^)( NSError *error))failedBlock
        downloadProgress:(void (^)(double progress))progressBlock{
    
    KQCHttpEngine *httpEngine = [[KQCHttpEngine alloc] init];
    [httpEngine downloadFileFrom:url toFile:filePath successBlock:^(NSString *responseStr, NSData *responseData) {
        if (successBlock) {
            successBlock(responseStr, responseData);
        }
    } failBlock:^(NSError *error) {
        NSString *errorMsg = [self treatUploadOrDownloadError:error];
        
        if (failedBlock) {
            failedBlock(error);
        } else {
            [self.uiDelegate showToast:errorMsg];
//            [KQBToastView show:errorMsg];
        }
    } uploadProgress:progressBlock ignoreCert:[self.swipeCardDataSource ignoreNetworkCert]];
}

- (NSString *)treatUploadOrDownloadError:(NSError *)error{
    NSString *errorCode = kNetWorkErrorUploadFailedKey;
    if (error.code == NSURLErrorTimedOut) {
        errorCode = kNetWorkErrorConnectTimeOutKey;
    }
    
    return self.localErrorDic[errorCode];
}

- (void)handleResponseData:(NSData *)responseData withHeader:(NSDictionary *)responseHeader requestData:(KQHttpSwipeCardRequestData *)requestData responseModel:(KQSwipeCardHttpResponseData *)responseModel {
    NSDictionary *response = [requestData parseResponseData:responseData];
    
    if (!response) {
        [self treatErrorCode:kSwipeCardNetWorkErrorSystemBusyKey responseData:responseModel];
        [self checkResponseData:responseModel requestData:requestData];
        return;
    }
    
    NSDictionary *headerDic = response[@"header"];
    [self parseHeader:headerDic responseData:responseModel];
    
    id data = response[@"data"];

    if ([data isKindOfClass:[NSDictionary class]]) {
        responseModel.responseBody = [self parsingResponseDataToModel:data bizCode:requestData.bizCode];
    }
    
    [self checkResponseData:responseModel requestData:requestData];
}

- (void)parseHeader:(NSDictionary *)headerDic responseData:(KQSwipeCardHttpResponseData *)responseData{
    if (!headerDic) {
        [self treatErrorCode:kSwipeCardNetWorkErrorSystemBusyKey responseData:responseData];
        return;
    }
    
    [self treatErrorCode:headerDic[@"rspCode"] errorMsg:headerDic[@"rspMsg"] responseData:responseData];
}

- (void)treatErrorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg responseData:(KQSwipeCardHttpResponseData *)responseData{
    if (!errorMsg) {
        errorMsg = self.localErrorDic[kNetWorkErrorConnectFailedKey];
    }
    
    responseData.errorCode = errorCode;
    responseData.errorMessage = errorMsg;
}

- (void)treatErrorCode:(NSString *)errorCode responseData:(KQSwipeCardHttpResponseData *)responseData{
    [self treatErrorCode:errorCode errorMsg:self.localErrorDic[errorCode] responseData:responseData];
}

- (BOOL)checkSpecificError:(KQSwipeCardHttpResponseData *)responseData requestData:(KQHttpSwipeCardRequestData *)requestData{
    
    if ([responseData.errorCode isEqualToString:kSwipeCardNetWorkErrorSecretKeyFailureKey]
        || [responseData.errorCode isEqualToString:kSwipeCardNetWorkErrorSecretKeyMismatchKey]
        || [responseData.errorCode isEqualToString:kSwipeCardNetWorkErrorVerifyServerSignFailedKey]
        || [responseData.errorCode isEqualToString:kNetWorkErrorLocalSecureKeyErrorKey]) { // 重新交换密钥
        if (![requestData.bizCode isEqualToString:@"swapKey"]) {
            [self treatExchangeKey:requestData];
        }
        return NO;
    } else if ([responseData.errorCode isEqualToString:kSwipeCardNetWorkErrorLandingFailureKey]) {

    } else if ([responseData.errorCode isEqualToString:kSwipeCardNetWorkErrorUserNotLoggedInKey]) {

    } else if ([responseData.errorCode isEqualToString:kSwipeCardNetWorkErrorUserNotLoggedInKey]) {
        [self treatNeedLogin:requestData];
        return NO;
    } else if ([responseData.errorCode isEqualToString:kSwipeCardNetWorkErrorTimestampCheckFailedKey]) {
        [self treatDeviceTimeOut:responseData.errorMessage];
        return NO;
    } else {
        return YES;
    }

    [self treatLogoutAlert:responseData.errorMessage];
    return NO;
}

#pragma mark - treat special error code
- (void)treatExchangeKey:(KQHttpSwipeCardRequestData *)requestData{
    [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_resetData];
//    [SwipeCardSecureManager resetData];
//    DLog(@"开始重发请求， bizType = %@", requestData.bizCode);
//    [KQBToastView show:KQC_NON_NIL(self.localErrorDic[kNetWorkErrorParseFailedKey])];
    [SwipeCardHttpManager.uiDelegate showToast:KQC_NON_NIL(self.localErrorDic[kNetWorkErrorParseFailedKey])];
    KQHttpSwipeCardRequestData *r = [KQHttpSwipeCardRequestData requestData:@{} bizCode:@"swapKey" successBlock:NULL failedBlock:NULL showWaitMode:KQHttpServiceWaitingViewModeNotShow timeOut:0];
    [self sendRequest:r];
//    [KQSwipeCardHttpService request:@{} bizCode:@"swapKey" successBlock:^(id response) {
//
//    }];
}

- (void)treatDeviceTimeOut:(NSString *)tips{
    if (self.isLogoutAlertShow) {
        return;
    }
    
    if (!self.isTimeCheckAlertShow) {
        self.isTimeCheckAlertShow = YES;
        UIAlertView *alertView = nil;
        alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        alertView.tag = TimeChechAlertTag;
        [alertView show];
    }
}

- (void)treatLogoutAlert:(NSString *)tips{
    if (!self.isLogoutAlertShow) {
        if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(hideWatingView:)]) {
            [self.uiDelegate hideWatingView:KQHttpServiceWaitingViewModeShow];
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alertView.tag = LogoutAlertTag;
        [alertView show];
        self.isLogoutAlertShow = YES;
    }
}

- (void)treatNeedLogin:(KQHttpSwipeCardRequestData *)requestData{
    if (!ComponentManager.userStatusDelegate || ![ComponentManager.userStatusDelegate respondsToSelector:@selector(userShouldLogin:)]) {
        return;
    }
    
    [ComponentManager.userStatusDelegate userShouldLogin:^(BOOL isSuccess) {
//        if (isSuccess) {
//            [self sendRequest:requestData];
//        }
    }];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KQBUserNeedLoginInNotification object:@{@"resultBlock":^(BOOL isSuccess){
//
//    }}];
}

- (void)checkResponseData:(KQSwipeCardHttpResponseData *)responseData requestData:(KQHttpSwipeCardRequestData *)requestData{
    [self hideWaiting:requestData];
    
    BOOL isSuccess = [responseData.errorCode isEqualToString:@"0000"];
    
    if (![self checkSpecificError:responseData requestData:requestData]) {
        return;
    }
    
    if (isSuccess) {
        if (requestData.successBlock) {
            requestData.successBlock(responseData.responseBody);
        }
    } else {
        // 如果是用户取消，那么在底层吃掉错误，不做提示、不向上层传递
        if ([responseData.errorCode isEqualToString:kNetWorkErrorUserCancelKey]) {
            return;
        }
        if (requestData.failedBlock) {
            requestData.failedBlock(responseData.errorCode, responseData.errorMessage, responseData.responseBody);
        } else {
            if ([NSString kqc_isBlank:responseData.errorMessage]) {
                responseData.errorMessage = self.localErrorDic[kSwipeCardNetWorkErrorSystemBusyKey];
            }
            [self.uiDelegate showToast:KQC_NON_NIL(responseData.errorMessage)];
//            [KQBToastView show:KQC_NON_NIL(responseData.errorMessage)];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    alertView.delegate = nil;
    if (alertView.tag == LogoutAlertTag) {
        self.isLogoutAlertShow = NO;
        if (ComponentManager.userStatusDelegate && [ComponentManager.userStatusDelegate respondsToSelector:@selector(userShouldLogout:)]) {
            [ComponentManager.userStatusDelegate userShouldLogout:nil];
        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:KQBUserSignOutNotification object:nil];
    } else if (alertView.tag == TimeChechAlertTag) {
        self.isTimeCheckAlertShow = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:KQCDeviceTimeOutOfRangeNotification object:nil];
    }
}

#pragma mark - 返回报文解析
- (id)parsingResponseDataToModel:(NSDictionary *)responseDataDic bizCode:(NSString *)bizCode{
    NSString *className = self.interfaceDic[bizCode];
    Class responseDataClass = NSClassFromString(className);
    
    if (!responseDataClass) {
        return responseDataDic;
    }
    
    NSObject *dataModel = [responseDataClass yy_modelWithDictionary:responseDataDic];;
    if (!dataModel || ![dataModel isKindOfClass:[NSObject class]]) {
        return responseDataDic;
    }
    
    return dataModel;
}

#pragma mark - cancelRequset
- (void)cancelRequsetWithMode:(KQHttpServiceCancelMode)model bizeTypeArray:(NSArray *__nullable)bizeTypeArray{
    switch (model) {
        case KQHttpServiceCancelRequsetWithBizeTypeMode://!< 根据bizeType取消对应的网络请求
            [self cancelRequsetWithBizeTypes:bizeTypeArray];
            break;
        case KQHttpServiceCancelRequsetMode://!< 取消掉canCancel=YES的网络请求
            [self cancelRequestData];
            break;
        case KQHttpServiceCancelAllRequsetWithOutUpLoadMode://!< 取消掉除了上传文件以外的所有的网络请求
            // cancelAllRequest
            [KQCHttpEngine cancelRequest:[self.swipeCardDataSource serviceUrl:KQSwipeCardHttpServiceTypeMainService] isUpload:NO];
            break;
        case KQHttpServiceCancelAllRequsetMode://!< 取消掉所有的网络请求
            // cancelCustUpload
            [KQCHttpEngine cancelRequest:[self.swipeCardDataSource serviceUrl:KQHttpCardHttpServiceTypeUpload]  isUpload:YES];
            break;
            
        default:
            break;
    }
}

// 取消指定接口的网络请求
- (void)cancelRequsetWithBizeTypes:(NSArray * _Nullable )bizTypeArray{
    if (!bizTypeArray || ![bizTypeArray isKindOfClass:[NSArray class]] || bizTypeArray.count == 0 ) {
        return;
    }
    for (KQHttpSwipeCardRequestData *data in self.requestArray) {
        for (NSString *bizeType in bizTypeArray) {
            if ([data.bizCode isEqualToString:bizeType]) {
                [data.task cancel];
            }
        }
    }
}

- (void)cancelRequestData{
    // 取消掉canCancel=YES的网络请求
    @synchronized (self.requestArray) {
        [self.requestArray enumerateObjectsUsingBlock:^(KQHttpSwipeCardRequestData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.canCancel) {
                [obj.task cancel];
            }
        }];
    }
}

#pragma mark - requestArray
- (void)addRequestData:(KQHttpSwipeCardRequestData *__nonnull)requestData{
    @synchronized (self.requestArray) {
        [self.requestArray addObject:requestData];
    }
}

- (void)removeRequestData:(KQHttpSwipeCardRequestData *__nonnull)requestData{
    @synchronized (self.requestArray) {
        [self.requestArray removeObject:requestData];
    }
}

@end
