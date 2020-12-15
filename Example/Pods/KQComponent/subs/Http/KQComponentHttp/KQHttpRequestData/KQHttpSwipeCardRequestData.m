//
//  KQHttpSwipeCardRequestData.m
//  KQProtocol
//
//  Created by building wang on 2018/9/13.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "KQHttpSwipeCardRequestData.h"
#import "KQSwipeCardHttpManager.h"
#import "KQHttpManager.h"

// 此秘钥交换区别于钱包内部的秘钥交换，属于刷卡模块独有的秘钥交换体制
typedef NS_ENUM(NSInteger, KQSwipeCardExchangeKeyState) {
    KQSwipeCardExchangeKeyStateNormal = 0,         // 刷卡模块状态正常
    KQSwipeCardExchangeKeyStateExchanging,         // 刷卡模块秘钥交换请求进行中
    KQSwipeCardExchangeKeyStateError               // 刷卡模块秘钥交换失败
};

static NSString *SwipeCardExchangeSuccessCode = @"0000";

static KQSwipeCardExchangeKeyState ExchangeKeyState = KQSwipeCardExchangeKeyStateNormal;
static dispatch_queue_t SwipeCardExchangeKeyQueue = nil;
static NSDictionary *KQPSwipeCardRequestClassDic = nil;

@interface KQHttpSwipeCardRequestData()

@property (nonatomic, assign) BOOL isExchangeKey;
@property (nonatomic, strong) NSMutableString *requestLogStr;
@property (nonatomic, strong) NSMutableString *requestSignStr;

@end

@implementation KQHttpSwipeCardRequestData

+ (void)initialize{
    KQPSwipeCardRequestClassDic = @{@(KQSwipeCardHttpServiceTypeMainService):NSStringFromClass([KQHttpSwipeCardRequestData class])};
    SwipeCardExchangeKeyQueue = dispatch_queue_create("SwipeCardCheckExchangeKeyQueue", DISPATCH_QUEUE_SERIAL);
}

+ (instancetype)requestData:(NSDictionary *)paramDic bizCode:(NSString *)bizCode successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode timeOut:(NSInteger)timeout{
    if ([NSString kqc_isBlank:bizCode]) {
        DLog(@"biz为空，请检查参数");
        return nil;
    }
    
    KQHttpSwipeCardRequestData *requsetData = [KQHttpSwipeCardRequestData configWithbizCode:bizCode];
    requsetData.paramDic = paramDic;
    requsetData.successBlock = successBlock;
    requsetData.failedBlock = failedBlock;
    requsetData.showWaitMode = showWaitMode;
    // 当showMode为可返还的时候   可以取消   先按showMode的来
    requsetData.canCancel = showWaitMode == KQHttpServiceWaitingViewModeShowTop;
    requsetData.timeout = timeout;
    
    if (!requsetData.customerHttpHeader) {
        requsetData.customerHttpHeader = @{@"Content-Type":@"application/json"};
    }
    return requsetData;
}

+ (instancetype)configWithbizCode:(NSString *)bizCode{
    KQSwipeCardHttpServiceType serviceType = [SwipeCardHttpManager.swipeCardDataSource serviceType:bizCode];
    Class requsetDataClass = NSClassFromString(KQPSwipeCardRequestClassDic[@(serviceType)]);
    
    if (!requsetDataClass) {
        requsetDataClass = [KQHttpSwipeCardRequestData class];
    }
    
    KQHttpSwipeCardRequestData *requsetData = [[requsetDataClass alloc] initWithSwipeCardbizCode:bizCode serviceType:serviceType];
    return requsetData;
}

- (nonnull instancetype)initWithSwipeCardbizCode:(NSString * __nonnull)bizCode serviceType:(KQSwipeCardHttpServiceType)serviceType {
    self = [super init];
    if (self) {
        self.bizCode = bizCode;
        _serviceType = serviceType;
        
        self.headerVersion = [SwipeCardHttpManager.swipeCardDataSource networkVersion:_serviceType];
        self.host = [SwipeCardHttpManager.swipeCardDataSource serviceUrl:_serviceType];
    }
    return self;
}

