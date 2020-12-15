//
//  KQHttpBaseRequestData.m
//  kuaiQianbao
//
//  Created by xy on 15/8/16.
//
//

#import "KQHttpBaseRequestData.h"
#import "KQHttpRobotRequestData.h"
#import "KQHttpStatRequestData.h"
#import "KQHttpGatewayRequestData.h"
#import "KQHttpManager.h"
#import "Header.pb.h"

typedef NS_ENUM(NSInteger, KQPExchangeKeyState) {
    KQPExchangeKeyStateNormal = 0,
    KQPExchangeKeyStateExchanging,
    KQPExchangeKeyStateError
};

@interface KQHttpBaseRequestData()

@property (nonatomic, assign) BOOL isBuildHeader; // 是否在组装头
//@property (nonatomic, assign) BOOL isExchangeKey; // 是否在交换密钥
//@property (nonatomic, strong) KQPSecureKeyGroup *keyGroup;
@property (nonatomic, strong) NSMutableString *requestLogStr;
@property (nonatomic, strong) NSString *headerCertSignStr;
@property (nonatomic, assign) BOOL isExchangeKey;

@end

@implementation KQHttpBaseRequestData

static unsigned char SignTag = 0x3;
static unsigned char HeaderTag = 0x1;
static unsigned char BodyTag = 0x2;

static NSString *ExchangeSuccessCode = @"00";

static KQPExchangeKeyState ExchangeKeyState = KQPExchangeKeyStateNormal;
static dispatch_queue_t CheckExchangeKeyQueue = nil;

#define CLASS_STRING(className)   NSStringFromClass([className class])
#define RESET_EXCHANGE_KEY_STATE()  if (ExchangeKeyState == KQPExchangeKeyStateExchanging) { \
                                        [HttpManager.secureDelegate resetData];\
                                        ExchangeKeyState = KQPExchangeKeyStateError;\
                                    }

static NSDictionary *KQPRequestClassDic = nil;

+ (void)initialize{
    KQPRequestClassDic = @{
                           @(KQHttpServiceTypeGateway):CLASS_STRING(KQHttpGatewayRequestData)};
    CheckExchangeKeyQueue = dispatch_queue_create("CheckExchangeKeyQueue", DISPATCH_QUEUE_SERIAL);
}

+ (instancetype)requestData:(NSDictionary *)paramDic bizType:(NSString *)bizType successBlock:(KQNetworkSuccessBlock)successBlock failedBlock:(KQNetworkFailedBlock)failedBlock showWaitMode:(KQHttpServiceWaitingViewMode)showWaitMode timeOut:(NSInteger)timeout{
    if ([NSString kqc_isBlank:bizType]) {
        DLog(@"biz为空，请检查参数");
        return nil;
    }
    
    KQHttpBaseRequestData *requsetData = [KQHttpBaseRequestData configWithBizType:bizType];
    requsetData.paramDic = paramDic;
    requsetData.successBlock = successBlock;
    requsetData.failedBlock = failedBlock;
    requsetData.showWaitMode = showWaitMode;
    // 当showMode为可返还的时候   可以取消   先按showMode的来
    requsetData.canCancel = showWaitMode == KQHttpServiceWaitingViewModeShowTop;
    requsetData.timeout = timeout;

    if (!requsetData.customerHttpHeader) {
        requsetData.customerHttpHeader = @{@"Content-Type":@"application/x-protobuf"};
    }
    return requsetData;
}

+ (instancetype)configWithBizType:(NSString *)bizType{
    KQHttpServiceType serviceType = [HttpManager.dataSource serviceType:bizType];
    Class requsetDataClass = NSClassFromString(KQPRequestClassDic[@(serviceType)]);
    
    if (!requsetDataClass) {
        requsetDataClass = [KQHttpGatewayRequestData class];
    }
    
    KQHttpBaseRequestData *requsetData = [[requsetDataClass alloc] initWithBizType:bizType serviceType:serviceType];
    return requsetData;
}

