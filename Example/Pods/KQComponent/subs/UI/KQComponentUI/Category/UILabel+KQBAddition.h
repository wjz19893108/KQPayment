//
//  UILabel+KQAdditions.h
//  KQMOB
//
//  Created by LiuBin on 14-4-4.
//  Copyright (c) 2014年 99Bill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQTextAlignment) {
    TextLeft,
    TextRight,
    TextCenter
};

@interface UILabel (KQLabel)

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
                       font:(UIFont *)font
                        tag:(NSInteger)tag
                  hasShadow:(BOOL)hasShadow
              textAlignment:(NSTextAlignment)textAlignment;

+ (UILabel *)labelMutableLinesWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
                       font:(UIFont *)font
                        tag:(NSInteger)tag
                  hasShadow:(BOOL)hasShadow
              textAlignment:(NSTextAlignment)textAlignment;

+ (UILabel*)addLabel:(NSString *)text
               frame:(CGRect)frame
                size:(CGFloat)size
              isBold:(BOOL)isBold
       textAlignment:(NSTextAlignment)textAlignment
           textColor:(UIColor *)textColor
                 tag:(int)tag
            intoView:(UIView*)view;

+ (UILabel*)labelBlackByFont:(float)fontSize frame:(CGRect)frame  align:(KQTextAlignment)textAlignment;

+ (UILabel*)labelByBoldFont:(float)fontSize frame:(CGRect)frame  align:(KQTextAlignment)textAlignment;

+ (UILabel*)labelByLightFont:(float)fontSize frame:(CGRect)frame  align:(KQTextAlignment)textAlignment;

+ (UILabel*)labelByFont:(float)fontSize frame:(CGRect)frame  light:(BOOL)light align:(KQTextAlignment)textAlignment isBold:(BOOL)isBlod color:(UIColor*)color;

+ (UILabel *)noRecordLabelByPoint:(CGPoint)point;
@end
