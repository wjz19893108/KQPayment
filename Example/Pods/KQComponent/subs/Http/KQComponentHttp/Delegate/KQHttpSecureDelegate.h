//
//  KQPSecureCertDelegate.h
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KQPSecureKeyGroup;
@protocol KQHttpSecureDelegate <NSObject>

- (NSString *)encryptByAES:(NSString *)srcStr;

/**
 用客户端自己生产的私钥签名

 @param srcData 待签名源串

 @return 签名值
 */
- (NSData *)sign:(NSData *)srcData;

/**
 获取设备密钥组
 
 @param isNewCreate 是否是新生成的 -out
 @return 密钥组
 */
- (KQPSecureKeyGroup *)deviceSecureKey:(BOOL *)isNewCreate;

/**
 重置服务端公钥

 @param publicKey 服务端公钥
 @return 是否成功
 */
- (BOOL)setServerPublicKey:(NSString *)publicKey;

/**
 验证签名

 @param rawData 源数据
 @param signData 签名值
 @return 是否符合
 */
- (BOOL)verify:(NSData *)rawData signData:(NSData *)signData;

/**
 重置密钥数据
 */
- (void)resetData;

@end
