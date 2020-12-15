//
//  KQBSecureManager.h
//  KQBusiness
//
//  Created by xy on 2016/10/26.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQBSecureCacheDelegate.h"

#define KQB_Manager_Secure  [KQBSecureManager sharedKQBSecureManager]

@interface KQBSecureManager : NSObject

@property (nonatomic, weak) id<KQBSecureCacheDelegate> cacheDelegate;

+ (KQBSecureManager *)sharedKQBSecureManager;

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
//- (BOOL)resetClientPrivateKey:(NSString *)privateKey;

/**
 初始化服务端的公钥

 @param publicKey 公钥base64编码的字符串

 @return 是否成功
 */
- (BOOL)setServerPublicKey:(NSString *)publicKey;

/**
 初始化AES的密钥

 @param aesKey aeskey

 @return 是否成功
 */
- (BOOL)resetAESKey:(NSString *)aesKey;

/**
 登录前加密，用99bill的固定公钥

 @param plainText 明文

 @return 密文
 */
- (NSString *)encryptBeforeLogin:(NSString *)plainText;

/**
 登录后加密，用服务端的公钥

 @param plainText 明文

 @return 密文，失败返回nil
 */
//- (NSString *)encryptAfterLogin:(NSString *)plainText;

/**
 登录后解密，用客户端的私钥

 @param cipherStr 密文

 @return 明文，失败返回nil
 */
//- (NSString *)decryptAfterLogin:(NSString *)cipherStr;

/**
 用初始化的AES密钥加密

 @param plainText 明文

 @return 密文
 */
- (NSString *)encryptByAES:(NSString *)plainText;

/**
 AES加密
 
 @param plainText 明文
 @param isCacheData 是否为缓存数据，密钥不一样
 @return 密文
 */
- (NSString *)encryptByAES:(NSString *)plainText isCacheData:(BOOL)isCacheData;

/**
 用初始化的AES密钥加密

 @param data 明文

 @return 密文
 */
- (NSString *)encryptDataByAES:(NSData *)data;

/**
 AES解密，密钥为网络密钥，即密钥交换的密钥

 @param cipherStr 密文

 @return 明文
 */
- (NSString *)decryptByAES:(NSString *)cipherStr;

/**
 AES解密

 @param cipherStr 密文
 @param isCacheData 是否为缓存数据，密钥不一样
 @return 明文
 */
- (NSString *)decryptByAES:(NSString *)cipherStr isCacheData:(BOOL)isCacheData;

/**
 用初始化的AES密钥AES解密

 @param cipherStr 密文

 @return 明文
 */
- (NSData *)decryptDataByAES:(NSString *)cipherStr;

/**
 用客户端的私钥进行签名

 @param srcData 待签名数据

 @return 签名结果
 */
- (NSData *)sign:(NSData *)srcData;

/**
 获取设备密钥组

 @param isNewCreate 输出，是否为本次新创建
 @return 密钥组
 */
- (KQPSecureKeyGroup *)deviceSecureKey:(BOOL *)isNewCreate;

/**
 验证签名

 @param rawData 签名源串
 @param signData 签名值
 @return 是否通过
 */
- (BOOL)verify:(NSData *)rawData signData:(NSData *)signData;

@end