- (instancetype)initWithBizType:(NSString *)bizType serviceType:(KQHttpServiceType)serviceType{
    self = [super init];
    if (self) {
        self.bizType = bizType;
        _serviceType = serviceType;
        
        self.headerVersion = [HttpManager.dataSource networkVersion:_serviceType];
        self.host = [HttpManager.dataSource serviceUrl:_serviceType];
    }
    return self;
}

- (BOOL)checkKeyState:(KQPSecureKeyGroup * __autoreleasing *)outKeyGroup{
    __block BOOL ret = NO;
    dispatch_sync(CheckExchangeKeyQueue, ^{
        if (ExchangeKeyState == KQPExchangeKeyStateError) {
            ExchangeKeyState = KQPExchangeKeyStateNormal;
        }
        while (ExchangeKeyState == KQPExchangeKeyStateExchanging) { // 已经有密钥交换请求，挂起
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        BOOL isNewCreate = NO;
        KQPSecureKeyGroup *keyGroup = [HttpManager.secureDelegate deviceSecureKey:&isNewCreate];
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
            if ([NSString kqc_isBlank:keyGroup.cipherAesKey]
                || [NSString kqc_isBlank:keyGroup.clientPublicKey]
                || [NSString kqc_isBlank:keyGroup.cipherClientPublicKey]) {
                DLog(@"AES密钥加密失败或客户端公钥、公钥密文为空");
                ret = NO;
                return;
            }
            ret = YES;
            *outKeyGroup = keyGroup;
            ExchangeKeyState = KQPExchangeKeyStateExchanging;
        } else {
            ret = YES;
            ExchangeKeyState = KQPExchangeKeyStateNormal;
        }
    });
    return ret;
}
- (NSData *)buildRequestData:(NSError **)error{
    KQPSecureKeyGroup *keyGroup = nil;
    if (![self checkKeyState:&keyGroup]){
        DLog(@"密钥状态不对，bizType = %@, 放弃发送请求", self.bizType);
        if (ExchangeKeyState != KQPExchangeKeyStateExchanging) {
            [HttpManager.secureDelegate resetData];
        }
        *error = [NSError errorWithDomain:@"buildRequestData" code:[kNetWorkErrorLocalSecureKeyErrorKey integerValue] userInfo:nil];
        return nil;
    }
    
    self.requestLogStr = [NSMutableString stringWithFormat:@"DebugScreenLog:请求数据:\nurl::%@\n{", self.host];
    NSDictionary *deviceInfoDic = [self deviceInfo];
    NSData *headerData = [self header:deviceInfoDic keyGroup:keyGroup];
    NSData *bodyData = [self body];
    DLog(@"%@\n}", self.requestLogStr);
    self.requestLogStr = nil;
    
    NSMutableData *messageData = [NSMutableData data];
    
    [messageData appendBytes:&HeaderTag length:1];
    [messageData appendData:[KQCMath int2Bytes:(int)headerData.length]];
    [messageData appendData:headerData];
    
    [messageData appendBytes:&BodyTag length:1];
    [messageData appendData:[KQCMath int2Bytes:(int)bodyData.length]];
    [messageData appendData:bodyData];
    
    NSMutableData *requestData = [NSMutableData data];
    NSData *signData =  [HttpManager.secureDelegate sign:messageData];
    if (!signData || signData.length == 0) {
        if (ExchangeKeyState != KQPExchangeKeyStateExchanging) {
            [HttpManager.secureDelegate resetData];
        }
        *error = [NSError errorWithDomain:@"buildRequestData" code:[kNetWorkErrorLocalSignErrorKey integerValue] userInfo:nil];
        return nil;
    }
    
    [requestData appendBytes:&SignTag length:1];
    [requestData appendData:[KQCMath int2Bytes:(int)signData.length]];
    if (signData.length > 0) {
        [requestData appendData:signData];
    }
    [requestData appendData:messageData];
    
    return requestData;
}

