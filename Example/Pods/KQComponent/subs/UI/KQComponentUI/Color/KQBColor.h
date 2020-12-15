//
//  KQBColor.h
//  KQCore
//
//  Created by xy on 2016/11/1.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQBColorType) {
    KQBColorTypeDefault = 0,        // 默认
    KQBColorTypeNavigationBarTint,  // 导航栏前景
    KQBColorTypeNavigationBarBg,    // 导航栏背景
    KQBColorTypeTextFieldMajor,     // 用于重要级文字提示，例如导航名称，列表主要文字，大段文字标题
    KQBColorTypeTextFieldNormal,    // 用户普通级段落文字，引导文字
    KQBColorTypeTextFieldInfo,      // 用于大段落辅助/次要的文字信息
    KQBColorTypeTextFieldDetail,    // 用于点击后会消失的辅助/次要的文字信息
    KQBColorTypeTextFieldDisabled,  // 不可用颜色
    KQBColorTypeButtonDisabled,     // 按钮不可用颜色
    KQBColorTypeSeperator,          // 分割线颜色，用于tableView,collectionView
    KQBColorTypeButtonHyperLink,    // 超链接
    KQBColorTypeViewBg,        // 页面背景色
    KQBColorTypeButtonInfoLabelColor, // 次要辅助文字颜色
    KQBColorTypeProcessBar,              //进度条颜色
    KQBColorTypeNavigationBarNew      //新的导航栏颜色，白色
};

@interface KQBColor : NSObject

/**
 注册颜色值对应列表

 @param dic 对应列表
 */
+ (void)registerColorDic:(NSDictionary *)dic;

/**
 根据类型获取对应颜色值

 @param type 指定类型
 @return 颜色值
 */
+ (UIColor *)colorWithType:(KQBColorType)type;

@end
