//
//  KQHttpMBPDataSource.m
//  KQComponent
//
//  Created by xy on 2018/7/31.
//

#import "KQHttpMBPDataSource.h"
#import "KQHttpServiceConfig.h"
#import "KQHttpManager.h"

@interface KQHttpMBPDataSource()

@property (nonatomic, strong) NSArray *serviceConfigArray;
@property (nonatomic, strong) NSDictionary *localErrorDic;
@property (nonatomic, strong) NSDictionary *urlConfigDic;

@end

@implementation KQHttpMBPDataSource

static NSString *KQBServerVersion = @"4.6";
static NSString *KQBAppVersion = nil;

static BOOL IgnoreNetworkCert = NO; // 是否忽略证书验证
static NSString *GatewayServiceUrl = nil; // 网关地址
static NSString *CustUpload = nil; // 文件上传地址

static NSArray *SensitiveWordsArray = nil;
static NSDictionary *CustomerSensitiveWordsDic = nil;
static NSDictionary *CustomerSecondLevelSensitiveWordsDic = nil;

static NSDictionary *MBPUrlConfigDic = nil;
static NSString *MBPUrlPath = @"/mbp-gateway/gateway";

static NSDictionary *PayMBPUrlConfigDic = nil;
static NSString *PayMBPUrlPath = @"/mbp-xgateway/gateway";

#define kCustomerSensitiveKey       @"key"
#define kCustomerSensitiveAddFlag   @"AddFlag"

#define kUrlHostKey             @"gatewayPath"
#define kIgnoreCertKey          @"ignoreCert"

#define SERVICE_CONFIG(type, host, bizArray)   [KQHttpServiceConfig serviceConfig:type url:host bizTypeArray:bizArray]

SYNTHESIZE_SINGLETON_FOR_CLASS(KQHttpMBPDataSource);

+ (void)load{
    MBPUrlConfigDic = @{@(KQCAppEnvironmentTypePro):@{kUrlHostKey:@"https://mbp.99bill.com"},
                        @(KQCAppEnvironmentTypeIntegrated):@{kUrlHostKey:@"https://192.168.8.33",
                                                             kIgnoreCertKey:@(YES)},
                        @(KQCAppEnvironmentTypeDev):@{kUrlHostKey:@"http://192.168.127.151:8022",
                                                      kIgnoreCertKey:@(YES)},
                        @(KQCAppEnvironmentTypeSandbox):@{kUrlHostKey:@"https://sandbox.99bill.com:9443",
                                                          kIgnoreCertKey:@(YES)},
                        };
    PayMBPUrlConfigDic = @{@(KQCAppEnvironmentTypePro):@{kUrlHostKey:@"https://paymbp.99bill.com"},
                        @(KQCAppEnvironmentTypeIntegrated):@{kUrlHostKey:@"http://192.168.20.67",
                                                             kIgnoreCertKey:@(YES)},
                        @(KQCAppEnvironmentTypeDev):@{kUrlHostKey:@"http://192.168.127.151:8022",
                                                      kIgnoreCertKey:@(YES)},
                        @(KQCAppEnvironmentTypeSandbox):@{kUrlHostKey:@"https://sandbox.99bill.com:9443",
                                                          kIgnoreCertKey:@(YES)},
                        };
    
    [[NSNotificationCenter defaultCenter] addObserver:[KQHttpMBPDataSource sharedKQHttpMBPDataSource] selector:@selector(environmentChanged:) name:KQCApplicationEnvironmentDidChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[KQHttpMBPDataSource sharedKQHttpMBPDataSource] selector:@selector(serverChanged:) name:KQCApplicationServerDidChangedNotification object:nil];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        SensitiveWordsArray = kSensitiveWordsArray;
        HttpManager.dataSource = self;
        
        self.localErrorDic = @{kNetWorkErrorNotConnectKey:@"无网络连接，请稍后再试",
                               kNetWorkErrorParseFailedKey:@"网络繁忙，请稍后再试",
                               kNetWorkErrorConnectTimeOutKey:@"网络连接超时，请稍后再试",
                               kNetWorkErrorConnectFailedKey:@"网络连接失败，请稍后再试",
                               kNetWorkErrorLoginTokenErrorKey:@"您的登录已失效，请重新登录",
                               kNetWorkErrorLocalParamErrorFailedKey:@"请求参数错误，请稍后再试",
                               kNetWorkErrorVerifyServerSignFailedKey:@"本地验签失败，请稍后再试",
                               kNetWorkErrorUploadFailedKey:@"上传文件失败",
                               kNetWorkErrorUserCancelKey:@"用户取消"};
        
        [self serverChanged:nil];
    }
    return self;
}

