//
//  KQBSecureManager.m
//  KQBusiness
//
//  Created by xy on 2016/10/26.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBSecureManager.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>

@interface KQBSecureManager () {
    SecKeyRef publicServerRSA;
    SecKeyRef privateClientRSA;
    SecKeyRef publicBaseKey;
    NSString *_aesKey;
    KQPSecureKeyGroup *secureKeyGroup;
}
@end

@implementation KQBSecureManager

const char AlgorithmData[] = {0x30, 0x81, 0x9F, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x81, 0x8D, 0x00}; // rsa固定算法标志
static NSString *KQ99BillPublicPEMStr = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCvkhkxipVQPKLgZM2WInhbO4RGI3AZs73y2gqjCnSerD3IQ1TITm097Z3hgJiddBZQ9eICkUUY8CyTw30HgmuAN0TxRBTczAZUu0GX/xyNAj2Hg1U5jQjRZkVdmB4golJUvLAvMmMEQXCevawN7TU0Xhj0BWxToUtZ1qDGHUMCrwIDAQAB";

static NSString *UserAESAppendKey = @"Aj2Hg1U5ju0GEQXCevaw7TczA";

static NSString *ServerPublicKeyTag = @"com.99bill.server.publicKey";
static NSString *LocalPublicKeyTag = @"com.99bill.local.publickey";
static NSString *LocalPrivateKeyTag = @"com.99bill.local.privateKey";
static NSString *ServerBasePublicKeyTag = @"com.99bill.base.publicKey";
static NSString *AESKeyTag = @"com.99bill.local.privateKey.aesKey";

static NSString *KQBCacheSecureKeyGroupKey = @"secureKeyGroup";

static NSInteger NetAESLoopCount = 100;
static NSInteger NetAESKeyLength = 20;

SYNTHESIZE_SINGLETON_FOR_CLASS(KQBSecureManager);

#pragma mark- 读取存储的客户端私钥和服务端公钥
- (instancetype)init{
    self = [super init];
    if (self) {
        NSData *publicData = [NSData dataFromBase64String:KQ99BillPublicPEMStr];
        NSData *data = [NSData dataWithBytes:publicData.bytes + sizeof(AlgorithmData) length:publicData.length - sizeof(AlgorithmData)];
        publicBaseKey = [self convertData2SecType:data tag:ServerBasePublicKeyTag];
    }
    return self;
}

- (void)setCacheDelegate:(id<KQBSecureCacheDelegate>)cacheDelegate{
    _cacheDelegate = cacheDelegate;
    
    if (self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(loadSecureDataCache)]){
        secureKeyGroup = [self.cacheDelegate loadSecureDataCache];
        // 直接初始化，无需检测是否有值
        [self resetClientPrivateKey:secureKeyGroup.clientPrivateKey];
        [self resetServerPublicKey:secureKeyGroup.serverPublicKey];
    }
}

- (void)resetData{
    DLog(@"清除本地公私钥：%@", secureKeyGroup.clientPrivateKey);
    
    if (privateClientRSA) {
        privateClientRSA = NULL;
    }
    
    if (publicServerRSA) {
        publicServerRSA = NULL;
    }
    secureKeyGroup = nil;
    if (self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(saveSecureDataCache:)]) {
        [self.cacheDelegate saveSecureDataCache:nil];
    }
//    [KQBCacheManager saveValue:nil forKey:KQBCacheSecureKeyGroupKey cacheType:KQCacheTypeMain];
}

- (BOOL)resetClientPrivateKey:(NSString *)privateKey{
    if (privateClientRSA) {
        CFRelease(privateClientRSA);
        privateClientRSA = NULL;
    }
    
    if ([NSString kqc_isBlank:privateKey]) {
        return NO;
    }
    
    NSData *privateClientData = [NSData dataFromBase64String:privateKey];
    privateClientRSA = [self convertData2SecType:privateClientData attrKeyClass:kSecAttrKeyClassPrivate tag:LocalPrivateKeyTag];
    return (privateClientRSA != NULL);
}

- (BOOL)resetServerPublicKey:(NSString *)publicKey{
    if (publicServerRSA) {
        CFRelease(publicServerRSA);
        publicServerRSA = NULL;
    }
    
    if ([NSString kqc_isBlank:publicKey]) {
        return NO;
    }
    
    NSData *publicServerData = [NSData dataFromBase64String:publicKey];
    if (publicServerData.length > 140) {
        publicServerData = [NSData dataWithBytes:publicServerData.bytes + sizeof(AlgorithmData) length:publicServerData.length - sizeof(AlgorithmData)];
    }
    publicServerRSA = [self convertData2SecType:publicServerData attrKeyClass:kSecAttrKeyClassPublic tag:ServerPublicKeyTag];
    
    return (publicServerRSA != NULL);
}

