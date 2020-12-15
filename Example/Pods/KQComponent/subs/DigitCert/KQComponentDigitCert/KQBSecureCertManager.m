//
//  KQSecureCertManager.m
//  kuaiQianbao
//
//  Created by xy on 16/6/20.
//
//

#import "KQBSecureCertManager.h"
#import "SCAP.h"

@interface KQBSecureCertManager()<KQHttpCertDelegate>

@property (nonatomic, strong) NSString *certPin;
@property (nonatomic, strong) NSString *certSerialNumber;
@property (nonatomic, assign) KQSecureCertStatus certStatus;
@property (nonatomic, strong) SCAPCertificate *cert;

@end

@implementation KQBSecureCertManager

#define DO_RETURN()          if (statusBlock) {\
                                 statusBlock(self.certStatus);\
                             }\

SYNTHESIZE_SINGLETON_FOR_CLASS(KQBSecureCertManager);

static NSString *CertSwitchKey = @"digitalSignEnabled";
static NSString *CertSignApiListKey = @"apisNeedTWSign";
static int SECURE_CERT_PIN_MAX_LENGHT = 16;

+ (void)load{
    SecureCertManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        HttpManager.certDelegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveConfigUpdateNotification:) name:KQComponentConfigUpdateNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetData {
    self.certStatus = KQSecureCertStatusUnknow;
    self.certPin = nil;
    self.certSerialNumber = nil;
    self.cert = nil;
}

- (void)initData {
//    [self loadCache];
//    [self checkLocalStatus:NULL];
}

- (void)checkCertStatus:(void (^)(KQSecureCertStatus certStatus))statusBlock{
    if (self.certStatus == KQSecureCertStatusUnknow) {
        [self requestM307:statusBlock];
        return;
    }
    statusBlock(self.certStatus);
}

- (void)installCert:(void (^)(BOOL success, NSString *errorMessage))resultBlock{
    if (self.certStatus == KQSecureCertStatusInstalled
        && self.cert
        && ![NSString kqc_isBlank:self.certPin]) {
        resultBlock(YES, nil);
        return;
    }
    
    [self generateCert:resultBlock];
}

- (void)generateCert:(void (^)(BOOL success, NSString *errorMessage))resultBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *ppP10 = nil;
        NSString *certPin = [self generatePin];
        NSInteger status = [[SCAP sharedSCAP] generateP10:CFCA_CERT_RSA2048 isDoubleCert:NO pinCode:certPin p10:&ppP10];
        if (status != CFCA_OK
            || [NSString kqc_isBlank:ppP10]) {
            resultBlock(NO, nil);
            return;
        }
        
        NSDictionary *reqDic = @{@"extData1":ppP10,
                                 @"pin":certPin};
        [KQHttpService request:reqDic bizType:@"M308" successBlock:^(Content *response) {
            long tempStatus = [[SCAP sharedSCAP] importSingleCertficate:response.remark];
            if (tempStatus == CFCA_OK && [self checkLocalStatus:response.certId]) {
                self.certPin = certPin;
            } else {
                [self revokeCert:NULL];
            }
            if (resultBlock) {
                resultBlock(self.certStatus == KQSecureCertStatusInstalled, nil);
            }
        } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
            if (resultBlock) {
                resultBlock(NO, errorMessage);
            }
        } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
    });
}

- (void)revokeCert:(void (^)(BOOL success))resultBlock{
    if (self.cert) {
        [[SCAP sharedSCAP] deleteCertificate:self.cert];
    }
    
    self.certStatus = KQSecureCertStatusUninstalled;
    self.certSerialNumber = nil;
    self.certPin = nil;
    self.cert = nil;
    [self requestM309:resultBlock];
}

- (NSString *)sign:(NSString *)srcStr{
    if ([NSString kqc_isBlank:srcStr]) {
        return nil;
    }
    
    if (self.certStatus != KQSecureCertStatusInstalled
        || !self.cert
        || [NSString kqc_isBlank:self.certPin]) {
        return nil;
    }
    
    NSString *signStr = nil;
    NSInteger status = [[SCAP sharedSCAP] sign:self.cert dataToSign:[srcStr dataUsingEncoding:NSUTF8StringEncoding] pin:self.certPin hashType:CFCA_HASH_ALGORITHAM_SHA1 signType:CFCA_SIGN_TYEP_PKCS7_A signature:&signStr];
    if (status != CFCA_OK || [NSString kqc_isBlank:signStr]) {
        return nil;
    }
    
    return signStr;
}

