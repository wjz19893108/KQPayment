//
//  KQCSecure.m
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCSecure.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonKeyDerivation.h>

const NSUInteger kAlgorithmKeySizeOfKQSecure = kCCKeySizeAES256;
const NSUInteger kPBKDFRoundsOfKQSecure = 10000;  // ~80ms on an iPhone 4

static Byte saltBuff[] = {0,1,2,3,4,5,6,7,8,9,0xA,0xB,0xC,0xD,0xE,0xF};

static Byte ivBuff[]   = {0xA,1,0xB,5,4,0xF,7,9,0x17,3,1,6,8,0xC,0xD,91};

@implementation KQCSecure

+ (BOOL)generateRSAPrivateKey:(SecKeyRef *)privateKey publicKey:(SecKeyRef *)publicKey keyPairLength:(NSInteger)keyPairLength{
    if (*privateKey) {
        CFRelease(*privateKey);
        *privateKey = NULL;
    }
    
    if (*publicKey) {
        CFRelease(*publicKey);
        *publicKey = NULL;
    }
    
    NSDictionary *keyPairAttr = @{(__bridge id)kSecAttrKeyType:(__bridge id)kSecAttrKeyTypeRSA,
                                  (__bridge id)kSecAttrKeySizeInBits:@(keyPairLength)};
    OSStatus status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, publicKey, privateKey);
    return status == noErr;
}

#pragma mark - 公私钥加解密、签名
+ (NSData *)sign:(NSData *)data privateKey:(SecKeyRef)privateKey{
    if (!privateKey) {
        return nil;
    }
    
    if (!data) {
        return nil;
    }
    
    uint8_t *hashBytes = (uint8_t *)malloc(CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t));
    memset(hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
    
    CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    CC_SHA1_Update(&ctx, data.bytes, (CC_LONG)data.length);
    CC_SHA1_Final(hashBytes, &ctx);
    
    size_t length = SecKeyGetBlockSize(privateKey);
    uint8_t *sigData =  (uint8_t *)malloc(length * sizeof(uint8_t));
    memset(sigData, 0, length);
    OSStatus status = SecKeyRawSign(privateKey, kSecPaddingPKCS1SHA1, hashBytes, CC_SHA1_DIGEST_LENGTH, sigData, &length);
    if (status != noErr) {
        if (hashBytes) {
            free(hashBytes);
        }
        
        if (sigData) {
            free(sigData);
        }
        return nil;
    }
    
    NSData *encryptedData = [NSData dataWithBytes:sigData length:length];
    if (hashBytes) {
        free(hashBytes);
    }
    
    if (sigData) {
        free(sigData);
    }
    return encryptedData;
}

+ (BOOL)verify:(NSData *)rawData signData:(NSData *)signData publicKey:(SecKeyRef)publicKey{
    if (!publicKey || !signData || !rawData || signData.length == 0 || rawData.length == 0) {
        return NO;
    }
    
    uint8_t *hashBytes = (uint8_t *)malloc(CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t));
    memset(hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
    
    CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    CC_SHA1_Update(&ctx, rawData.bytes, (CC_LONG)rawData.length);
    CC_SHA1_Final(hashBytes, &ctx);
    
    OSStatus status = SecKeyRawVerify(publicKey, kSecPaddingPKCS1SHA1, hashBytes, CC_SHA1_DIGEST_LENGTH, signData.bytes, SecKeyGetBlockSize(publicKey));
    if (hashBytes) {
        free(hashBytes);
    }
    
    return status == noErr;
}

+ (NSString *)encrypt:(NSString *)plainText publicKey:(SecKeyRef)publicKey{
    if (!publicKey) {
        return nil;
    }
    
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    size_t cipherSize = SecKeyGetBlockSize(publicKey);
    
    double totalLength = plainData.length;
    size_t blockSize = cipherSize - 12;//注：cipherBufferSize - 11有误。
    size_t blockCount = (size_t)ceil(totalLength / blockSize);
    NSMutableData *encryptedData = [NSMutableData data];
    // 分段加密
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        // 数据段的实际大小
        NSInteger dataSegmentRealSize = MIN(blockSize, [plainData length] - loc);
        // 截取需要加密的数据段
        NSData *dataSegment = [plainData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        //加密后保存
        unsigned char cipherText[cipherSize + 1];
        
        
        OSStatus status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, dataSegment.bytes, dataSegment.length, cipherText, &cipherSize);
        if (status == noErr) {
            NSData *encrypted = [NSData dataWithBytes:cipherText length:cipherSize];
            [encryptedData appendData:encrypted];
        }
        
    }
    
    NSString* encryptedStr = [encryptedData base64EncodedString];
    return encryptedStr;
}