/**
 *  此方法请不要删除
 *  此方法方便日志模块HOOK
 *
 *  @param messageStr 请求的报文
 */
- (void)hookHttpRequestContent:(NSString *)messageStr {
    DLog(@"%@::\r\n%@", self.host, messageStr);
}

- (void)appendStr:(NSMutableString*)targetStr buildObj:(id)builderObj keyMsg:(NSString*)keyMsg contentMsg:(NSString*)contentMsg{
    if ([self executeSetMehtod:builderObj key:keyMsg value:contentMsg]) {
        [targetStr appendString:contentMsg];
    }
}

- (NSString *)upCaseKey:(NSString *)key{
    if ([NSString kqc_isBlank:key]) {
        return @"";
    }
    return [[[key substringToIndex:1] uppercaseString] stringByAppendingString:[key substringFromIndex:1]];
}

- (BOOL)executeSetMehtod:(id)srcObj key:(NSString *)key value:(id)value{
    NSString *upCaseKey = [self upCaseKey:key];
    NSString *methodName = [NSString stringWithFormat:@"set%@:", upCaseKey];
    SEL selector = NSSelectorFromString(methodName);

    if (![srcObj respondsToSelector:selector]) {
        return NO;
    }
    SuppressPerformSelectorLeakWarning([srcObj performSelector:selector withObject:value]);
    return YES;
}

- (id)executeBuildMethod:(NSString *)key param:(NSDictionary *)param{
    id builder = [self createObjWithName:key];

    [self buildMessage:builder msgKey:nil msgContent:param];
    SuppressPerformSelectorLeakWarning(builder = [builder performSelector:NSSelectorFromString(@"build")]);
    return builder;
}

- (id)createObjWithName:(NSString *)name{
    NSString *upCaseKey = [self upCaseKey:name];
    NSString *classStr = KQC_FORMAT(@"%@%@Builder", self.isBuildHeader ? @"Header" : self.messageNamePrefix, upCaseKey);
    Class targetClass = NSClassFromString(classStr);
    id targetObj = [[targetClass alloc] init];
    return targetObj;
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

- (id)header:(NSDictionary *)deviceInfo keyGroup:(KQPSecureKeyGroup *)keyGroup{
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

    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"version":self.headerVersion,
                              @"bizType":self.bizType,
                              @"requestId":requestId,
                              @"reqTime":nowTime,
                              @"appType":@"iOS",
                              @"appVersion":[HttpManager.dataSource appVersion],
                              @"appChannel":[KQCApplication appChannel],
                              @"loginToken":loginToken,
                              @"deviceInfo":deviceInfo,
                              @"sourceId":KQC_NON_NIL(HttpManager.configDelegate.sourceId)}];
    
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
    NSString *userId = [HttpManager.userDelegate userId];
    if (![NSString kqc_isBlank:userId]) {
        headerDic[@"appendData"] = userId;
    }
    
    if (ExchangeKeyState == KQPExchangeKeyStateExchanging) {
        headerDic[@"aesKey"] = keyGroup.cipherAesKey;
        headerDic[@"rsaKey"] = keyGroup.cipherClientPublicKey;
        self.isExchangeKey = YES;
    }

    [self customHeader:headerDic];
    if ([HttpManager.dataSource respondsToSelector:@selector(customerHeader:bizType:)]) {
        [HttpManager.dataSource customerHeader:headerDic bizType:self.bizType];
    }

    self.isBuildHeader = YES;
    
    if ([self needCertSign]) {
        self.headerCertSignStr = [self signSrcStr:headerDic isRecursive:YES];
    }
    
    id headerInfo = [self executeBuildMethod:@"" param:headerDic];
    return [self pb2Data:headerInfo logPrefix:@"header"];
}

