//
//  KQBSwipeCardSecureManager.h
//  KQBusiness
//
//  Created by building wang on 2018/9/17.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SwipeCardSecureManager  [KQBSwipeCardSecureManager sharedKQBSwipeCardSecureManager]

@interface KQBSwipeCardSecureManager : NSObject

+ (KQBSwipeCardSecureManager *)sharedKQBSwipeCardSecureManager;

/**
 重置密钥数据
 */
- (void)resetData;

/**
 生产RSA公私钥对
 
 @param privateKey 私钥，通过该值返回，base64编码的字符串
 @param publicKey  公钥，通过该值返回，base64编码的字符串
 
 @return 是否成功
 */
- (BOOL)createRSAKeyPair:(NSString **)privateKey publicKey:(NSString **)publicKey;

/**
 初始化客户端的私钥
 
 @param privateKey 私钥base64编码的字符串
 
 @return 是否成功
 */
- (BOOL)resetClientPrivateKey:(NSString *)privateKey;

/**
 初始化服务端的公钥
 
 @param publicKey 公钥base64编码的字符串
 
 @return 是否成功
 */
- (BOOL)resetServerPublicKey:(NSString *)publicKey;

/**
 获取秘钥接口加密，用99bill的固定公钥
 
 @param plainText 明文
 
 @return 密文
 */
- (NSString *)encryptBeforeGetSecretKey:(NSString *)plainText;

/**
 用初始化的AES密钥加密
 
 @param plainText 明文
 
 @return 密文
 */
- (NSString *)encryptByAES:(NSString *)plainText;

/**
 AES解密，密钥为网络密钥，即密钥交换的密钥
 
 @param cipherStr 密文
 
 @return 明文
 */
- (NSString *)decryptByAES:(NSString *)cipherStr;

/**
 用客户端的私钥进行签名
 
 @param srcData 待签名数据
 
 @return 签名结果
 */
- (NSData *)sign:(NSData *)srcData;

- (BOOL)verify:(NSData *)rawData signData:(NSData *)signData;

- (BOOL)setServerPublicKey:(NSString *)publicKey;

- (KQPSecureKeyGroup *)deviceSecureKey:(BOOL *)isNewCreate;
@end