- (BOOL)resetAESKey:(NSString *)aesKey{
    if ([NSString kqc_isBlank:aesKey]) {
        return NO;
    }
    
    NSString *key = [aesKey stringByAppendingString:UserAESAppendKey];
    _aesKey = [KQCSecure stringFromMD5:key];
    return YES;
}

#pragma  mark - 生成公私钥
- (BOOL)createRSAKeyPair:(NSString **)privateKey publicKey:(NSString **)publicKey{
    SecKeyRef privateSecKey = NULL;
    SecKeyRef publicSecKey = NULL;
    static NSInteger keyPairLength = 1024;
    
    if (![KQCSecure generateRSAPrivateKey:&privateSecKey publicKey:&publicSecKey keyPairLength:keyPairLength]) {
        return NO;
    }
    NSData *publicSecKeyData = [self convertSecType2Data:publicSecKey tag:LocalPublicKeyTag];
    NSMutableData *publicKeyData = [NSMutableData data];
    [publicKeyData appendBytes:AlgorithmData length:sizeof(AlgorithmData)];
    [publicKeyData appendData:publicSecKeyData];
    *publicKey = [publicKeyData base64EncodedString];
    
    NSData *privateSecKeyData = [self convertSecType2Data:privateSecKey attrKeyClass:kSecAttrKeyClassPrivate tag:LocalPrivateKeyTag];
    *privateKey = [privateSecKeyData base64EncodedString];
    
    return YES;
}

#pragma  mark - 加签、验签
- (NSData *)sign:(NSData *)srcData{
//    DLog(@"本地签名私钥：%@", secureKeyGroup.clientPrivateKey);
    return [KQCSecure sign:srcData privateKey:privateClientRSA];
}

- (BOOL)verify:(NSData *)rawData signData:(NSData *)signData{
    return [KQCSecure verify:rawData signData:signData publicKey:publicServerRSA];
}

- (KQPSecureKeyGroup *)deviceSecureKey:(BOOL *)isNewCreate{
    if (secureKeyGroup) {
        if (isNewCreate) {
            *isNewCreate = NO;
        }
        return secureKeyGroup;
    }
    
    NSString *privateKey = nil;
    NSString *publicKey = nil;
    [KQB_Manager_Secure createRSAKeyPair:&privateKey publicKey:&publicKey];
    
    if ([NSString kqc_isBlank:privateKey]
        || [NSString kqc_isBlank:publicKey]) {
        return nil;
    }
    DLog(@"新生成私钥：%@", privateKey);
    [self resetClientPrivateKey:privateKey];
    
    NSMutableData *tempAesKey = [NSMutableData data];
    [self getRandomArray:tempAesKey len:(int)NetAESKeyLength];
//    networkAesKey = [tempAesKey base64EncodedString];
//    [self resetAESKey:@"AABBCCDD11223344556677889900"];
    
    secureKeyGroup = [[KQPSecureKeyGroup alloc] init];
    secureKeyGroup.clientPrivateKey = privateKey;
    secureKeyGroup.clientPublicKey = publicKey;
    secureKeyGroup.serverPublicKey = nil;
    secureKeyGroup.aesKey = [tempAesKey base64EncodedString];
    secureKeyGroup.cipherAesKey = [self encryptBeforeLogin:secureKeyGroup.aesKey];
    secureKeyGroup.cipherClientPublicKey = [self encryptByAES:publicKey isCacheData:NO];
    if (isNewCreate) {
        *isNewCreate = YES;
    }
    return secureKeyGroup;
}

- (BOOL)setServerPublicKey:(NSString *)publicKey{
    secureKeyGroup.serverPublicKey = [self decryptByAES:publicKey isCacheData:NO];
    if ([self resetServerPublicKey:secureKeyGroup.serverPublicKey]){
        if (self.cacheDelegate && [self.cacheDelegate respondsToSelector:@selector(saveSecureDataCache:)]) {
            [self.cacheDelegate saveSecureDataCache:secureKeyGroup];
        }
//        [KQBCacheManager saveValue:secureKeyGroup forKey:KQBCacheSecureKeyGroupKey cacheType:KQCacheTypeMain];
        return YES;
    }
    [self resetData];
    
    return NO;
}

#pragma mark - 登录前字段加密
- (NSString *)encryptBeforeLogin:(NSString *)plainText{
    if (!plainText) {
        return nil;
    }
    
    if (!publicBaseKey) {
        return nil;
    }
    
    return [KQCSecure encrypt:plainText publicKey:publicBaseKey];
}

#pragma mark - 登录后字段加密
- (NSString *)encryptAfterLogin:(NSString *)plainText{
    return [KQCSecure encrypt:plainText publicKey:publicServerRSA];
}

#pragma mark - 登录后字段解密
- (NSString *)decryptAfterLogin:(NSString *)cipherStr{
    return [KQCSecure decrypt:cipherStr privateKey:privateClientRSA];
}

#pragma mark - 密钥转换
- (NSData *)convertSecType2Data:(SecKeyRef)secKey tag:(NSString *)tag{
    return [self convertSecType2Data:secKey attrKeyClass:NULL tag:tag];
}

