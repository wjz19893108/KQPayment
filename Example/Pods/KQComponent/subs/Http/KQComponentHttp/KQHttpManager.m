//
//  KQHttpManager.m
//  kuaiQianbao
//
//  Created by xy on 15/8/16.
//
//

#import "KQHttpManager.h"
#import "KQHttpBaseRequestData.h"
#import "KQHttpResponseData.h"
#import "Msg.pb.h"
#import "KQCHttpEngine.h"

typedef NS_ENUM(NSInteger, KQAPPFlagType) {
    KQAPPFlagTypeNo = 0,
    KQAPPFlagTypeOptional,
    KQAPPFlagTypeRequired
};

@interface KQHttpManager() <UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isLogoutAlertShow;
@property (nonatomic, assign) BOOL isTimeCheckAlertShow;
@property (nonatomic, assign) BOOL isAccountRiskAlertShow; // 账户风险

@end

@implementation KQHttpManager

#define CHECK_VALUE_RETURN_VALUE(param)     if ([NSString kqc_isBlank:param]) {\
                                                self.refreshTokenState = RefreshTokenStateError;\
                                                return nil;\
                                            }

#define CHECK_VALUE(param)                  if ([NSString kqc_isBlank:param]) {\
                                                self.refreshTokenState = RefreshTokenStateError;\
                                                return;\
                                            }


SYNTHESIZE_SINGLETON_FOR_CLASS(KQHttpManager);

static NSInteger LogoutAlertTag = 700;
static NSInteger TimeChechAlertTag = 701;
static NSInteger AccountRiskAlertTag = 702; // 账户有风险返回码（R65）

- (instancetype)init{
    self = [super init];
    if (self) {
        // 全局网络请求数组
        self.requestArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showWaiting:(KQHttpBaseRequestData *)requestData{
    // 没有实现等待框
    if (!self.uiDelegate || ![self.uiDelegate respondsToSelector:@selector(showWatingView:)]) {
        return;
    }
    
    [self.uiDelegate showWatingView:requestData.showWaitMode];
}

- (void)hideWaiting:(KQHttpBaseRequestData *)requestData{
    if (requestData.showWaitMode == KQHttpServiceWaitingViewModeNotShow) {
        return;
    }
    
    // 没有实现等待框
    if (!self.uiDelegate || ![self.uiDelegate respondsToSelector:@selector(hideWatingView:)]) {
        return;
    }
    [self.uiDelegate hideWatingView:requestData.showWaitMode];
}

- (void)sendRequest:(KQHttpBaseRequestData *)requestData{
    [self showWaiting:requestData];
    
    [self doSendRequest:requestData];
}

- (void)doSendRequest:(KQHttpBaseRequestData *)requestData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *buildError = nil;
        if ([self.delegate respondsToSelector:@selector(extMapParam:bizType:)]) {
            NSMutableDictionary *paramWithExtMapInfo = [NSMutableDictionary dictionaryWithDictionary:requestData.paramDic];
            [self.delegate extMapParam:paramWithExtMapInfo bizType:requestData.bizType];
            requestData.paramDic = paramWithExtMapInfo;
        }
        NSData *postData = [requestData buildRequestData:&buildError];
        
        KQHttpResponseData *responseModel = [[KQHttpResponseData alloc] init];
        if (!postData) {
            NSString *buildErrorCode = buildError ? KQC_FORMAT(@"%ld", (long)buildError.code) : kNetWorkErrorLocalParamErrorFailedKey;
            [self treatErrorCode:buildErrorCode responseData:responseModel];
            dispatch_async(dispatch_get_main_queue(), ^{
               [self checkResponseData:responseModel requestData:requestData];
            });
            return;
        }
        
        KQCHttpRequestModel *httpRequestModel = [KQCHttpRequestModel requsetModel:requestData.host body:postData header:requestData.customerHttpHeader successBlock:^(NSData *responseData, NSDictionary *responseHeader) {
            responseModel.costTime = [NSDate date].timeIntervalSince1970 - requestData.currentReqTime;
            // 网络请求结束  从请求数组中移除
            [self removeRequestData:requestData];
            [self handleResponseData:responseData withHeader:responseHeader requestData:requestData responseModel:responseModel];
        } failedBlock:^(NSError *error, NSInteger httpStatusCode) {
            responseModel.costTime = [NSDate date].timeIntervalSince1970 - requestData.currentReqTime;
            [KQHttpBaseRequestData resetData];
            
            NSString *errorCode = kNetWorkErrorConnectFailedKey;
            if (error.code == NSURLErrorTimedOut) {
                errorCode = kNetWorkErrorConnectTimeOutKey;
            } else if (error.code == NSURLErrorCancelled) {// 用户主动取消的错误
                errorCode = kNetWorkErrorUserCancelKey;
            }
            // 网络请求结束  从请求数组中移除
            [self removeRequestData:requestData];
            [self treatErrorCode:errorCode responseData:responseModel];
            [self checkResponseData:responseModel requestData:requestData];
        } timeout:requestData.timeout ignoreCert:[self.dataSource ignoreNetworkCert]];
        
        requestData.currentReqTime = [NSDate date].timeIntervalSince1970;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendHttpRequest:)]) {
            [self.delegate sendHttpRequest:httpRequestModel];
            return;
        }
        
        KQCHttpEngine *httpEngine = [[KQCHttpEngine alloc] init];
        // 把requestData加入全局请求数组中
        NSURLSessionTask *dataTask = [httpEngine sendHttpRequest:httpRequestModel];
        requestData.task = dataTask;
        [self addRequestData:requestData];
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
            if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(showToast:)]) {
                [self.uiDelegate showToast:errorMsg];
            }
        }
    } uploadProgress:progressBlock ignoreCert:[self.dataSource ignoreNetworkCert]];
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
            if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(showToast:)]) {
                [self.uiDelegate showToast:errorMsg];
            }
        }
    } uploadProgress:progressBlock ignoreCert:[self.dataSource ignoreNetworkCert]];
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
            if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(showToast:)]) {
                [self.uiDelegate showToast:errorMsg];
            }
        }
    } uploadProgress:progressBlock ignoreCert:[self.dataSource ignoreNetworkCert]];
}