// 子类可以复写该方法，自定义pb头
- (void)customHeader:(NSMutableDictionary *)headerDic{
    
}

- (id)body{
    NSDictionary *paramDic = nil;
    if ([HttpManager.dataSource respondsToSelector:@selector(encryptParam:bizType:)]) {
        paramDic = [HttpManager.dataSource encryptParam:self.paramDic bizType:self.bizType];
    } else {
        paramDic = self.paramDic;
    }
    
    self.isBuildHeader = NO;
    
    if ([self needCertSign]) {
        NSString *contentPreSignStr = [self signSrcStr:paramDic isRecursive:NO];
        paramDic = [self doCertSign:self.headerCertSignStr bodySignStr:contentPreSignStr paramDic:paramDic];
    }
    
    id bodyInfo = [self executeBuildMethod:@"" param:paramDic];
    return [self pb2Data:bodyInfo logPrefix:@"body"];
}

- (NSString *)pbLog:(id)pbInfo logPrefix:(NSString *)logPrefix{
    NSString *pbStr = nil;
    SEL parseMethod = NSSelectorFromString(@"description");
    SuppressPerformSelectorLeakWarning(pbStr = [pbInfo performSelector:parseMethod]);
    NSString *logStr = [NSString stringWithFormat:@"\n%@ = {\n%@}", logPrefix, pbStr];
    return logStr;
}

- (NSData *)pb2Data:(id)pbInfo logPrefix:(NSString *)logPrefix{
    NSString *logStr = [self pbLog:pbInfo logPrefix:logPrefix];
    [self.requestLogStr appendString:logStr];
    
    NSData *pbData = nil;
    SuppressPerformSelectorLeakWarning(pbData = [pbInfo performSelector:NSSelectorFromString(@"data")];);
    return pbData;
}

#pragma mark - 数字证书签名
- (BOOL)needCertSign{
    if (![HttpManager.certDelegate respondsToSelector:@selector(httpRequestNeedCertSign:)]
        || ![HttpManager.certDelegate httpRequestNeedCertSign:self.bizType]) {
        return NO;
    }
    
    if (![HttpManager.certDelegate respondsToSelector:@selector(certSign:)]) {
        return NO;
    }
    
    return YES;
}

- (NSString *)signSrcStr:(NSDictionary *)paramDic isRecursive:(BOOL)isRecursive{
    NSString *preSignStr = nil;
    @try{
        preSignStr = [self generalPreSign:paramDic builderObj:[self createObjWithName:@""] isRecursive:isRecursive];
    }@catch (NSException *e) {
        DLog(@"sign error")
    }
    return preSignStr;
}

- (NSString*)generalPreSign:(NSDictionary *)sourceDic builderObj:(id)builderObj isRecursive:(BOOL)isRecursive{
    NSArray* sourceKeyAry = [[sourceDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *orderStr = [[NSMutableString alloc] init];
    [sourceKeyAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([sourceDic[obj] isKindOfClass:[NSDictionary class]] && isRecursive) {
            id targetObj = [self createObjWithName:obj];
            NSString *innerStr = [self generalPreSign:sourceDic[obj] builderObj:targetObj isRecursive:YES];
            [self appendStr:orderStr buildObj:builderObj keyMsg:obj contentMsg:innerStr];
        }else if([sourceDic[obj] isKindOfClass:[NSString class]]){
            [self appendStr:orderStr buildObj:builderObj keyMsg:obj contentMsg:sourceDic[obj]];
        }
    }];
    return orderStr;
}

- (NSDictionary *)doCertSign:(NSString *)headerSignStr bodySignStr:(NSString *)bodySignStr paramDic:(NSDictionary *)paramDic{
    NSString *preSignStr = KQC_FORMAT(@"%@%@", KQC_NON_NIL(headerSignStr), KQC_NON_NIL(bodySignStr));
    if ([NSString kqc_isBlank:preSignStr]) {
        return paramDic;
    }
    DLog(@"数字证书签名源串:%@", preSignStr);
    preSignStr = [KQCSecure stringFromMD5:preSignStr];
    
    NSString *sign = [HttpManager.certDelegate certSign:preSignStr];
    if ([NSString kqc_isBlank:sign]) {
        return paramDic;
    }
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:paramDic];
    tempDic[@"twSign"] = sign;
    return tempDic;
}