- (NSData *)convertSecType2Data:(SecKeyRef)secKey attrKeyClass:(CFTypeRef)keyClass tag:(NSString *)tag{
    if (!secKey || [NSString kqc_isBlank:tag]) {
        return nil;
    }
    
    NSData *keyTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    if (!keyTag) {
        return nil;
    }
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    NSMutableDictionary *addPublicKeyAttributes = [queryPublicKey mutableCopy];
    [addPublicKeyAttributes setObject:(__bridge id)secKey forKey:(__bridge id)kSecValueRef];
    if (keyClass) {
        [addPublicKeyAttributes setObject:(__bridge id)keyClass forKey:(__bridge id)kSecAttrKeyClass];
    }
    [addPublicKeyAttributes setObject:@YES forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef secKeyType = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)addPublicKeyAttributes, &secKeyType);
    SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    if (status != errSecSuccess) {
        DLog(@"convertSecType2Data SecItemAdd error:%d", (int)status);
        return nil;
    }
    
    NSData* secKeyData = CFBridgingRelease(secKeyType);
    return secKeyData;
}

- (SecKeyRef)convertData2SecType:(NSData *)secKeyData tag:(NSString *)tag{
    return [self convertData2SecType:secKeyData attrKeyClass:NULL tag:tag];
}

- (SecKeyRef)convertData2SecType:(NSData *)secKeyData attrKeyClass:(CFTypeRef)keyClass tag:(NSString *)tag{
    if (!secKeyData || [NSString kqc_isBlank:tag]) {
        return NULL;
    }
    
    NSData *keyTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    if (!keyTag) {
        return NULL;
    }
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    NSMutableDictionary *addPublicKeyAttributes = [queryPublicKey mutableCopy];
    [addPublicKeyAttributes setObject:secKeyData forKey:(__bridge id)kSecValueData];
    [addPublicKeyAttributes setObject:@YES forKey:(__bridge id)kSecReturnRef];
    if (keyClass) {
        [addPublicKeyAttributes setObject:(__bridge id)keyClass forKey:(__bridge id)kSecAttrKeyClass];
    }
    
    SecKeyRef secKey = NULL;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)addPublicKeyAttributes, (CFTypeRef*)&secKey);
    SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    if (status != errSecSuccess) {
        DLog(@"convertData2SecType SecItemAdd error:%d", (int)status);
    }
    
    return secKey;
}

#pragma mark - AES加解密
- (NSString *)encryptByAES:(NSString *)plainText{
    return [self encryptByAES:plainText isCacheData:YES];
}

- (NSString *)encryptByAES:(NSString *)plainText isCacheData:(BOOL)isCacheData{
    if (isCacheData) {
        return [KQCSecure encrypt:plainText aes256Key:_aesKey];
    }
    
    static int saltLength = 32;
    static int ivLength = 16;
    
    NSMutableData *salt = [NSMutableData data];
    NSMutableData *iv = [NSMutableData data];
    
    [self getRandomArray:salt len:saltLength];
    [self getRandomArray:iv len:ivLength];
    
    NSString *cipherStr = [KQCSecure encrypt:plainText aes256Key:secureKeyGroup.aesKey salt:salt iv:iv rounds:NetAESLoopCount];
    if ([NSString kqc_isBlank:cipherStr]) {
        return nil;
    }
    
    return KQC_FORMAT(@"%@]%@]%@", [salt base64EncodedString], [iv base64EncodedString], cipherStr);
}

- (void)getRandomArray:(NSMutableData *)data len:(int)len{
    for (int i = 0; i < len; i++) {
        char temp = [KQCMath getRandomNumber:0 to:255];
        [data appendBytes:&temp length:1];
    }
}

- (NSString *)encryptDataByAES:(NSData *)data{
    return [KQCSecure encryptData:data aes256Key:_aesKey];
}

- (NSString *)decryptByAES:(NSString *)cipherStr{
    return [self decryptByAES:cipherStr isCacheData:YES];
}

- (NSString *)decryptByAES:(NSString *)cipherStr isCacheData:(BOOL)isCacheData{
    if (isCacheData) {
        return [KQCSecure decrypt:cipherStr aes256Key:_aesKey];
    }
    
    NSArray *fields = [cipherStr componentsSeparatedByString:@"]"];
    if (fields.count != 3) {
        return nil;
    }
    
    NSData *salt = [NSData dataFromBase64String:fields[0]];
    NSData *iv = [NSData dataFromBase64String:fields[1]];
    return [KQCSecure decrypt:fields[2] aes256Key:secureKeyGroup.aesKey salt:salt iv:iv rounds:NetAESLoopCount];
}

- (NSData *)decryptDataByAES:(NSString *)cipherStr{
    return [KQCSecure decryptData:cipherStr aes256Key:_aesKey];
}

@end