- (NSString *)treatUploadOrDownloadError:(NSError *)error{
    NSString *errorCode = kNetWorkErrorUploadFailedKey;
    if (error.code == NSURLErrorTimedOut) {
        errorCode = kNetWorkErrorConnectTimeOutKey;
    }
    
    return [HttpManager.dataSource msgByErrorCode:errorCode];
}

/**
 *  此方法请不要删除
 *  此方法方便日志模块HOOK
 *
 *  @param response 请求的报文
 */
- (void)hookHttpResponseContent:(id)response{
    if (response) {
//        DLog(@"返回数据:%@",response);
    }
}

- (void)handleResponseData:(NSData *)responseData withHeader:(NSDictionary *)responseHeader requestData:(KQHttpBaseRequestData *)requestData  responseModel:(KQHttpResponseData *)responseModel{
    NSDictionary *response = [requestData parseResponseData:responseData];
    [self hookHttpResponseContent:response];

    if (!response) {
        [self treatErrorCode:kNetWorkErrorParseFailedKey responseData:responseModel];
        [self checkResponseData:responseModel requestData:requestData];
        return;
    }
    
    NSDictionary *responsePBHeader = response[@"header"];
    [self parseHeader:responsePBHeader responseData:responseModel];
    
    id responseBody = response[@"msgContent"];
    responseModel.responseBody = responseBody;
    
    if ([self checkStatusResponse:responseBody respCode:responseModel.errorCode]) {
        return;
    }
    [self checkResponseData:responseModel requestData:requestData];
}

- (void)parseHeader:(NSDictionary *)headerDic responseData:(KQHttpResponseData *)responseData{
    if (!headerDic) {
        [self treatErrorCode:kNetWorkErrorParseFailedKey responseData:responseData];
        return;
    }
    
    NSString *loginToken = headerDic[@"loginToken"];
    NSString *currentToken = [self.userDelegate loginToken];
    if (![NSString kqc_isBlank:loginToken]
        && ![loginToken isEqualToString:currentToken]) {
        [self.userDelegate loginTokenChanged:loginToken];
    }
                                                    
    NSString *userId = headerDic[@"appendData"];
    NSString *currentUserId = [self.userDelegate userId];
    if (![NSString kqc_isBlank:userId]
        && ![loginToken isEqualToString:currentUserId]) {
        [self.userDelegate userIdChanged:userId];
    }
    
    [self treatErrorCode:headerDic[@"responseCode"] errorMsg:headerDic[@"responseMsg"] responseData:responseData];
}

