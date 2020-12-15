//
//  KQComponetUserInfoDelegate.h
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KQComponetUserStatusDelegate <NSObject>

/**
 获取用户是否登陆

 @return YES：已登录 NO：未登录
 */
- (BOOL)isLogin;

/**
 通知APP，需要用户登录

 @param resultBlock 登录结果回调，isSuccess说明：YES-登录成功 NO-登录失败
 */
- (void)userShouldLogin:(void (^)(BOOL isSuccess))resultBlock;

/**
 通知APP，需要登出

 @param code 登出原因代码
 */
- (void)userShouldLogout:(NSString *)code;

/**
 通知APP，需要用户实名

 @param resultBlock 实名结果回调，isSuccess说明：YES-实名成功 NO-实名失败
 @param tips 实名时需要提示给用户的信息
 */
- (void)userShouldRealName:(void (^)(BOOL isSuccess))resultBlock tips:(NSString *)tips;

/**
 开放给第三方系统使用的用户身份标识

 @return 身份标识
 */
- (NSString *)thirdIdentity;

@end
