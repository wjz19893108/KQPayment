//
//  UIView+KQBAddition.h
//  KQBusiness
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (KQBAddition)

/**
 增加分隔线

 @param frame 线的frame
 @return 线的view
 */
- (UIView *)addSeperatorLine:(CGRect)frame;

/**
 增加分隔线

 @param frame 线的frame
 @param color 线的颜色
 @return 线的view
 */
- (UIView *)addSeperatorLine:(CGRect)frame color:(UIColor *)color;

/**
 增加圆角矩形跟边框颜色值

 @param radius 圆角值
 @param borderColor 边框颜色
 */
- (void)radius:(CGFloat)radius borderColor:(UIColor *)borderColor;

@end
