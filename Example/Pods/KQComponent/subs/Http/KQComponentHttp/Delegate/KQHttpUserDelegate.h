//
//  KQHttpUserDelegate.h
//  KQComponentHttp
//
//  Created by xy on 2017/11/8.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KQHttpUserDelegate <NSObject>

/**
 获取用户账号
 
 @return 账号
 */
- (NSString *)userName;

/**
 获取登录token
 
 @return token
 */
- (NSString *)loginToken;

/**
 修改登录token
 
 @param token token
 */
- (void)loginTokenChanged:(NSString *)token;

/**
 获取用户本地标示
 
 @return 本地标示
 */
- (NSString *)userId;

/**
 修改本地标示
 
 @param userId 本地标示
 */
- (void)userIdChanged:(NSString *)userId;

/**
 token失效时的处理
 
 */
- (void)treatedWithFailureToken;

@end
