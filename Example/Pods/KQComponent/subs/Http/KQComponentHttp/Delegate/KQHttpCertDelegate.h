//
//  KQPDigitalCertDelegate.h
//  KQProtocol
//
//  Created by xy on 2016/12/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KQHttpCertDelegate <NSObject>

/**
 该业务是否电子证书需要签名
 
 @param bizType 业务号
 
 @return 是否要签名
 */
- (BOOL)httpRequestNeedCertSign:(NSString *)bizType;

/**
 用电子证书进行签名
 
 @param srcStr 待签名源串
 
 @return 签名值
 */
- (NSString *)certSign:(NSString *)srcStr;

@end
