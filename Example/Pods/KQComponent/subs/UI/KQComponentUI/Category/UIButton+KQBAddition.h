//
//  UIButton+KQAdditions.h
//  KQMOB
//
//  Created by LiuBin on 14-4-2.
//  Copyright (c) 2014年 99Bill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (KQBButton)

+ (UIButton *)buttonWithType:(NSUInteger)type
					   title:(NSString *)title
					   frame:(CGRect)frame
					   image:(UIImage *)image
				 tappedImage:(UIImage *)tappedImage
                disableImage:(UIImage *)disableImage
					  target:(id)target
					  action:(SEL)selector
						 tag:(NSInteger)tag;

+ (UIButton *)buttonWithType:(NSUInteger)type
                       title:(NSString *)title
                       frame:(CGRect)frame
                      target:(id)target
                      action:(SEL)selector
                         tag:(NSInteger)tag;

+ (UIButton *)buttonWithType:(NSUInteger)type
                       title:(NSString *)title
                       frame:(CGRect)frame
                       color:(UIColor*)color
                 tappedColor:(UIColor*)tappedColor
                disableColor:(UIColor*)disableColor
                      target:(id)target
                      action:(SEL)selector
                         tag:(NSInteger)tag;

+ (UIButton *)buttonWithType:(NSUInteger)type
                       title:(NSString *)title
                       frame:(CGRect)frame
                       color:(UIColor*)color
                 tappedColor:(UIColor*)tappedColor
                disableColor:(UIColor*)disableColor
                  titleColor:(UIColor*)titleColor
            tappedTitleColor:(UIColor*)tappedTitleColor
           disableTitleColor:(UIColor*)disableTitleColor
                      target:(id)target
                      action:(SEL)selector
                         tag:(NSInteger)tag;
- (void) setBtnImage:(UIImage *)image
        withTitle:(NSString *)title
         forState:(UIControlState)stateType
        titleSize:(CGFloat)sizeVal
       titleColor:(UIColor*)titleColor;
@end

@interface KQSecondaryButton:UIButton

+ (KQSecondaryButton *)secondaryButtonWithType:(NSUInteger)type
                                title:(NSString *)title
                                frame:(CGRect)frame
                               target:(id)target
                               action:(SEL)selector
                                  tag:(NSInteger)tag;
- (void)setEnabled:(BOOL)enabled;
@end
