//
//  KQHttpSwipeCardDataSource.m
//  AFNetworking
//
//  Created by tian qing on 2018/12/18.
//

#import "KQHttpSwipeCardDataSource.h"
#import "KQHttpServiceConfig.h"
#import "KQSwipeCardHttpManager.h"

@interface KQHttpSwipeCardDataSource()

@property (nonatomic, strong) NSArray *serviceConfigArray;
@property (nonatomic, strong) NSDictionary *localErrorDic;
@property (nonatomic, strong) NSDictionary *urlConfigDic;

@end

@implementation KQHttpSwipeCardDataSource

static NSString *KQBServerVersion = @"4.6";
static NSString *KQBAppVersion = nil;

static BOOL IgnoreNetworkCert = NO; // 是否忽略证书验证
static NSString *GatewayServiceUrl = nil; // 网关地址
static NSString *CustUpload = nil; // 文件上传地址
static NSString *SwipeCardServiceUrl = nil; // 刷卡交易url

static NSArray *SensitiveWordsArray = nil;
static NSDictionary *CustomerSensitiveWordsDic = nil;
static NSDictionary *CustomerSecondLevelSensitiveWordsDic = nil;

#define kCustomerSensitiveKey       @"key"
#define kCustomerSensitiveAddFlag   @"AddFlag"

#define kUrlHostKey             @"gatewayPath"
#define kIgnoreCertKey          @"ignoreCert"

#define SERVICE_CONFIG(type, host, bizArray)   [KQHttpServiceConfig serviceConfig:type url:host bizTypeArray:bizArray]

SYNTHESIZE_SINGLETON_FOR_CLASS(KQHttpSwipeCardDataSource);

+ (void)load{
    [[NSNotificationCenter defaultCenter] addObserver:[KQHttpSwipeCardDataSource sharedKQHttpSwipeCardDataSource] selector:@selector(environmentChanged:) name:KQCApplicationEnvironmentDidChangedNotification object:nil];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        SensitiveWordsArray = kSensitiveWordsArray;
        SwipeCardHttpManager.swipeCardDataSource = self;
        
        self.localErrorDic = @{kNetWorkErrorNotConnectKey:@"无网络连接，请稍后再试",
                               kNetWorkErrorParseFailedKey:@"网络繁忙，请稍后再试",
                               kNetWorkErrorConnectTimeOutKey:@"网络连接超时，请稍后再试",
                               kNetWorkErrorConnectFailedKey:@"网络连接失败，请稍后再试",
                               kNetWorkErrorLoginTokenErrorKey:@"您的登录已失效，请重新登录",
                               kNetWorkErrorLocalParamErrorFailedKey:@"请求参数错误，请稍后再试",
                               kNetWorkErrorVerifyServerSignFailedKey:@"本地验签失败，请稍后再试",
                               kNetWorkErrorUploadFailedKey:@"上传文件失败",
                               kNetWorkErrorUserCancelKey:@"用户取消"};
        
        self.urlConfigDic = @{@(KQCAppEnvironmentTypePro):@{kUrlHostKey:@"https://mbp.99bill.com"},
                              @(KQCAppEnvironmentTypeIntegrated):@{kUrlHostKey:@"https://192.168.8.33",
                                                                   kIgnoreCertKey:@(YES)},
                              @(KQCAppEnvironmentTypeDev):@{kUrlHostKey:@"",
                                                            kIgnoreCertKey:@(YES)},
                              @(KQCAppEnvironmentTypeSandbox):@{kUrlHostKey:@"",
                                                                kIgnoreCertKey:@(YES)},
                              };
    }
    return self;
}

#pragma mark - notify environment changed
- (void)environmentChanged:(NSNotification *)notification{
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
    [KQHttpSwipeCardDataSource modifyHost:host];
    
    self.serviceConfigArray = @[SERVICE_CONFIG(KQHttpServiceTypeUpload, CustUpload, nil)];
}

+ (void)modifyHost:(NSString *)host{
    GatewayServiceUrl = [host stringByAppendingString:@"/mbp-cs-gateway/api"];
    CustUpload = [host stringByAppendingString:@"/mbp-c/custDocUpload"];
}

#pragma mark - network datasource
- (NSString *)serviceUrl:(KQSwipeCardHttpServiceType)serviceType{
    NSPredicate *configPredicate = [NSPredicate predicateWithFormat:@"serviceType = %d", serviceType];
    NSArray *configArray = [self.serviceConfigArray filteredArrayUsingPredicate:configPredicate];
    
    if (configArray.count <= 0) {
        return GatewayServiceUrl;
    }
    
    KQSwipeCardHttpServiceConfig *config = [configArray firstObject];
    return config.url;
}

- (KQSwipeCardHttpServiceType)serviceType:(NSString *)bizType {
    NSPredicate *configPredicate = [NSPredicate predicateWithFormat:@"bizTypeArray CONTAINS %@", bizType];
    NSArray *configArray = [self.serviceConfigArray filteredArrayUsingPredicate:configPredicate];
    
    if (configArray.count <= 0) {
        return KQSwipeCardHttpServiceTypeMainService;
    }
    
    KQSwipeCardHttpServiceConfig *config = [configArray firstObject];
    return config.serviceType;
}

- (NSString *)networkVersion:(KQSwipeCardHttpServiceType)serviceType{
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

- (NSString *)decryptParam:(NSString *)paramString bizCode:(NSString *)bizCode {
    if ([NSString kqc_isBlank:paramString]) {
        return @"";
    }
    NSString *decryptString = [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_decryptByAES:paramString];
    return decryptString;
}

- (NSString *)encryptParam:(NSDictionary *)paramDic bizCode:(NSString *)bizCode{
    NSString *contentString = nil;
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramDic options:0 error:&parseError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if ([bizCode isEqualToString:@"swapKey"]) {
        contentString = [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_encryptBeforeGetSecretKey:jsonString];
    } else {
//        contentString = [SwipeCardSecureManager encryptByAES:jsonString];
        contentString = [SwipeCardHttpManager.swipeCardSecureDelegate swipeCard_encryptByAES:jsonString];
    }
    
    return contentString;
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
