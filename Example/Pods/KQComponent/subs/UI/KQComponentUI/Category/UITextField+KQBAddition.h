//
//  UITextField+KQBAddition.h
//  KQBusiness
//
//  Created by xy on 2016/12/26.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextField (KQBAddition)

+ (UITextField *)addTextfield:(CGRect)frame
              placeholderText:(NSString *)text
                         font:(UIFont *)font
              minimumFontSize:(float)minimumFontSize
                 keyboardType:(UIKeyboardType)UIKeyboardType;

- (NSInteger)selectedRangeIndex;

- (void)setSelectedRangeWithIndex:(NSInteger)idx;

@end
