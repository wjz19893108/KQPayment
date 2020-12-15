//
//  KQCTabBarDataModel.h
//  KQCore
//
//  Created by xy on 2016/12/15.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQCTabBarItemDataModel : NSObject

/**
 界面名称
 */
@property (nonatomic, strong) NSString *screenName;

/**
 tab按钮标题
 */
@property (nonatomic, strong) NSString *title;

/**
 tab按钮图标
 */
@property (nonatomic, strong) UIImage *imageUnselected;

/**
 tab按钮选中图标
 */
@property (nonatomic, strong) UIImage *imageSelected;

+ (instancetype)tabBarData:(NSString *)screenName title:(NSString *)title imageName:(NSString *)imageName imageNameSelected:(NSString *)imageNameSelected;

+ (instancetype)tabBarData:(NSString *)screenName title:(NSString *)title image:(UIImage *)image imageSelected:(UIImage *)imageSelected;

@end

@interface KQCTabBarDataModel : NSObject

@property (nonatomic, assign) NSInteger selectedIndex;

/**
 KQCTabBarItemDataModel的数组
 */
@property (nonatomic, strong) NSArray *itemArray;

/**
 背景色
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 背景图片
 */
@property (nonatomic, strong) UIImage *backgroundImage;

/**
 未选中的字体的颜色
 */
@property (nonatomic, strong) UIColor *normalTitleColor;

/**
 选中字体的颜色
 */
@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIImage *selectionIndicatorImage;

@end