#pragma mark - notify environment changed
- (void)environmentChanged:(NSNotification *)notification{
    [self switchUrlConfig:[KQCApplication environmentType]];
}

- (void)serverChanged:(NSNotification *)notification{
    self.urlConfigDic = [KQCApplication appServerType] == KQCAppServerTypePay ? PayMBPUrlConfigDic : MBPUrlConfigDic;
    [self switchUrlConfig:[KQCApplication environmentType]];
}

#pragma mark - change environment
- (void)switchUrlConfig:(KQCAppEnvironmentType)environmentType{
    NSDictionary *urlDic = self.urlConfigDic[@(environmentType)];
    if (!urlDic) {
        urlDic = self.urlConfigDic[@(KQCAppEnvironmentTypePro)];
    }
    
    IgnoreNetworkCert = urlDic[kIgnoreCertKey] ? [urlDic[kIgnoreCertKey] boolValue] : NO;
    NSString *host = urlDic[kUrlHostKey];
    [KQHttpMBPDataSource modifyHost:host];
    
    self.serviceConfigArray = @[SERVICE_CONFIG(KQHttpServiceTypeUpload, CustUpload, nil)];
}

+ (void)modifyHost:(NSString *)host{
    GatewayServiceUrl = [host stringByAppendingString:[KQCApplication appServerType] == KQCAppServerTypePay ? PayMBPUrlPath : MBPUrlPath];
    CustUpload = [host stringByAppendingString:@"/mbp-c/custDocUpload"];
}

#pragma mark - network datasource
- (NSString *)serviceUrl:(KQHttpServiceType)serviceType{
    NSPredicate *configPredicate = [NSPredicate predicateWithFormat:@"serviceType = %d", serviceType];
    NSArray *configArray = [self.serviceConfigArray filteredArrayUsingPredicate:configPredicate];
    
    if (configArray.count <= 0) {
        return GatewayServiceUrl;
    }
    
    KQHttpServiceConfig *config = [configArray firstObject];
    return config.url;
}

- (KQHttpServiceType)serviceType:(NSString *)bizType{
    NSPredicate *configPredicate = [NSPredicate predicateWithFormat:@"bizTypeArray CONTAINS %@", bizType];
    NSArray *configArray = [self.serviceConfigArray filteredArrayUsingPredicate:configPredicate];
    
    if (configArray.count <= 0) {
        return KQHttpServiceTypeGateway;
    }
    
    KQHttpServiceConfig *config = [configArray firstObject];
    return config.serviceType;
}

- (NSString *)networkVersion:(KQHttpServiceType)serviceType{
    return KQBServerVersion;
}

- (NSString *)appVersion{
    if (!KQBAppVersion) {
        KQBAppVersion = KQC_FORMAT(@"MP_IOS_APP_KQB_99bill_%@_1605071415_01", [KQCApplication version]);
    }
    return KQBAppVersion;
}

- (BOOL)ignoreNetworkCert{
    return IgnoreNetworkCert;
}

- (NSString *)msgByErrorCode:(NSString *)errorCode{
    NSString *msg = nil;
    if (![NSString kqc_isBlank:errorCode]) {
        msg = self.localErrorDic[errorCode];
    }
    
    if ([NSString kqc_isBlank:msg]) {
        msg = self.localErrorDic[kNetWorkErrorConnectFailedKey];
    }
    return msg;
}

- (void)customerHeader:(NSMutableDictionary *)headerDic bizType:(NSString *)bizType{
    /*未获取到cityId 取上海市cityId 310100*/
    headerDic[@"cityId"] = KQC_Engine_Location.address.cityId ? : @"310100";
}

