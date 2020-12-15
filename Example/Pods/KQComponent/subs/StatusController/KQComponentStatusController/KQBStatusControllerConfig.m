//
//  KQBStatusControllerConfig.m
//  KQComponentStatusController
//
//  Created by xy on 2017/12/13.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import "KQBStatusControllerConfig.h"

@implementation KQBStatusControllerConfig

+ (KQBStatusControllerConfig *)totalRemindTimes:(NSString *)remindTimes remindInterval:(NSString *)remindInterval{
    KQBStatusControllerConfig *config = [[KQBStatusControllerConfig alloc] init];
    config.totalRemindTimes = remindTimes;
    config.remindInterval = remindInterval;
    return config;
}

@end
