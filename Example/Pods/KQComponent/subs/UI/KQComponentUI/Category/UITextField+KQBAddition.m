//
//  UITextField+KQBAddition.m
//  KQBusiness
//
//  Created by xy on 2016/12/26.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "UITextField+KQBAddition.h"

@implementation UITextField (KQBAddition)

+ (UITextField *)addTextfield:(CGRect)frame
              placeholderText:(NSString *)text
                         font:(UIFont *)font
              minimumFontSize:(float)minimumFontSize
                 keyboardType:(UIKeyboardType)UIKeyboardType
{
    UITextField *temptextField = [[UITextField alloc] initWithFrame:frame];
    [temptextField setKeyboardType:UIKeyboardType];
    [temptextField setPlaceholder:text];
    [temptextField setFont:font];
    temptextField.textColor = [KQBColor colorWithType:KQBColorTypeTextFieldInfo];
    [temptextField setAdjustsFontSizeToFitWidth:YES];
    [temptextField setMinimumFontSize:minimumFontSize];
    [temptextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [temptextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [temptextField setReturnKeyType:UIReturnKeyDone];
    return temptextField;
}

- (NSInteger)selectedRangeIndex {
    UITextRange *selRange = self.selectedTextRange;
    UITextPosition *selStartPos = selRange.start;
    NSInteger idx = [self offsetFromPosition:self.beginningOfDocument
                                  toPosition:selStartPos];
    return idx;
}

- (void)setSelectedRangeWithIndex:(NSInteger)idx {
    UITextPosition* endPos = [self positionFromPosition:self.beginningOfDocument
                                            inDirection:UITextLayoutDirectionRight
                                                 offset:idx];
    UITextRange* resetSelRange = [self textRangeFromPosition:endPos
                                                  toPosition:endPos];
    [self setSelectedTextRange:resetSelRange];
}
@end
