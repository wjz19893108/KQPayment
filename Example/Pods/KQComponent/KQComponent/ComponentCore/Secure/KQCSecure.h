//
//  KQCSecure.h
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQCSecure : NSObject

/**
 生成公私钥对
 
 @param privateKey 私钥 out
 @param publicKey 公钥 out
 @return 是否生成成功
 */
+ (BOOL)generateRSAPrivateKey:(SecKeyRef *)privateKey publicKey:(SecKeyRef *)publicKey keyPairLength:(NSInteger)keyPairLength;

/**
 用私钥签名

 @param data  待签名字串
 @param privateKey 私钥

 @return 签名数据流
 */
+ (NSData *)sign:(NSData *)data privateKey:(SecKeyRef)privateKey;

/**
 验签
 
 @param rawData  待验证数据
 @param publicKey 公钥
 
 @return 是否成功
 */
+ (BOOL)verify:(NSData *)rawData signData:(NSData *)signData publicKey:(SecKeyRef)publicKey;

/**
 用公钥加密

 @param plainText 明文
 @param publicKey 公钥

 @return 密文
 */
+ (NSString *)encrypt:(NSString *)plainText publicKey:(SecKeyRef)publicKey;

/**
 用私钥解密

 @param cipherStr  密文
 @param privateKey 私钥

 @return 明文
 */
+ (NSString *)decrypt:(NSString *)cipherStr privateKey:(SecKeyRef)privateKey;

/**
 计算MD5值

 @param srcStr 源字符串

 @return MD5值
 */
+ (NSString *)stringFromMD5:(NSString *)srcStr;

/**
 aes加密

 @param data 明文字节流
 @param key  密钥

 @return 密文
 */
+ (NSString *)encryptData:(NSData *)data aes256Key:(NSString *)key;

/**
 aes加密

 @param plainText 明文字符串
 @param key       密钥

 @return 密文
 */
+ (NSString *)encrypt:(NSString *)plainText aes256Key:(NSString *)key;

/**
 指定参数进行aes加密

 @param plainText 原文
 @param key 密钥
 @param salt salt
 @param iv iv
 @param rounds 循环加密次数
 @return 密文
 */
+ (NSString *)encrypt:(NSString *)plainText aes256Key:(NSString *)key salt:(NSData *)salt iv:(NSData *)iv rounds:(NSInteger)rounds;

/**
 aes解密

 @param ciphertexts 密文
 @param key         密钥

 @return 明文字节流
 */
+ (NSData *)decryptData:(NSString *)ciphertexts aes256Key:(NSString *)key;

/**
 aes解密

 @param ciphertexts 密文
 @param key         密钥

 @return 明文字符串
 */
+ (NSString *)decrypt:(NSString *)ciphertexts aes256Key:(NSString *)key;

/**
 指定参数进行aes解密

 @param ciphertexts 密文
 @param key 密钥
 @param salt salt
 @param iv iv
 @param rounds 循环次数
 @return 明文
 */
+ (NSString *)decrypt:(NSString *)ciphertexts aes256Key:(NSString *)key salt:(NSData *)salt iv:(NSData *)iv rounds:(NSInteger)rounds;

/**
 des加密

 @param plainText 明文
 @param key       秘钥

 @return 密文
 */
+ (NSString *)encrypt:(NSString *)plainText desKey:(NSString *)key;

/**
 des加密不带向量
 
 @param plainText 明文
 @param key       秘钥
 
 @return 密文
 */

+ (NSString *)encryptWithoutIv:(NSString *)plainText desKey:(NSString *)key;


/**
 des解密不带向量
 
 @param encrypedText 密文
 @param key 秘钥
 @return 明文
 */
+ (NSString *)decryptWithoutIv:(NSString *)encrypedText desKey:(NSString *)key;

/**
 用sha1算法进行摘要

 @param str 源字符串

 @return 摘要
 */
+ (NSString *)digestWithSHA1:(NSString *)str;

/**
 用sha256算法进行摘要

 @param str 源字符串
 @return 摘要
 */
+ (NSString *)digestWithSHA256:(NSString *)str;

@end