// 初始化时调用，不需要显示等待框与错误信息
- (void)requestM307:(void (^)(KQSecureCertStatus certStatus))statusBlock{
    [KQHttpService request:@{} bizType:@"M307" successBlock:^(Content *response) {
        //1：有效，2：吊销，3：失效
        if (![response.status isEqualToString:@"1"]) {
            [self removeLocalCert:response.certId]; // 先注销本地证书
            self.certStatus = KQSecureCertStatusUninstalled;
            if ([response.status isEqualToString:@"2"]) {
                DO_RETURN()
            } else {
                [self revokeCert:^(BOOL success) { // 等吊销有结果了再出结果
                    DO_RETURN()
                }];
            }
            return;
        }
        
        BOOL isInstall = [self checkLocalStatus:response.certId];
        if (!isInstall) {
            [self revokeCert:^(BOOL success) {
                DO_RETURN()
            }];
            return;
        }
        
        self.certPin = [response.pin kqb_decrypt];
        DO_RETURN()
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        self.certStatus = KQSecureCertStatusUnknow;
        if (errorMessage) {
            //            [KQBToastView show:errorMessage];
        }
        if (statusBlock) {
            statusBlock(self.certStatus);
        }
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
}

- (void)requestM309:(void (^)(BOOL success))resultBlock{
    [KQHttpService request:@{} bizType:@"M309" successBlock:^(id response) {
        if (resultBlock) {
            resultBlock(YES);
        }
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        DLog(@"吊销证书失败 errorCode:%@ errorMessage:%@", errorCode, errorMessage);
        if (resultBlock) {
            resultBlock(NO);
        }
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
}

- (BOOL)checkLocalStatus:(NSString *)certSerialNumber{
    if ([NSString kqc_isBlank:certSerialNumber]) {
        return NO;
    }
    
    self.cert = [self findLocalCert:certSerialNumber];
    if (!self.cert) {
        return NO;
    }
    self.certSerialNumber = certSerialNumber;
    self.certStatus = KQSecureCertStatusInstalled;
    return YES;
}

- (void)removeLocalCert:(NSString *)certSerialNumber{
    if ([NSString kqc_isBlank:certSerialNumber]) {
        return;
    }
    
    SCAPCertificate *cert = [self findLocalCert:certSerialNumber];
    if (cert) {
        [[SCAP sharedSCAP] deleteCertificate:cert];
    }
}

- (SCAPCertificate *)findLocalCert:(NSString *)certSerialNumber{
    NSArray *certArray = nil;
    long status = [[SCAP sharedSCAP] getAllCertificates:&certArray];
    if (status != CFCA_OK
        || !certArray
        || certArray.count == 0) {
        return nil;
    }
    
    NSPredicate *certPredicate = [NSPredicate predicateWithFormat:@"serialNumber = %@", certSerialNumber];
    NSArray *resultArray = [certArray filteredArrayUsingPredicate:certPredicate];
    if (!resultArray || resultArray.count == 0) {
        return nil;
    }
    
    return resultArray[0];
}

/*
 16位PIN码（字符串）生成规则：
 X=随机数字的个数 Y=随机字母的个数 X随机4-12 ； Y=16-X
 1-16中，随机X个不同的数字，确认数字在字符串中的位置。
 0-9中，随机X个数字，按先后顺序填入数字在字符串中的位置。
 A-     Z中，随机Y个字母，按先后顺序填入剩余位置
 */
- (NSString *)generatePin{
    int X = [KQCMath getRandomNumber:4 to:12];
    
    NSMutableArray *digitAllArray = [NSMutableArray arrayWithCapacity:SECURE_CERT_PIN_MAX_LENGHT];
    for (int i = 0; i < SECURE_CERT_PIN_MAX_LENGHT; i++){
        [digitAllArray addObject:@(i)];
    }
    
    NSMutableArray *digitLocArray = [NSMutableArray arrayWithCapacity:X];
    for (int i = 0; i < X; i++) {
        int loc = [KQCMath getRandomNumber:0 to:(int)digitAllArray.count - 1];
        [digitLocArray addObject:digitAllArray[loc]];
        [digitAllArray removeObjectAtIndex:loc];
    }
    
    [digitLocArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    
    NSMutableString *pinStr = [NSMutableString string];
    [digitLocArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int loc = obj.intValue;
        while (loc > pinStr.length) {
            [self appendRandomCharacter:pinStr];
        }
        
        if (loc == pinStr.length) {
            [pinStr appendFormat:@"%d", [KQCMath getRandomNumber:0 to:9]];
        }
    }];
    
    while (pinStr.length < SECURE_CERT_PIN_MAX_LENGHT) {
        [self appendRandomCharacter:pinStr];
    }
    
    return pinStr;
}

- (void)appendRandomCharacter:(NSMutableString *)str{
    int character = [KQCMath getRandomNumber:65 to:90]; // A-Z的ascii码
    [str appendFormat:@"%c", (unichar)character];
}

//- (NSArray *)secureCertApiArray{
//    if (!_secureCertApiArray) {
//        _secureCertApiArray = [FunctionSwitchManager.apisNeedTWSign componentsSeparatedByString:@","];
//    }
//    return _secureCertApiArray;
//}
//
//- (BOOL)isCertAvailable{
//    return FunctionSwitchManager.digitalSignEnabled.integerValue == 1;
//}

- (BOOL)isNeedCertSign:(NSString *)bizType{
    return self.isCertAvailable && [self.secureCertApiArray containsObject:bizType];
}

#pragma mark - Digital Cert Delegate
- (BOOL)httpRequestNeedCertSign:(NSString *)bizType{
    return [self isNeedCertSign:bizType];
}

- (NSString *)certSign:(NSString *)srcStr{
    return [self sign:srcStr];
}

#pragma mark - Notification
- (void)receiveConfigUpdateNotification:(NSNotification *)notification{
    if (!notification.object) {
        return;
    }
    
    if (notification.object[CertSwitchKey]) {
        self.isCertAvailable = ([notification.object[CertSwitchKey] integerValue]) == 1;
    }
    
    if (notification.object[CertSignApiListKey]) {
        self.secureCertApiArray = [notification.object[CertSignApiListKey] componentsSeparatedByString:@","];
    }
}

@end
