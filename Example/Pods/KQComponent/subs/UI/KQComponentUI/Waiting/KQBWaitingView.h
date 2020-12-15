//
//  KQBWaitingView.h
//  KQBusiness
//
//  Created by xy on 2016/10/24.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQBWaitingView : NSObject

/**
 显示等待框
 */
+ (void)show;

/**
 显示默认的非全屏幕等待框
 */
+ (void)showShort;

/**
 显示露出返回按钮的全屏幕等待框(可返回的loading)
 */
+ (void)showShortWithOutTop;

/**
 隐藏全屏等待框
 */
+ (void)hideFullView;
/**
 隐藏可返回的等待框
 */
+ (void)hideTopView;
/**
 隐藏短等待框
 */
+ (void)hideShortView;

/**
 强制隐藏loading
 */
+ (void)hide;

@end