- (BOOL)checkKeyState:(KQPSecureKeyGroup * __autoreleasing *)outKeyGroup{
    __block BOOL ret = NO;
    dispatch_sync(SwipeCardExchangeKeyQueue, ^{
        if (ExchangeKeyState == KQSwipeCardExchangeKeyStateError) {
            ExchangeKeyState = KQSwipeCardExchangeKeyStateNormal;
        }
        while (self.isExchangeKey && ExchangeKeyState == KQSwipeCardExchangeKeyStateExchanging) { // 已经有密钥交换请求，挂起
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        BOOL isNewCreate = NO;
        KQPSecureKeyGroup *keyGroup = [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_deviceSecureKey:&isNewCreate];
        // 值为空，则数据无效
        if (!keyGroup
            || [NSString kqc_isBlank:keyGroup.aesKey]
            || [NSString kqc_isBlank:keyGroup.clientPrivateKey]) {
            DLog(@"AES密钥或者客户端私钥为空");
            ret = NO;
            return;
        }
        
        // 不是新创建的，如果没有服务器公钥，也代表数据无效
        if (!isNewCreate
            && [NSString kqc_isBlank:keyGroup.serverPublicKey]) {
            DLog(@"服务端公钥为空");
            ret = NO;
            return;
        }
        
        if (isNewCreate) {
            if ([NSString kqc_isBlank:keyGroup.aesKey]
                || [NSString kqc_isBlank:keyGroup.clientPublicKey]) {
                DLog(@"AES密钥加密失败或客户端公钥为空");
                ret = NO;
                return;
            }
            ret = YES;
            *outKeyGroup = keyGroup;
            ExchangeKeyState = KQSwipeCardExchangeKeyStateExchanging;
        } else {
            ret = YES;
            ExchangeKeyState = KQSwipeCardExchangeKeyStateNormal;
        }
    });
    return ret;
}

- (NSData *)buildRequestData:(NSError **)error {
    
    KQPSecureKeyGroup *keyGroup = nil;
    if (![self checkKeyState:&keyGroup]){
        DLog(@"密钥状态不对，bizCode = %@, 放弃发送请求", self.bizCode);
        if (ExchangeKeyState != KQSwipeCardExchangeKeyStateExchanging) {
            [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_resetData];
        }
        *error = [NSError errorWithDomain:@"buildRequestData" code:[kNetWorkErrorLocalSecureKeyErrorKey integerValue] userInfo:nil];
        return nil;
    }
    
    self.requestLogStr = [NSMutableString stringWithFormat:@"DebugScreenLog:刷卡请求数据:\nurl::%@\n", self.host];
    self.requestSignStr = [NSMutableString string];
    
    NSDictionary *headerDic = [self header];
    NSDictionary *dataDic = [self contentWithKeyGroup:keyGroup];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionary];
    [requestDic addEntriesFromDictionary:headerDic];
    [requestDic addEntriesFromDictionary:dataDic];
    
    NSData *messageData = [self.requestSignStr dataUsingEncoding:NSUTF8StringEncoding];
    
    DLog(@"%@\n", self.requestLogStr);
    self.requestLogStr = nil;
    self.requestSignStr = nil;
    
    NSData *signData = [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_sign:messageData];
    NSString *jsonString = [signData base64EncodedString];
    
    [requestDic addEntriesFromDictionary:@{@"sign":KQC_NON_NIL(jsonString)}];
    if (!signData || signData.length == 0) {
        if (ExchangeKeyState != KQSwipeCardExchangeKeyStateExchanging) {
            [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_resetData];
        }
        return nil;
    }
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDic options:NSJSONWritingPrettyPrinted error:error];
    return requestData;
}

