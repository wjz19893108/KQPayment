//
//  KQPayLoadingViewManager.h
//  KQProcess
//
//  Created by zouf on 17/2/10.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LoadingViewManager [KQBLoadingViewManager sharedKQBLoadingViewManager]

@interface KQBLoadingViewManager : NSObject

+ (instancetype)sharedKQBLoadingViewManager;


/**
 显示开始加载的动效

 @param parentView 在哪个view上显示
 @param lineColor 颜色
 */
- (void)startLoading:(UIView *)parentView lineColor:(UIColor *)lineColor;

/**
 显示加载成功的动效
 
 @param parentView 在哪个view上显示
 @param lineColor 颜色
 */
- (void)successLoading:(UIView *)parentView lineColor:(UIColor *)lineColor;

/**
 显示加载失败的动效
 
 @param parentView 在哪个view上显示
 @param lineColor 颜色
 */
- (void)failLoading:(UIView *)parentView lineColor:(UIColor *)lineColor;

@end
