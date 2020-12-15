//
//  KQComponentManager.h
//  KQComponent
//
//  Created by xy on 2018/5/15.
//  Copyright © 2018年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQComponetUserStatusDelegate.h"

// 应用崩溃通知
FOUNDATION_EXTERN NSNotificationName const KQComponentConfigUpdateNotification;

#define ComponentManager        [KQComponentManager sharedKQComponentManager]

@interface KQComponentManager : NSObject

@property (nonatomic, weak) id<KQComponetUserStatusDelegate> userStatusDelegate;

+ (KQComponentManager *)sharedKQComponentManager;

@end
