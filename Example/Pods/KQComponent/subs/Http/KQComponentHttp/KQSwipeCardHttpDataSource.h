//
//  KQSwipeCardHttpDataSource.h
//  KQProtocol
//
//  Created by building wang on 2018/9/18.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQHttpMacro.h"

@protocol KQSwipeCardHttpDataSource <NSObject>

/**
 根据网络请求业务号获取对应的服务类别
 
 @param bizType 业务号
 
 @return 服务器对应类别
 */
- (KQSwipeCardHttpServiceType)serviceType:(NSString *)bizType;

/**
 根据url type获取对应的url地址
 
 @param serviceType 指定的serviceType
 
 @return url地址
 */
- (NSString *)serviceUrl:(KQSwipeCardHttpServiceType)serviceType;

/**
 服务器版本号
 
 @param serviceType 指定的serviceType
 
 @return 版本号
 */
- (NSString *)networkVersion:(KQSwipeCardHttpServiceType)serviceType;

/**
 APP版本号
 
 @return 版本
 */
- (NSString *)appVersion;

/**
 是否需要签名
 
 @param bizType 业务号
 
 @return 是否要签名
 */
//- (BOOL)needSign:(NSString *)bizType;

@optional
/**
 自定义pb报文的头
 @param headerDic 已经组织好的header
 */
- (void)customerHeader:(NSMutableDictionary *)headerDic bizType:(NSString *)bizType;

/**
 给请求参数做加密处理
 @param paramDic 待加密的参数
 @param bizCode  业务类型
 @return 加密的字参字典
 */
- (NSString *)encryptParam:(NSDictionary *)paramDic bizCode:(NSString *)bizCode;

/**
 发送网络请求时，是否忽略验证服务端证书
 
 @return YES:忽略证书 NO:验证证书
 */
- (BOOL)ignoreNetworkCert;

/**
 给返回参数做解密处理
 @param paramString 待解密的参数
 @param bizCode  业务类型
 @return 要解密的参数
 */
- (NSString *)decryptParam:(NSString *)paramString bizCode:(NSString *)bizCode;
@end
