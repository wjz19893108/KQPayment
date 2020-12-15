//
//  KQBScreenJumpDelegate.h
//  KQBusiness
//
//  Created by pengkang on 2016/10/28.
//  Copyright © 2016年 xy. All rights reserved.
//
#import "KQBScreenJumpModel.h"

@protocol KQBScreenJumpDelegate <NSObject>

- (void)handleNativeAction:(KQBScreenJumpModel *)nativeModel;

- (void)handleHtmlAction:(KQBScreenJumpModel *)h5Model;

@end
