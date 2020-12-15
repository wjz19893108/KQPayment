//
//  UIColor+KQCAddition.h
//  KQCore
//
//  Created by xy on 2016/12/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(ared,agreen,ablud) [UIColor colorWithRed:(float)ared/255.0 green:(float)agreen/255.0 blue:(float)ablud/255.0 alpha:1.0]

@interface UIColor (KQCAddition)

/**
 根据颜色字符串生成颜色

 @param hexColor 颜色字符串，格式为RGBA
 @return 对应颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)hexColor;

/**
 根据颜色值生成颜色

 @param rgbValue 颜色值，格式为RGB, A固定为1.0
 @return 对应颜色
 */
+ (UIColor *)colorWithRGB:(int)rgbValue;

@end