- (id)parseResponseData:(NSData *)responseData {
    if (!responseData) {
        return nil;
    }
    
    NSError *error = nil;
    
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        DLog(@"JSON Parsing Error: %@", error);
        return nil;
    }
    
    id data = responseDic[@"data"];
    id responseHeaderDic = responseDic[@"header"];
    id responseSign = responseDic[@"sign"];
    
    if ([NSString kqc_isBlank:responseSign]) {
        NSString *responseString = [self conversionJson:responseDic options:NSJSONWritingPrettyPrinted];
        DLog(@"刷卡返回数据：%@", responseString);
        return responseDic;
    }
    
    NSString *decryptDataString = @"";
    if ([SwipeCardHttpManager.swipeCardDataSource respondsToSelector:@selector(decryptParam:bizCode:)]) {
        decryptDataString = [SwipeCardHttpManager.swipeCardDataSource decryptParam:data bizCode:self.bizCode];
    }
    
    NSDictionary *dataDic = @{};
    NSData *jsonData = [decryptDataString dataUsingEncoding:NSUTF8StringEncoding];
    if (![NSString kqc_isBlank:decryptDataString]) {
        NSError *err = nil;
        dataDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:NSJSONReadingMutableContainers
                                                    error:&err];
    }
    
    NSData *signData = [NSData dataFromBase64String:responseSign];
    
    NSMutableDictionary *afterParsingDic = [NSMutableDictionary dictionary];
    afterParsingDic[@"header"] = responseHeaderDic;
    
    if (ExchangeKeyState == KQSwipeCardExchangeKeyStateExchanging
        && self.isExchangeKey) {
        if (![responseHeaderDic[@"rspCode"] isEqualToString:SwipeCardExchangeSuccessCode]) {
            [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_resetData];
            ExchangeKeyState = KQSwipeCardExchangeKeyStateError;
            return nil;
        }

        BOOL ret = [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_setServerPublicKey:dataDic[@"rsaKey"]];
        if (!ret) {
            [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_resetData];
        }
        ExchangeKeyState = ret ? KQSwipeCardExchangeKeyStateNormal : KQSwipeCardExchangeKeyStateError;
    } else {
        afterParsingDic[@"data"] = dataDic;
    }

    if ([responseHeaderDic[@"rspCode"] isEqualToString:kSwipeCardNetWorkErrorSecretKeyFailureKey] ||
        [responseHeaderDic[@"rspCode"] isEqualToString:kSwipeCardNetWorkErrorSecretKeyMismatchKey]) {
        if (ExchangeKeyState != KQSwipeCardExchangeKeyStateExchanging) {
            [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_resetData];
        }
    } else {
        if (!responseSign) {
            DLog(@"签名解析失败");
            return nil;
        }
        // 开始验签
        if (![SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_verify:jsonData signData:signData]) {
            afterParsingDic[@"header"][@"rspCode"] = kSwipeCardNetWorkErrorVerifyServerSignFailedKey;
        }
    }
    
    NSString *responseString = [self conversionJson:afterParsingDic options:NSJSONWritingPrettyPrinted];
    DLog(@"刷卡返回数据：%@", responseString);
    return afterParsingDic;
}

