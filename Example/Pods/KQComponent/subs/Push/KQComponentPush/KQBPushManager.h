//
//  KQBPushManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/12/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "KQPPushDelegate.h"

#define PushManeger [KQBPushManager sharedKQBPushManager]

typedef NS_ENUM(NSInteger, KQBPushOpenState) {
    KQBPushOpenStateUnknow = 0,  // 未知状态
    KQBPushOpenStateAvailable,   // 可用状态
    KQBPushOpenStateUnavailable  // 不可用状态
};

@class KQBScreenJumpModel;

@interface KQBPushManager : NSObject <UNUserNotificationCenterDelegate>

+ (KQBPushManager *)sharedKQBPushManager;

@property (nonatomic, assign) KQPNotificationType notificationType;

@property (nonatomic, assign) BOOL isLaunchOptionsNotification;

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) NSString *viewTitle;

@property (nonatomic, strong) NSMutableArray *localNotificationArray;

@property (nonatomic, strong) NSString *channelId; // 通道ID

@property (nonatomic, strong) NSString *userId;    // 用户ID

@property (nonatomic, strong) KQBScreenJumpModel *screenJumpModel;

@property (nonatomic, assign) KQBPushOpenState pushOpenState; // 推送开关状态

- (void)handleNotification:(NSDictionary *)userinfo;

+ (void)startPushEngine:(NSDictionary *)launchOptions resultBlock:(void(^)(BOOL success))resultBlock;

+ (void)registerDeviceToken:(NSData *)deviceToken;

- (void)checkLocalNotification;

@end