- (void)treatErrorCode:(NSString *)errorCode errorMsg:(NSString *)errorMsg responseData:(KQHttpResponseData *)responseData{
    if (!errorMsg) {
        errorMsg = [HttpManager.dataSource msgByErrorCode:errorCode];
    }
    
    responseData.errorCode = errorCode;
    responseData.errorMessage = errorMsg;
}

- (void)treatErrorCode:(NSString *)errorCode responseData:(KQHttpResponseData *)responseData{
    [self treatErrorCode:errorCode errorMsg:[HttpManager.dataSource msgByErrorCode:errorCode] responseData:responseData];
}

- (BOOL)checkLoginToken:(KQHttpResponseData *)responseData requestData:(KQHttpBaseRequestData *)requestData{
    if ([responseData.errorCode isEqualToString:kNetWorkErrorSecureKeyInvaildKey]
        || [responseData.errorCode isEqualToString:kNetWorkErrorVerifySignKey]
        || [responseData.errorCode isEqualToString:kNetWorkErrorLocalSignErrorKey]
        || [responseData.errorCode isEqualToString:kNetWorkErrorLocalSecureKeyErrorKey]) { // 重新交换密钥
        [self treatExchangeKey:requestData];
        return NO;
    } else if ([responseData.errorCode isEqualToString:kNetWorkErrorLoginTokenErrorKey]) {
        responseData.errorMessage = [HttpManager.dataSource msgByErrorCode:kNetWorkErrorLoginTokenErrorKey];
    } else if ([responseData.errorCode isEqualToString:kNetWorkErrorLoginTokenInvaildKey]) {
        
    } else if ([responseData.errorCode isEqualToString:kNetWorkErrorNeedLoginKey]) {
        [self treatNeedLogin:requestData];
        return NO;
    } else if ([responseData.errorCode isEqualToString:kNetWorkErrorTimeOutOfRangeKey]) {
        [self treatDeviceTimeOut:responseData.errorMessage];
        return NO;
    } else if ([responseData.errorCode isEqualToString:kNetWorkErrorAccountRiskKey]) {
        [self treatAccoutRisk:responseData.errorMessage];
        return NO;
    } else {
        return YES;
    }
    
    [self treatLogoutAlert:responseData.errorMessage errorCode:responseData.errorCode];
    return NO;
}

#pragma mark - treat special error code
- (void)treatExchangeKey:(KQHttpBaseRequestData *)requestData{
//    [KQB_Manager_Secure resetData];
    DLog(@"开始重发请求， bizType = %@", requestData.bizType);
    [self doSendRequest:requestData];
}

- (void)treatNeedLogin:(KQHttpBaseRequestData *)requestData{
    if (!ComponentManager.userStatusDelegate || ![ComponentManager.userStatusDelegate respondsToSelector:@selector(userShouldLogin:)]) {
        return;
    }
    
    [ComponentManager.userStatusDelegate userShouldLogin:^(BOOL isSuccess) {
        if (isSuccess) {
            [self sendRequest:requestData];
        }
    }];
}

- (void)treatDeviceTimeOut:(NSString *)tips{
    if (self.isLogoutAlertShow) {
        return;
    }
    
    if (!self.isTimeCheckAlertShow) {
        self.isTimeCheckAlertShow = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        alertView.tag = TimeChechAlertTag;
        [alertView show];
    }
}

- (void)treatAccoutRisk:(NSString *)tips{
    if (self.isLogoutAlertShow) {
        return;
    }
    
    if (!self.isAccountRiskAlertShow) {
        self.isAccountRiskAlertShow = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:tips
                                                           delegate:self
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil, nil];
        alertView.tag = AccountRiskAlertTag;
        [alertView show];
    }
}

