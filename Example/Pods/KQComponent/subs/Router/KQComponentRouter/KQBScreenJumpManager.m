//
//  KQBScreenJumpManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/18.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBScreenJumpManager.h"

@implementation KQBScreenJumpManager


+ (KQBScreenJumpManager *)sharedKQBScreenJumpManager
{
    static KQBScreenJumpManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[KQBScreenJumpManager alloc] init];
    });

    return instance;
}

- (void)handleDirect:(KQBScreenJumpModel *)screenJumpModel {
    switch (screenJumpModel.jumpMode) {
        case KQPScreenJumpModeTypeNone:
            break;
        case KQPScreenJumpModeTypeNative:{
            
            if (_screenJumpDelegate && [_screenJumpDelegate respondsToSelector:@selector(handleNativeAction:)]) {
                [_screenJumpDelegate handleNativeAction:screenJumpModel];
            }
            break;
        }
        case KQPScreenJumpModeTypeH5:{
            if (_screenJumpDelegate && [_screenJumpDelegate respondsToSelector:@selector(handleHtmlAction:)]) {
                [_screenJumpDelegate handleHtmlAction:screenJumpModel];
            }
            break;
        }
    }
}

@end
