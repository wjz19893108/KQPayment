//
//  KQBSwipeCardSecureManager.m
//  KQBusiness
//
//  Created by building wang on 2018/9/17.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "KQBSwipeCardSecureManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>

@interface KQBSwipeCardSecureManager () {
    SecKeyRef publicServerRSA;
    SecKeyRef privateClientRSA;
    SecKeyRef publicBaseKey;
    KQPSecureKeyGroup *secureKeyGroup; // 刷卡相关的秘钥(独立于钱包内部的秘钥)
}
@end

@implementation KQBSwipeCardSecureManager

const char SwipeCardAlgorithmData[] = {0x30, 0x81, 0x9F, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x81, 0x8D, 0x00}; // rsa固定算法标志
static NSString *KQ99BillPublicPEMStr = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCvkhkxipVQPKLgZM2WInhbO4RGI3AZs73y2gqjCnSerD3IQ1TITm097Z3hgJiddBZQ9eICkUUY8CyTw30HgmuAN0TxRBTczAZUu0GX/xyNAj2Hg1U5jQjRZkVdmB4golJUvLAvMmMEQXCevawN7TU0Xhj0BWxToUtZ1qDGHUMCrwIDAQAB";

//static NSString *UserAESAppendKey = @"Aj2Hg1U5ju0GEQXCevaw7TczA";

static NSString *ServerPublicKeyTag = @"com.99bill.server.swipeCard.publicKey";
static NSString *LocalPublicKeyTag = @"com.99bill.local.swipeCard.publickey";
static NSString *LocalPrivateKeyTag = @"com.99bill.local.swipeCard.privateKey";
static NSString *ServerBasePublicKeyTag = @"com.99bill.base.swipeCard.publicKey";
//static NSString *AESKeyTag = @"com.99bill.local.privateKey.swipeCard.aesKey";

static NSInteger NetAESKeyLength = 20;
static NSInteger NetAESLoopCount = 100;

SYNTHESIZE_SINGLETON_FOR_CLASS(KQBSwipeCardSecureManager);

#pragma mark- 读取存储的客户端私钥和服务端公钥
- (instancetype)init{
    self = [super init];
    if (self) {
//        SwipeCardHttpManager.swipeCardSecureDelegate = self;
        
        NSData *publicData = [NSData dataFromBase64String:KQ99BillPublicPEMStr];
        NSData *data = [NSData dataWithBytes:publicData.bytes + sizeof(SwipeCardAlgorithmData) length:publicData.length - sizeof(SwipeCardAlgorithmData)];
        publicBaseKey = [self convertData2SecType:data tag:ServerBasePublicKeyTag];
    }
    return self;
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
        publicServerData = [NSData dataWithBytes:publicServerData.bytes + sizeof(SwipeCardAlgorithmData) length:publicServerData.length - sizeof(SwipeCardAlgorithmData)];
    }
    publicServerRSA = [self convertData2SecType:publicServerData attrKeyClass:kSecAttrKeyClassPublic tag:ServerPublicKeyTag];
    
    return (publicServerRSA != NULL);
}

- (KQPSecureKeyGroup *)deviceSecureKey:(BOOL *)isNewCreate {
    if (secureKeyGroup) {
        if (isNewCreate) {
            *isNewCreate = NO;
        }
        return secureKeyGroup;
    }
    
    NSString *privateKey = nil;
    NSString *publicKey = nil;
    [SwipeCardSecureManager createRSAKeyPair:&privateKey publicKey:&publicKey];
    
    if ([NSString kqc_isBlank:privateKey]
        || [NSString kqc_isBlank:publicKey]) {
        return nil;
    }
    DLog(@"新生成私钥：%@", privateKey);
    [self resetClientPrivateKey:privateKey];
    
    NSMutableData *tempAesKey = [NSMutableData data];
    [self getRandomArray:tempAesKey len:(int)NetAESKeyLength];
    
    secureKeyGroup = [[KQPSecureKeyGroup alloc] init];
    secureKeyGroup.clientPrivateKey = privateKey;
    secureKeyGroup.clientPublicKey = publicKey;
    secureKeyGroup.serverPublicKey = nil;
    secureKeyGroup.aesKey = [tempAesKey base64EncodedString];
    if (isNewCreate) {
        *isNewCreate = YES;
    }
    return secureKeyGroup;
}

- (void)resetData {
    DLog(@"清除本地公私钥：%@", secureKeyGroup.clientPrivateKey);
    
    if (privateClientRSA) {
        privateClientRSA = NULL;
    }
    
    if (publicServerRSA) {
        publicServerRSA = NULL;
    }
    secureKeyGroup = nil;
}

- (BOOL)setServerPublicKey:(NSString *)publicKey {
    secureKeyGroup.serverPublicKey = publicKey;
    if ([self resetServerPublicKey:secureKeyGroup.serverPublicKey]){
        return YES;
    }
    [self resetData];
    
    return NO;
}

- (NSData *)sign:(NSData *)srcData {
//    DLog(@"本地签名私钥：%@", secureKeyGroup.clientPrivateKey);
    return [KQCSecure sign:srcData privateKey:privateClientRSA];
}

- (BOOL)verify:(NSData *)rawData signData:(NSData *)signData{
    return [KQCSecure verify:rawData signData:signData publicKey:publicServerRSA];
}

#pragma mark - 获取秘钥接口加密
- (NSString *)encryptBeforeGetSecretKey:(NSString *)plainText {
    if (!plainText) {
        return nil;
    }

    if (!publicBaseKey) {
        return nil;
    }
    
    return [KQCSecure encrypt:plainText publicKey:publicBaseKey];
}

#pragma mark - 获取秘钥之后的报文加密
- (NSString *)encryptAfterGetSecretKey:(NSString *)plainText {
    return [KQCSecure encrypt:plainText publicKey:publicServerRSA];
}

#pragma mark - 获取秘钥之后的报文解密
- (NSString *)decryptGetSecretKey:(NSString *)cipherStr {
    return [KQCSecure decrypt:cipherStr privateKey:privateClientRSA];
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
    [publicKeyData appendBytes:SwipeCardAlgorithmData length:sizeof(SwipeCardAlgorithmData)];
    [publicKeyData appendData:publicSecKeyData];
    *publicKey = [publicKeyData base64EncodedString];
    
    NSData *privateSecKeyData = [self convertSecType2Data:privateSecKey attrKeyClass:kSecAttrKeyClassPrivate tag:LocalPrivateKeyTag];
    *privateKey = [privateSecKeyData base64EncodedString];
    
    return YES;
}

#pragma mark - AES加解密
- (NSString *)encryptByAES:(NSString *)plainText{
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

- (NSString *)decryptByAES:(NSString *)cipherStr{
    if ([NSString kqc_isBlank:cipherStr]) {
        return nil;
    }
    
    NSArray *fields = [cipherStr componentsSeparatedByString:@"]"];
    if (fields.count != 3) {
        return nil;
    }
    
    NSData *salt = [NSData dataFromBase64String:fields[0]];
    NSData *iv = [NSData dataFromBase64String:fields[1]];
    return [KQCSecure decrypt:fields[2] aes256Key:secureKeyGroup.aesKey salt:salt iv:iv rounds:NetAESLoopCount];
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
@end
