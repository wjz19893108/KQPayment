//
//  UIView+KQBAddition.m
//  KQBusiness
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "UIView+KQBAddition.h"

@implementation UIView (KQBAddition)

#pragma mark - 分割线
- (UIView *)addSeperatorLine:(CGRect)frame{
    return [self addSeperatorLine:frame color:[KQBColor colorWithType:KQBColorTypeSeperator]];
}

- (UIView *)addSeperatorLine:(CGRect)frame color:(UIColor *)color{
    UIView *dividingLine = [[UIView alloc] initWithFrame:frame];
    dividingLine.backgroundColor = color;
    [self addSubview:dividingLine];
    return dividingLine;
}

- (void)radius:(CGFloat)radius borderColor:(UIColor *)borderColor{
    [self.layer setBorderWidth:1.0];//画线的宽度
    [self.layer setBorderColor:borderColor.CGColor];//颜色
    [self.layer setCornerRadius:radius];//圆角
    [self.layer setMasksToBounds:YES];
}

@end
