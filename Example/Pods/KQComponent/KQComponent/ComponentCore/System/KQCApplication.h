//
//  KQCApplication.h
//  KQCore
//
//  Created by xy on 2016/10/28.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 APP访问的服务器类型

 - KQCAppServerTypeMBP: MBP服务，默认
 - KQCAppServerTypePay: 快易刷项目服务
 */
typedef NS_ENUM(NSInteger, KQCAppServerType) {
    KQCAppServerTypeMBP,
    KQCAppServerTypePay
};

/**
 APP所处于的环境

 - KQCAppEnvironmentTypeDev: 开发环境
 - KQCAppEnvironmentTypeIntegrated: 集成环境
 - KQCAppEnvironmentTypeSandbox: 外网测试环境
 - KQCAppEnvironmentTypePro: 生产环境
 */
typedef NS_ENUM(NSInteger, KQCAppEnvironmentType) {
    KQCAppEnvironmentTypeDev = 0,     
    KQCAppEnvironmentTypeIntegrated,  
    KQCAppEnvironmentTypeSandbox,     
    KQCAppEnvironmentTypePro
};

@interface KQCApplication : NSObject

/**
 设置当前APP服务器类型

 @param serverType 服务器类型
 */
+ (void)setAppServerType:(KQCAppServerType)serverType;

/**
 返回当前APP服务器类型
 */
+ (KQCAppServerType)appServerType;

/**
 配置当前APP环境

 @param environmentType 当前环境
 */
+ (void)setEnvironmentType:(KQCAppEnvironmentType)environmentType;

/**
 返回当前APP环境
 
 @return 当前环境
 */
+ (KQCAppEnvironmentType)environmentType;

/**
 配置当前APP渠道

 @param channel 当前渠道
 */
+ (void)setAppChannel:(NSString *)channel;

/**
 获取当前APP的渠道

 @return 当前渠道
 */
+ (NSString *)appChannel;

/**
 获取当前app版本号

 @return 版本号
 */
+ (NSString *)version;

/**
 *  广告标示符
 *
 *  @return 广告标示符(适用于对外：例如广告推广，换量等跨应用的用户追踪等。)
 */

+ (NSString *)idfaString;

/**
 *  Vindor标示符
 *
 *  @return Vindor标示符(适用于对内：例如分析用户在应用内的行为等)
 */
+ (NSString *)idfvString;

/**
 倒数第二个window

 @return view
 */
+ (UIView *)keyboardBelowWindow;

/**
 等待框显示的window

 @return window
 */
+ (UIWindow *)progressViewParentWindow;

@end

void HandleException(NSException *exception);
void SignalHandler(int signal);

void InstallUncaughtExceptionHandler(void);

// 应用崩溃通知
FOUNDATION_EXTERN NSNotificationName const KQCApplicationCrashNotification;

// 应用升级通知
FOUNDATION_EXTERN NSNotificationName const KQCApplicationStatusNotification;

// 应用环境切换通知
FOUNDATION_EXTERN NSNotificationName const KQCApplicationEnvironmentDidChangedNotification;

// 应用服务器切换通知
FOUNDATION_EXTERN NSNotificationName const KQCApplicationServerDidChangedNotification;
