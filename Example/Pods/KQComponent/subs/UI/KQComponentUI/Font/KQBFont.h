//
//  KQBFont.h
//  KQCore
//
//  Created by xy on 2016/11/1.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQBFontType) {
    KQBFontTypeDefault = 0,        // 默认
    KQBFontTypeTextFieldMajor,     // 用于重要级文字提示，例如导航名称，列表主要文字，大段文字标题
    KQBFontTypeTextFieldNormal,    // 用户普通级段落文字，引导文字
    KQBFontTypeTextFieldDetail,    // 用于点击后会消失的辅助/次要的文字信息
//    KQBFontTypeTextFieldDisabled,  // 不可用文本
//    KQBFontTypeButtonDisabled,     // 按钮不可用
    KQBFontTypeButtonNormal,     // 按钮正常大小
    KQBFontTypeCellTextNormal,   // cell的文本大小
};

@interface KQBFont : NSObject

/**
 注册字体对应列表

 @param dic 对应字典
 */
+ (void)registerFontSizeDic:(NSDictionary *)dic;

/**
 根据类型获取对应字体

 @param type 指定类型
 @return 对应字体
 */
+ (UIFont *)fontWithType:(KQBFontType)type;

/**
 根据类型获取对应字体

 @param type 指定类型
 @param isBold 是否为粗体 YES：粗体 NO：普通
 @return 对应字体
 */
+ (UIFont *)fontWithType:(KQBFontType)type isBold:(BOOL)isBold;

/**
 根据类型获取对应字体大小

 @param type 指定类型
 @return 文字大小
 */
+ (CGFloat)fontSizeWithType:(KQBFontType)type;

@end