#pragma mark - 请求报文处理（header、data）
- (id)header {
    NSString *nowTime = [KQCDate dateFormat:[NSDate date] destFormat:KQDateFormatAccurateMicroSecond];;
    // fix bugs 时间字符串中含有“上午”，导致服务器解析失败
    if (![NSString kqc_isBlank:nowTime]) {
        // 0-9 数字 invertedSet， 只保留0-9数字
        NSCharacterSet *removeSets = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        nowTime = [[nowTime componentsSeparatedByCharactersInSet:removeSets] componentsJoinedByString:@""];
    }
    
    NSString *deviceId = [KQCDevice deviceId];
    NSString *randomStr = [NSString stringWithFormat:@"%05d", [KQCMath getRandomNumber:0 to:100000]];
    NSString *requestId = KQC_FORMAT(@"%@%@%@", nowTime, deviceId, randomStr);
    requestId = [requestId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    requestId = [requestId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *loginToken = KQC_NON_NIL([HttpManager.userDelegate loginToken]);
    NSDictionary *deviceInfoDic = [self deviceInfo];
   
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"appId":KQC_NON_NIL(SwipeCardHttpManager.configDelegate.swipeSourceId),
                             @"sourceId": KQC_NON_NIL(SwipeCardHttpManager.configDelegate.swipeSourceId),
                             @"version":self.headerVersion,
                             @"bizCode":self.bizCode,
                             @"requestId":requestId,
                             @"requestTime":nowTime,
                             @"appType":@"iOS",
                             @"appVersion":[SwipeCardHttpManager.swipeCardDataSource  appVersion],
                             @"appChannel":[KQCApplication appChannel],
                             @"loginToken":KQC_NON_NIL(loginToken),
                             @"deviceInfo":deviceInfoDic}];
    
    NSDictionary *headerDic = @{@"header":tempDic};
    
    [self.requestSignStr appendString:KQC_NON_NIL([KQCDevice deviceId])];
    [self.requestSignStr appendString:loginToken];
    
    
    NSString *jsonString = [self conversionJson:headerDic options:NSJSONWritingPrettyPrinted];
    [self.requestLogStr appendString:jsonString];
    
    return headerDic;
}

- (NSDictionary *)deviceInfo{
    NSMutableDictionary *deviceInfoDic = [@{@"mac":[KQCDevice macAddress],
                                            @"imei":@"null",
                                            @"imsi":@"null",
                                            @"deviceId":KQC_NON_NIL([KQCDevice deviceId]),
                                            @"ip":[KQCDevice deviceIPAddress]} mutableCopy];
    
    if (KQC_Engine_Location.longitude
        && KQC_Engine_Location.latitude) {
        deviceInfoDic[@"x"] = KQC_Engine_Location.longitude;
        deviceInfoDic[@"y"] = KQC_Engine_Location.latitude;
    }
    return deviceInfoDic;
}

- (id)contentWithKeyGroup:(KQPSecureKeyGroup *)keyGroup {
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    
    if (ExchangeKeyState == KQSwipeCardExchangeKeyStateExchanging && [self.bizCode isEqualToString:@"swapKey"]) {
        if (!keyGroup) {
            [KQHttpSwipeCardRequestData resetData];
        } else {
            contentDic[@"aesKey"] = keyGroup.aesKey;
            contentDic[@"rsaKey"] = keyGroup.clientPublicKey;
            self.isExchangeKey = YES;
        }
    } else {
        [contentDic addEntriesFromDictionary:self.paramDic];
    }

    NSString *contentString = nil;
    if ([SwipeCardHttpManager.swipeCardDataSource respondsToSelector:@selector(encryptParam:bizCode:)]) {
        contentString = [SwipeCardHttpManager.swipeCardDataSource encryptParam:contentDic bizCode:self.bizCode];
    }
    
    // 输出数据打印
    NSString *logJsonString = [self conversionJson:contentDic options:NSJSONWritingPrettyPrinted];
    [self.requestLogStr appendString:logJsonString];
    
    // 签名字段打印
    NSString *jsonString = [self conversionJson:contentDic options:0];
    [self.requestSignStr appendString:jsonString];
    
    NSDictionary *dataDic = @{@"data":KQC_NON_NIL(contentString)};
    return dataDic;
}

#pragma mark - 字典转json
- (NSString *)conversionJson:(NSDictionary *)dataDic options:(NSJSONWritingOptions)opt {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDic options:opt error:&parseError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark - 重置数据
+ (void)resetData{
    if (ExchangeKeyState == KQSwipeCardExchangeKeyStateExchanging) {
        [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_resetData];
        ExchangeKeyState = KQSwipeCardExchangeKeyStateError;
    }
}

@end
