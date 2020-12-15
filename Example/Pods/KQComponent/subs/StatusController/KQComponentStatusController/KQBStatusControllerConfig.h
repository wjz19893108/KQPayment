//
//  KQBStatusControllerConfig.h
//  KQComponentStatusController
//
//  Created by xy on 2017/12/13.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQBStatusControllerConfig : NSObject

@property (nonatomic, strong) NSString *totalRemindTimes;
@property (nonatomic, strong) NSString *remindInterval;

+ (KQBStatusControllerConfig *)totalRemindTimes:(NSString *)remindTimes remindInterval:(NSString *)remindInterval;

@end

@protocol KQBStatusControllerDelegate<NSObject>

- (KQBStatusControllerConfig *)statusControllerConfig;

- (void)hideWaiting;

@end