#pragma mark - 组装消息
- (void)buildMessage:(NSObject *)msgContentBd msgKey:(NSString *)msgKey msgContent:(id)msgContent{
    if ([msgContent isKindOfClass:[NSString class]]) {
        [self executeSetMehtod:msgContentBd key:msgKey value:msgContent];
    } else if ([msgContent isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        NSString *tempObjMsgKey = msgKey;
        // 由于memberListArray里面的对象是memberTwo，所以做特殊处理
        if ([tempObjMsgKey isEqualToString:@"member"]) {
            tempObjMsgKey = @"memberTwo";
        }
        [msgContent enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                [array addObject:obj];
            } else {
                id targetObj = [self createObjWithName:tempObjMsgKey];
                [self buildMessage:targetObj msgKey:nil msgContent:obj];
                SuppressPerformSelectorLeakWarning(targetObj = [targetObj performSelector:NSSelectorFromString(@"build")]);
                [array addObject:targetObj];
            }
        }];
        
        NSString *propertyName = KQC_FORMAT(@"%@Array", msgKey); // 先检查array后缀
        if (![self executeSetMehtod:msgContentBd key:propertyName value:array]) {
            propertyName = KQC_FORMAT(@"%@ListArray", msgKey);
            [self executeSetMehtod:msgContentBd key:propertyName value:array];
        }
    } else if ([msgContent isKindOfClass:[NSDictionary class]]) {
        if (![NSString kqc_isBlank:msgKey]) {
            id targetObj = [self createObjWithName:msgKey];
            [msgContent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [self buildMessage:targetObj msgKey:key msgContent:obj];
            }];
            SuppressPerformSelectorLeakWarning(targetObj = [targetObj performSelector:NSSelectorFromString(@"build")]);
            [self executeSetMehtod:msgContentBd key:msgKey value:targetObj];
        } else {
            [msgContent enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self buildMessage:msgContentBd msgKey:key msgContent:obj];
            }];
        }
    }
}

- (void)logHexData:(NSData *)data prefix:(NSString *)prefix{
    NSMutableString *str = [NSMutableString string];
    unsigned char *temp = (unsigned char *)data.bytes;
    for (int i = 0; i < data.length; i++) {
        [str appendFormat:@" %02X", temp[i]];
    }
    DLog(@"%@:::::%@", prefix, str);
}

