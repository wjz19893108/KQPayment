//
//  KQBStatusController.h
//  KQBusiness
//
//  Created by lihui on 17/3/7.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQBAppInfo.h"
#import "KQBStatusControllerConfig.h"

typedef NS_ENUM(NSInteger, KQBStatus) {
    KQBStatusUnknow = -1,
    KQBStatusNo = 0,
    KQBStatusOptional,
    KQBStatusRequired
};

#define KQB_StatusCon_Manager [KQBStatusController sharedKQBStatusController]

@interface KQBStatusController : NSObject

+ (instancetype)sharedKQBStatusController;

@property (nonatomic, weak) id<KQBStatusControllerDelegate> delegate;

@end
