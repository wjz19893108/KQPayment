//
//  KQBUserManager.h
//  KQBusiness
//
//  Created by xy on 2016/10/26.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQBUserInfo.h"

#define KQB_Manager_UserInfo    [KQBUserManager sharedKQBUserManager]
#define KQB_CurrentUser         [KQBUserManager sharedKQBUserManager].userInfo

@class Content;
@interface KQBUserManager : NSObject

/**
 当前的用户
 */
@property (nonatomic, strong) KQBUserInfo *userInfo;


+ (KQBUserManager *)sharedKQBUserManager;

/**
 读取用户缓存数据
 */
+ (BOOL)loadUserData;

/**
 登陆成功刷新用户数据

 @param msgContent 登陆成功的数据结构
 @return 是否成功
 */
- (BOOL)updateUserInfoByLoginSuccess:(Content *)msgContent;

/**
 调用网络请求来刷新用户信息

 @param resultBlock 刷新结束后的回调
 */
- (void)refreshUserInfo:(void(^)(BOOL isSuccess, Content *content))resultBlock;

/**
 重置用户数据
 */
+ (void)resetGlobalUser;

/**
 清除用户缓存
 */
- (void)clearUserInfoCache;

/**
 刷新征信白名单状态
 */
- (void)refreshCreditWhiteListFinishBlock:(void(^)(void))finishBlock;

/**
 刷新理财白名单状态
 */
- (void)refreshFinanceWhiteListFinishBlock:(void(^)(void))finishBlock;

/**
 获取历史用户信息列表，包含userName和userId

 @return 历史用户列表
 */
+ (NSArray *)historyUserArray;

/**
 保存用户信息到历史记录

 @param userDic 用户信息
 */
+ (void)saveHistoryUser:(NSDictionary *)userDic;

/**
 根据用户名，从历史记录中删除用户信息

 @param userName 用户名
 */
+ (void)deleteHistoryUser:(NSString *)userName;

@end