- (void)treatLogoutAlert:(NSString *)tips errorCode:(NSString *)errorCode{
    if (!self.isLogoutAlertShow) {
        if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(hideWatingView:)]) {
            [self.uiDelegate hideWatingView:KQHttpServiceWaitingViewModeShow];
        }
        
        if ([errorCode isEqualToString:kNetWorkErrorLoginTokenErrorKey] &&
            self.userDelegate &&
            [self.userDelegate respondsToSelector:@selector(treatedWithFailureToken)]) {
            [self.userDelegate treatedWithFailureToken];
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alertView.tag = LogoutAlertTag;
        [alertView show];
        self.isLogoutAlertShow = YES;
    }
}

- (void)checkResponseData:(KQHttpResponseData *)responseData requestData:(KQHttpBaseRequestData *)requestData{
    [self hideWaiting:requestData];
    
    BOOL isSuccess = [responseData.errorCode isEqualToString:@"00"];
    if (requestData.serviceType == KQHttpServiceTypeGateway
        && self.delegate
        && [self.delegate respondsToSelector:@selector(shouldResponseContinue:bizType:infoDic:)]
        ) {
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        infoDic[@"cost"] = KQC_FORMAT(@"%ld", (long)(responseData.costTime * 1000));
        if (!isSuccess) {
            infoDic[@"errorCode"] = responseData.errorCode;
            infoDic[@"errorMessage"] = KQC_NON_NIL(responseData.errorMessage);
        }
        
        if (![self.delegate shouldResponseContinue:isSuccess bizType:requestData.bizType infoDic:infoDic]) {
            return;
        }
    }
    
    if (![self checkLoginToken:responseData requestData:requestData]) {
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
            if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(showToast:)]) {
                [self.uiDelegate showToast:responseData.errorMessage];
            }
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
    } else if (alertView.tag == TimeChechAlertTag) {
        self.isTimeCheckAlertShow = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:KQCDeviceTimeOutOfRangeNotification object:nil];
    } else if (alertView.tag == AccountRiskAlertTag) {
        self.isAccountRiskAlertShow = NO;
        
        if (ComponentManager.userStatusDelegate && [ComponentManager.userStatusDelegate respondsToSelector:@selector(userShouldLogout:)]) {
            [ComponentManager.userStatusDelegate userShouldLogout:kNetWorkErrorAccountRiskKey];
        }
    }
}

- (BOOL)checkStatusResponse:(id)response respCode:(NSString *)respCode{
    if (![response isKindOfClass:[Content class]]) {
        return NO;
    }
    
    ContentAppInfo *appInfo = [((Content*)response) appInfo];
    
    NSInteger status = [appInfo.appFlag integerValue];
    if (!appInfo || status < 1) {
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KQCApplicationStatusNotification object:appInfo];
    return [appInfo.appFlag isEqualToString:@"2"];
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
            [KQCHttpEngine cancelRequest:[self.dataSource serviceUrl:KQHttpServiceTypeGateway] isUpload:NO];
            break;
        case KQHttpServiceCancelAllRequsetMode://!< 取消掉所有的网络请求
            // cancelCustUpload
            [KQCHttpEngine cancelRequest:[self.dataSource serviceUrl:KQHttpServiceTypeUpload] isUpload:YES];
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
    for (KQHttpBaseRequestData *data in self.requestArray) {
        for (NSString *bizeType in bizTypeArray) {
            if ([data.bizType isEqualToString:bizeType]) {
                [data.task cancel];
            }
        }
    }
}

- (void)cancelRequestData{
    // 取消掉canCancel=YES的网络请求
    @synchronized (self.requestArray) {
        [self.requestArray enumerateObjectsUsingBlock:^(KQHttpBaseRequestData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.canCancel) {
                [obj.task cancel];
            }
        }];
    }
}

#pragma mark - requestArray
- (void)addRequestData:(KQHttpBaseRequestData *__nonnull)requestData{
    @synchronized (self.requestArray) {
        [self.requestArray addObject:requestData];
    }
}

- (void)removeRequestData:(KQHttpBaseRequestData *__nonnull)requestData{
    @synchronized (self.requestArray) {
        [self.requestArray removeObject:requestData];
    }
}

@end