#pragma mark - 解析网络请求
- (id)parseResponseData:(NSData *)responseData{
    NSData *bodyData = nil;
    NSData *headerData = nil;
    NSData *signData = nil;
    
    int offset = 0;
    NSInteger contentOffset = 0;
    unsigned char *response = (unsigned char *)responseData.bytes;
    for (int i = 0; i < 3; i++) {
        [self parseElementData:response totalLength:(int)responseData.length offset:&offset signData:&signData headerData:&headerData bodyData:&bodyData];
    }
    
    if (!headerData) {
        [self logHexData:responseData prefix:@"header数据流为空"];
        RESET_EXCHANGE_KEY_STATE();
        return nil;
    }
    
    Header *head = [Header parseFromData:headerData];
    if (!head) {
        [self logHexData:responseData prefix:@"header解析失败"];
        RESET_EXCHANGE_KEY_STATE();
        return nil;
    }
    
    if (ExchangeKeyState == KQPExchangeKeyStateExchanging
        && self.isExchangeKey) {
        //    交换密钥失败   R67     翻译RSA  、AES 值、存储key值 失败
        //    密钥失效  RLOST    读取缓存key值  失效
        //    非法请求R95      两个key一个有值一个没值    判断为非法请求
        if (![head.exchangeKeyResult isEqualToString:ExchangeSuccessCode]
            || [NSString kqc_isBlank:head.rsaKey]) {
            DLog(@"密钥交换失败，header::::::%@", [head description]);
            [HttpManager.secureDelegate resetData];
            ExchangeKeyState = KQPExchangeKeyStateError;
            return nil;
        }
        
        BOOL ret = [HttpManager.secureDelegate setServerPublicKey:head.rsaKey];
        if (!ret) {
            [HttpManager.secureDelegate resetData];
        }
        ExchangeKeyState = ret ? KQPExchangeKeyStateNormal : KQPExchangeKeyStateError;
    }
    
    NSMutableString *responseLog = [NSMutableString stringWithFormat:@"DebugScreenLog:返回数据:\nheader = {\n%@}", [head description]];
    
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    [head storeInDictionary:headerDic];
    
    if ([head.responseCode isEqualToString:kNetWorkErrorSecureKeyInvaildKey]
        || [head.responseCode isEqualToString:kNetWorkErrorVerifySignKey]) {
        if (ExchangeKeyState != KQPExchangeKeyStateExchanging) {
            [HttpManager.secureDelegate resetData];
        }
    } else {
        if (!signData) {
            DLog(@"%@", responseLog);
            [self logHexData:responseData prefix:@"签名解析失败"];
            return nil;
        }
        contentOffset = signData.length + 5;
        // 开始验签
        NSData *rawData = [NSData dataWithBytes:response + contentOffset length:responseData.length - contentOffset];
        if (![HttpManager.secureDelegate verify:rawData signData:signData]) {
            headerDic[@"responseCode"] = kNetWorkErrorVerifyServerSignFailedKey; // 签名验证失败
        }
    }
    
    id body = nil;
    if (bodyData) {
        Class resultClass = NSClassFromString(self.messageNamePrefix);
        SEL parseMethod = NSSelectorFromString(@"parseFromData:");
        if (![resultClass respondsToSelector:parseMethod]) {
            return nil;
        }
        
        @try {
            SuppressPerformSelectorLeakWarning(body = [resultClass performSelector:parseMethod withObject:bodyData]);
            
            NSString *logStr = [self pbLog:body logPrefix:@"body"];
            [responseLog appendString:logStr];
        } @catch (NSException *exception) {
            DLog(@"parseResponseData error:%@", [exception name]);
        } @finally {
            
        }
    }
    
    DLog(@"%@", responseLog);
    
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    resultDic[@"header"] = headerDic;
    if (body) {
        resultDic[@"msgContent"] = body;
    }
    
    return resultDic;
}

- (BOOL)parseElementData:(unsigned char *)response totalLength:(int)totalLength offset:(int *)offset signData:(NSData **)signData headerData:(NSData **)headerData bodyData:(NSData **)bodyData{
    if (*offset > totalLength) {
        return NO;
    }
    
    unsigned char tag = response[*offset];
    
    int dataLength = 4;
    if (*offset + dataLength > totalLength) {
        return NO;
    }
    *offset = *offset + 1;
    int valueLength = [KQCMath bytes2Int:response offset:*offset];
    *offset = *offset + dataLength;
    if (*offset + valueLength > totalLength) {
        return NO;
    }
    
    if (tag == SignTag) {
        *signData = [NSData dataWithBytes:response + *offset length:valueLength];
    } else if (tag == HeaderTag) {
        *headerData = [NSData dataWithBytes:response + *offset length:valueLength];
    } else if (tag == BodyTag) {
        *bodyData = [NSData dataWithBytes:response + *offset length:valueLength];
    }
    *offset = *offset + valueLength;
    return YES;
}

#pragma mark - 重置数据
+ (void)resetData{
    RESET_EXCHANGE_KEY_STATE();
}

@end
