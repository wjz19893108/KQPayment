//
//  UIImage+KQCAddition.h
//  KQCore
//
//  Created by xy on 2016/10/31.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 定义一个空的类，用来获取当前类的路径
 */
@interface KQCoreImageCategory : NSObject

@end

@interface UIImage (KQCAddition)

/**
 根据颜色生成图片

 @param color 颜色
 @param size 目标图片大小
 @return 目标图片
 */
+ (UIImage *)kqc_imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 旋转图片

 @param orientation 选择角度
 @return 目标图片
 */
- (UIImage *)kqc_rotation:(UIImageOrientation)orientation;

/**
 选择图片到UIImageOrientationUp方向

 @return 目标图片
 */
- (UIImage *)kqc_rotation2Up;

/**
 屏幕截图

 @return 屏幕截图
 */
+ (UIImage *)kqc_screenShot;

/**
 根据资源包名以及图片名获取图片

 @param imageName 图片名
 @param bundleName 资源包名，不含路径，不含后缀.bundle
 @return 对应图片
 */
+ (UIImage *)kqc_imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName;

/**
 中间拉伸图

 @param image 需拉伸图片
 @return 中间拉伸图
 */
+ (UIImage *)kqc_resizableImage:(UIImage *)image;

@end
