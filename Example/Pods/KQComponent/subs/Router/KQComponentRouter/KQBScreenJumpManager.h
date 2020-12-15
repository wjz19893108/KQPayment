//
//  KQBScreenJumpManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/18.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQBScreenJumpDelegate.h"

#define AppRouter [KQBScreenJumpManager sharedKQBScreenJumpManager]
#define itemNeedLogin @"1"

@interface KQBScreenJumpManager : NSObject
@property (nonatomic, weak) id<KQBScreenJumpDelegate> screenJumpDelegate;

+ (KQBScreenJumpManager *)sharedKQBScreenJumpManager;

/**
 判断跳转对象包括Native和H5

 @param screenJumpModel 跳转数据模型
 */
- (void)handleDirect:(KQBScreenJumpModel *)screenJumpModel;

@end
