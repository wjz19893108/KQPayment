//
//  KQBTopView.m
//  KQBusiness
//
//  Created by kuaiqian on 2017/11/10.
//  Copyright © 2017年 xy. All rights reserved.
//  可以不拦截左上角返回按钮点击事件的view

#import "KQBTopView.h"

@implementation KQBTopView

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    // 当为全屏锁死，左上角不可点击的时候
    if (!self.canLeftClick) {
        return hitView;
    }
    CGFloat backWidth = 100;
    CGFloat backHeight = KQC_NAVIGATIONBAR_HEIGHT + KQC_STATUSBAR_NEW_HEIGHT;
    // 设置可点击的区域
    CGRect rect = CGRectMake(0, 0, backWidth, backHeight);
    
    if (CGRectContainsPoint(rect,point)) {
        // 当为目标区域，返回nil，事件传递到下一层
        return nil;
    }
    return hitView;
}

@end
