//
//  KQPSwipeCardSecureDelegate.h
//  KQProtocol
//
//  Created by building wang on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

@class KQPSecureKeyGroup;
@protocol KQPSwipeCardSecureDelegate <NSObject>

/**
 解密

 @param srcStr 待解密源串
 @return 明文
 */
- (NSString *)swipeCard_decryptByAES:(NSString *)srcStr;

/**
 交换秘钥前加密

 @param srcStr 待加密源串
 @return 秘文
 */
- (NSString *)swipeCard_encryptBeforeGetSecretKey:(NSString *)srcStr;

/**
 交换秘钥后加密
 
 @param srcStr 待加密源串
 @return 秘文
 */
- (NSString *)swipeCard_encryptByAES:(NSString *)srcStr;

/**
 用客户端自己生产的私钥签名
 
 @param srcData 待签名源串
 
 @return 签名值
 */
- (NSData *)swipeCard_sign:(NSData *)srcData;

/**
 获取设备密钥组
 
 @return 密钥组
 */
- (KQPSecureKeyGroup *)swipeCard_deviceSecureKey:(BOOL *)isNewCreate;

/**
 重置服务端公钥
 
 @param publicKey 服务端公钥
 @return 是否成功
 */
- (BOOL)swipeCard_setServerPublicKey:(NSString *)publicKey;

/**
 验证签名
 
 @param rawData 源数据
 @param signData 签名值
 @return 是否符合
 */
- (BOOL)swipeCard_verify:(NSData *)rawData signData:(NSData *)signData;

/**
 重置密钥数据
 */
- (void)swipeCard_resetData;

@end