+ (NSString *)decrypt:(NSString *)cipherStr privateKey:(SecKeyRef)privateKey{
    if (!privateKey) {
        return nil;
    }
    
    if ([NSString kqc_isBlank:cipherStr]) {
        return nil;
    }
    
    NSData *cipherData = [NSData dataFromBase64String:cipherStr];
    
    size_t plainTextLen = SecKeyGetBlockSize(privateKey) - 12;
    unsigned char *plainText =  (unsigned char *)malloc(plainTextLen);
    memset(plainText, 0, plainTextLen);
    
    OSStatus returnCode = SecKeyDecrypt(privateKey, kSecPaddingPKCS1, cipherData.bytes, cipherData.length, plainText, &plainTextLen);
    if (returnCode != noErr) {
        if (plainText) {
            free(plainText);
        }
        return nil;
    }
    NSString *decryptString = [[NSString alloc] initWithBytes:plainText length:plainTextLen encoding:NSUTF8StringEncoding];
    free(plainText);
    
    return decryptString;
}

#pragma mark - MD5
+ (NSString *)stringFromMD5:(NSString *)srcStr {
    if(srcStr == nil || [srcStr length] == 0)
        return nil;
    
    const char *value = [srcStr UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    __autoreleasing NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

#pragma mark - AES256加解密
+ (NSData *)aesKeyData:(NSString *)key salt:(NSData *)salt rounds:(int)rounds{
    if (!salt) {
        salt = [NSData dataWithBytes:saltBuff length:kCCKeySizeAES128];
    }
    
    NSMutableData *derivedKey = [NSMutableData dataWithLength:kAlgorithmKeySizeOfKQSecure];
    int result = CCKeyDerivationPBKDF(kCCPBKDF2,        // algorithm算法
                                      key.UTF8String,  // password密码
                                      key.length,      // passwordLength密码的长度
                                      salt.bytes,           // salt内容
                                      salt.length,          // saltLen长度
                                      kCCPRFHmacAlgSHA1,    // PRF
                                      (rounds == -1) ? kPBKDFRoundsOfKQSecure : rounds,         // rounds循环次数
                                      derivedKey.mutableBytes, // derivedKey
                                      derivedKey.length);   // derivedKeyLen derive:出自
    if (result != kCCSuccess) {
        DLog(@"Unable to create AES key for spassword: %d", result);
    }
    
    return derivedKey;
}

+ (NSString *)encrypt:(NSString *)plainText aes256Key:(NSString *)key{
    return [KQCSecure encrypt:plainText aes256Key:key salt:nil iv:nil rounds:-1];
}

+ (NSString *)encrypt:(NSString *)plainText aes256Key:(NSString *)key salt:(NSData *)salt iv:(NSData *)iv rounds:(NSInteger)rounds{
    if (!plainText || [plainText isEqualToString:@""]) {
        return @"";
    }
    
    if (!key || [key isEqualToString:@""]) {
        return nil;
    }
    
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    return [KQCSecure encryptData:plainData aes256Key:key salt:salt iv:iv rounds:rounds];
    
}

+ (NSString *)decrypt:(NSString *)ciphertexts aes256Key:(NSString *)key{
    return [KQCSecure decrypt:ciphertexts aes256Key:key salt:nil iv:nil rounds:-1];
}

+ (NSString *)decrypt:(NSString *)ciphertexts aes256Key:(NSString *)key salt:(NSData *)salt iv:(NSData *)iv rounds:(NSInteger)rounds{
    NSData *data = [KQCSecure decryptData:ciphertexts aes256Key:key salt:salt iv:iv rounds:rounds];
    if (!data) {
        return @"";
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)encryptData:(NSData *)data aes256Key:(NSString *)key{
    return [KQCSecure encryptData:data aes256Key:key salt:nil iv:nil rounds:-1];
}

+ (NSString *)encryptData:(NSData *)data aes256Key:(NSString *)key salt:(NSData *)salt iv:(NSData *)iv rounds:(NSInteger)rounds{
    char keyPtr[kAlgorithmKeySizeOfKQSecure+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    bzero(buffer, sizeof(buffer));
    
    size_t numBytesEncrypted = 0;
    NSData *aesKey = [self aesKeyData:key salt:salt rounds:(int)rounds];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          aesKey.bytes, kAlgorithmKeySizeOfKQSecure,
                                          iv ? iv.bytes : ivBuff,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return [encryptData base64EncodedString];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

+ (NSData *)decryptData:(NSString *)ciphertexts aes256Key:(NSString *)key{
    return [KQCSecure decryptData:ciphertexts aes256Key:key salt:nil iv:nil rounds:-1];
}

+ (NSData *)decryptData:(NSString *)ciphertexts aes256Key:(NSString *)key salt:(NSData *)salt iv:(NSData *)iv rounds:(NSInteger)rounds{
    if (!ciphertexts || [ciphertexts isEqualToString:@""]) {
        return nil;
    }
    if (!key || [key isEqualToString:@""]) {
//        DLog(@"===解密因子异常\n");
        return nil;
    }
    NSData *cipherData = [NSData dataFromBase64String:ciphertexts];
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kAlgorithmKeySizeOfKQSecure+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    NSUInteger dataLength = [cipherData length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    NSData *aesKey = [self aesKeyData:key salt:salt rounds:(int)rounds];
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          aesKey.bytes, kAlgorithmKeySizeOfKQSecure,
                                          iv ? iv.bytes : ivBuff ,/* initialization vector (optional) */
                                          [cipherData bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        return encryptData;
    }
    
    free(buffer); //free the buffer;
    return nil;
}

#pragma mark - des加解密
+ (NSString *)encrypt:(NSString *)plainText desKey:(NSString *)key{
    if ([NSString  kqc_isBlank:plainText]|| [NSString kqc_isBlank:key]) {
        return nil;
    }
    
    const char *keyData = [key UTF8String];
    const char *textData = [plainText UTF8String];
    NSInteger dataLength = strlen(textData);
    const char *ivData = [@"12345678" UTF8String];
    size_t retLength = strlen(textData);
    while (retLength % kCCBlockSizeDES != 0) { // 补齐到8的整数倍
        retLength ++;
    }
    
    unsigned char *retData = (unsigned char *)malloc(retLength * sizeof(unsigned char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding ,
                                          keyData, kCCBlockSizeDES,
                                          ivData,
                                          textData, dataLength,
                                          retData, retLength,
                                          &numBytesEncrypted);
    NSData *ret;
    if (cryptStatus == kCCSuccess && numBytesEncrypted > 0) {
        ret = [NSData dataWithBytes:retData length:numBytesEncrypted];
    }
    //iOS7兼容性修改 feng.zou 2016-03-28
    //NSString *result = [ret base64Encoding];
    NSString *result = [ret base64EncodedStringWithOptions:0];
    free(retData);
    
    return result;
    
}

#pragma mark - des加解密
+ (NSString *)encryptWithoutIv:(NSString *)plainText desKey:(NSString *)key{
    if ([NSString  kqc_isBlank:plainText]|| [NSString kqc_isBlank:key]) {
        return nil;
    }
    
    const char *keyData = [key UTF8String];
    const char *textData = [plainText UTF8String];
    NSInteger dataLength = strlen(textData);
    size_t retLength = strlen(textData);
    if (retLength % kCCBlockSizeDES == 0) {
        retLength+=kCCBlockSizeDES;
    } else {
        while (retLength % kCCBlockSizeDES != 0) { // 补齐到8的整数倍
            retLength ++;
        }
    }
    
    unsigned char *retData = (unsigned char *)malloc(retLength * sizeof(unsigned char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode ,
                                          keyData, kCCBlockSizeDES,
                                          nil,
                                          textData, dataLength,
                                          retData, retLength,
                                          &numBytesEncrypted);
    NSData *ret;
    if (cryptStatus == kCCSuccess && numBytesEncrypted > 0) {
        ret = [NSData dataWithBytes:retData length:numBytesEncrypted];
    }
    //iOS7兼容性修改 feng.zou 2016-03-28
    //NSString *result = [ret base64Encoding];
    NSString *result = [ret base64EncodedStringWithOptions:0];
    free(retData);
    
    return result;
}

+ (NSString *)decryptWithoutIv:(NSString *)encrypedText desKey:(NSString *)key {
    if ([NSString  kqc_isBlank:encrypedText]|| [NSString kqc_isBlank:key]) {
        return nil;
    }
    
    NSData *cipherData = [NSData dataFromBase64String:encrypedText];
    NSUInteger dataLength = [cipherData length];
    
    const char *keyData = [key UTF8String];
    
    if (dataLength % kCCBlockSizeDES != 0) {
        return nil;
    }
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode ,
                                          keyData, kCCBlockSizeDES,
                                          nil,
                                          [cipherData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

#pragma  mark - /** 摘要算法 **/
+ (NSString *)digestWithSHA1:(NSString *)str{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

+ (NSString *)digestWithSHA256:(NSString *)str{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

@end