- (NSDictionary *)encryptParam:(NSDictionary *)paramDic bizType:(NSString *)bizType{
    if (!HttpManager.secureDelegate && ![HttpManager.secureDelegate respondsToSelector:@selector(encryptByAES:)]) {
        return paramDic;
    }
    
    NSArray *tempArray = [self sensitiveKeyArray:paramDic bizType:bizType];
    
    NSMutableDictionary *secretDic = [paramDic mutableCopy];
    [paramDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![tempArray containsObject:key]) {
            return;
        }
        // 处理二级字段加密
        if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *tempSecretArray = [obj mutableCopy];
            [((NSArray *)obj) enumerateObjectsUsingBlock:^(id  _Nonnull elementArray, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([elementArray isKindOfClass:[NSString class]]) {
                    [tempSecretArray replaceObjectAtIndex:idx withObject:[HttpManager.secureDelegate encryptByAES:obj]];
                } else if ([elementArray isKindOfClass:[NSDictionary class]]) {
                    NSArray *tempSecondLevelArray = [self secondLevelSensitiveKeyArray:bizType];
                    NSMutableDictionary *tempDic = [elementArray mutableCopy];
                    [((NSDictionary *)elementArray) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull elementArrayDic, BOOL * _Nonnull stop) {
                        if (![tempSecondLevelArray containsObject:key]) {
                            return;
                        }
                        tempDic[key] = [HttpManager.secureDelegate encryptByAES:elementArrayDic];
                    }];
                    [tempSecretArray replaceObjectAtIndex:idx withObject:tempDic];
                }
            }];
            secretDic[key] = tempSecretArray;
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *tempSecretDic = [obj mutableCopy];
            NSArray *tempSecondLevelArray = [self secondLevelSensitiveKeyArray:bizType];
            [((NSDictionary *)obj) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![tempSecondLevelArray containsObject:key]) {
                    return;
                }
                tempSecretDic[key] = [HttpManager.secureDelegate encryptByAES:obj];
            }];
            secretDic[key] = tempSecretDic;
        } else {
            secretDic[key] = [HttpManager.secureDelegate encryptByAES:obj];
        }
    }];
    
    return secretDic;
}

- (NSArray *)sensitiveKeyArray:(NSDictionary *)paramDic bizType:(NSString *)bizType{
    if (!CustomerSensitiveWordsDic) {
        CustomerSensitiveWordsDic = @{@"M187":@[@{kCustomerSensitiveKey:@"cardId", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M193":@[@{kCustomerSensitiveKey:@"repayOrder", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M194":@[@{kCustomerSensitiveKey:@"repayOrder", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M256":@[@{kCustomerSensitiveKey:@"repayOrder", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M278":@[@{kCustomerSensitiveKey:@"pan"}],
                                      @"M279":@[@{kCustomerSensitiveKey:@"name", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M325":@[@{kCustomerSensitiveKey:@"idCardNo"}],
                                      @"M312":@[@{kCustomerSensitiveKey:@"authCode", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M313":@[@{kCustomerSensitiveKey:@"merchantCode", kCustomerSensitiveAddFlag:@(YES)},
                                                @{kCustomerSensitiveKey:@"authCode", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M323":@[@{kCustomerSensitiveKey:@"expireDate"}],
                                      @"M334":@[@{kCustomerSensitiveKey:@"member", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M345":@[@{kCustomerSensitiveKey:@"pan"}],
                                      @"M352":@[@{kCustomerSensitiveKey:@"authCode", kCustomerSensitiveAddFlag:@(YES)}],
                                      @"M364":@[@{kCustomerSensitiveKey:@"member", kCustomerSensitiveAddFlag:@(YES)},@{kCustomerSensitiveKey:@"memberTwo", kCustomerSensitiveAddFlag:@(YES)}],
                                      };
    }
    
    NSArray *treatKeyArray = CustomerSensitiveWordsDic[bizType];
    if (!treatKeyArray || treatKeyArray.count == 0) {
        return SensitiveWordsArray;
    }
    
    NSMutableArray *resultArray = [SensitiveWordsArray mutableCopy];
    [treatKeyArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *key = obj[kCustomerSensitiveKey];
        NSNumber *flag = obj[kCustomerSensitiveAddFlag];
        
        BOOL addFlag = NO;
        if (flag) {
            addFlag = [flag boolValue];
        }
        
        if (addFlag) {
            [resultArray addObject:key];
        } else {
            [resultArray removeObject:key];
        }
    }];
    return resultArray;
}

- (NSArray *)secondLevelSensitiveKeyArray:(NSString *)bizType{
    if (!CustomerSecondLevelSensitiveWordsDic) {
        CustomerSecondLevelSensitiveWordsDic = @{@"M334":@[@"userName"],
                                                 @"M193":@[@"tradeId", @"txnAcctNo"],
                                                 @"M194":@[@"tradeId", @"txnAcctNo", @"txnAmt"],
                                                 @"M256":@[@"tradeId", @"txnAcctNo", @"txnAmt"],
                                                 @"M364":@[@"openId", @"userMebCode"]
                                                 };
    }
    
    return CustomerSecondLevelSensitiveWordsDic[bizType];
}

@end
