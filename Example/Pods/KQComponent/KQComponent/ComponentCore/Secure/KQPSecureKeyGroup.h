//
//  KQCSecureKeyGroup.h
//  KQProtocol
//
//  Created by xy on 2017/3/7.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQPSecureKeyGroup : NSObject

/**
 客户端私钥
 */
@property(nonatomic, strong) NSString *clientPrivateKey;

/**
 客户端公钥
 */
@property(nonatomic, strong) NSString *clientPublicKey;

/**
 服务端公钥
 */
@property(nonatomic, strong) NSString *serverPublicKey;

/**
 协商的对称密钥
 */
@property(nonatomic, strong) NSString *aesKey;

/**
 预置公钥加密后的AES密钥的密文
 */
@property(nonatomic, strong) NSString *cipherAesKey;

/**
 AES加密后客户端公钥的密文
 */
@property(nonatomic, strong) NSString *cipherClientPublicKey;

@end
