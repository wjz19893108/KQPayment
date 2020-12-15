//
//  KQPPushDelegate.h
//  KQProtocol
//
//  Created by pengkang on 2016/12/8.
//  Copyright © 2016年 xy. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(char, KQPNotificationType) {
    KQPNotificationTypeNone = 0,
    KQPNotificationTypeNormal,
    KQPNotificationTypeHtml,
    KQPNotificationTypeNative
};

@protocol KQPPushDelegate <NSObject>

- (KQPNotificationType)notificationType;

@end
