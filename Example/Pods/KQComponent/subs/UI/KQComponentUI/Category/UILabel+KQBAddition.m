//
//  UILabel+KQAdditions.m
//  KQMOB
//
//  Created by LiuBin on 14-4-4.
//  Copyright (c) 2014年 99Bill. All rights reserved.
//

#import "UILabel+KQBAddition.h"

@implementation UILabel (KQLabel)

+ (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
                       font:(UIFont *)font
                        tag:(NSInteger)tag
                  hasShadow:(BOOL)hasShadow
              textAlignment:(NSTextAlignment)textAlignment
{
    __autoreleasing UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.text = text;
	label.textColor = textColor;
	label.backgroundColor = [UIColor clearColor];
	if( hasShadow ){
		label.shadowColor = [UIColor lightGrayColor];
		label.shadowOffset = CGSizeMake(0,1);
	}
	label.font = font;
	label.tag = tag;
	label.textAlignment = textAlignment;
    label.adjustsFontSizeToFitWidth = YES;
	return label;
}

+ (UILabel *)labelMutableLinesWithFrame:(CGRect)frame
                       text:(NSString *)text
                  textColor:(UIColor *)textColor
                       font:(UIFont *)font
                        tag:(NSInteger)tag
                  hasShadow:(BOOL)hasShadow
              textAlignment:(NSTextAlignment)textAlignment
{
    __autoreleasing UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    if( hasShadow ){
        label.shadowColor = [UIColor lightGrayColor];
        label.shadowOffset = CGSizeMake(0,1);
    }
    label.font = font;
    label.tag = tag;
    label.textAlignment = textAlignment;
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

+ (UILabel*)addLabel:(NSString *)text
               frame:(CGRect)frame
                size:(CGFloat)size
              isBold:(BOOL)isBold
       textAlignment:(NSTextAlignment)textAlignment
           textColor:(UIColor *)textColor
                 tag:(int)tag
            intoView:(UIView*)view{
    UILabel* tempLabel = [[UILabel alloc] initWithFrame:frame];
    [tempLabel setBackgroundColor:[UIColor clearColor]];
    if (isBold) {
        [tempLabel setFont:[UIFont boldSystemFontOfSize:size]];
    } else {
        [tempLabel setFont:[UIFont systemFontOfSize:size]];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [tempLabel setMinimumScaleFactor:1.0];
    }else{
        [tempLabel setMinimumScaleFactor:size];
    }
    tempLabel.tag = tag;
    [tempLabel setTextAlignment:textAlignment];
    [tempLabel setTextColor:textColor];
    [tempLabel setText:text];
    [view addSubview:tempLabel];
    return tempLabel;
}

+ (UILabel*)labelBlackByFont:(float)fontSize frame:(CGRect)frame  align:(KQTextAlignment)textAlignment{
    return [self labelByFont:fontSize frame:frame light:NO align:textAlignment isBold:NO color:nil];
}

+ (UILabel*)labelByBoldFont:(float)fontSize frame:(CGRect)frame  align:(KQTextAlignment)textAlignment{
    return [self labelByFont:fontSize frame:frame light:NO align:textAlignment isBold:YES color:nil];
}

+ (UILabel*)labelByLightFont:(float)fontSize frame:(CGRect)frame  align:(KQTextAlignment)textAlignment{
    return [self labelByFont:fontSize frame:frame light:YES align:textAlignment isBold:NO color:nil];
}

+ (UILabel*)labelByFont:(float)fontSize frame:(CGRect)frame  light:(BOOL)light align:(KQTextAlignment)textAlignment
                 isBold:(BOOL)isBlod color:(UIColor*)color{
    UILabel *l = [[UILabel alloc] init];
    l.textColor = [UIColor blackColor];
    if (isBlod) {
        [l setFont:[UIFont boldSystemFontOfSize:fontSize]];
    }else{
        [l setFont:[UIFont systemFontOfSize:fontSize]];
    }
    l.textAlignment = (textAlignment == TextLeft)?NSTextAlignmentLeft:
    (textAlignment == TextRight)?NSTextAlignmentRight:NSTextAlignmentCenter;
    l.frame = frame;
    if (color) {
        l.textColor = color;
    }else{
        l.textColor = light?[KQBColor colorWithType:KQBColorTypeTextFieldInfo]:[UIColor blackColor];
    }
    l.backgroundColor = [UIColor clearColor];
    l.adjustsFontSizeToFitWidth = YES;
    return l;
}

+ (UILabel *)noRecordLabelByPoint:(CGPoint)point{
    UILabel *noRecordLabel = [UILabel labelByLightFont:14 frame:CGRectMake(0, 0, 100, 20) align:TextCenter];
    noRecordLabel.text = @"暂无数据";
    noRecordLabel.textColor = [KQBColor colorWithType:KQBColorTypeTextFieldNormal];
    noRecordLabel.center = CGPointMake(point.x, point.y - 60);
    noRecordLabel.hidden = YES;
    return noRecordLabel;
}
@end
