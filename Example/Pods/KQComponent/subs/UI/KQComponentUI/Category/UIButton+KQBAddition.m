//
//  UIButton+KQAdditions.m
//  KQMOB
//
//  Created by LiuBin on 14-4-2.
//  Copyright (c) 2014年 99Bill. All rights reserved.
//

#import "UIButton+KQBAddition.h"

@implementation UIButton (KQBButton)


+ (UIButton *)buttonWithType:(NSUInteger)type
					   title:(NSString *)title
					   frame:(CGRect)frame
					   image:(UIImage *)image
				 tappedImage:(UIImage *)tappedImage
                disableImage:(UIImage *)disableImage
					  target:(id)target
					  action:(SEL)selector
						 tag:(NSInteger)tag{
	UIButton *button = [UIButton buttonWithType:type];
	button.frame = frame;
	if( title!=nil && title.length>0 ){
		[button setTitle:title forState:UIControlStateNormal];
		//[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont systemFontOfSize:17];
	}
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	button.tag = tag;
	if( image!=nil){
		[button setBackgroundImage:image forState:UIControlStateNormal];
	} else {
		[button setBackgroundImage:nil forState:UIControlStateNormal];
	}
	if( tappedImage!=nil){
		[button setBackgroundImage:tappedImage forState:UIControlStateHighlighted];
	} else {
		[button setBackgroundImage:nil forState:UIControlStateHighlighted];
	}
    if( disableImage!=nil){
		[button setBackgroundImage:disableImage forState:UIControlStateDisabled];
	} else {
		[button setBackgroundImage:nil forState:UIControlStateDisabled];
	}
    
	
	return button;
}

+ (UIButton *)buttonWithType:(NSUInteger)type
                       title:(NSString *)title
                       frame:(CGRect)frame
                      target:(id)target
                      action:(SEL)selector
                         tag:(NSInteger)tag{
    return [UIButton buttonWithType:type
                              title:title
                              frame:frame
                              color:UIColorFromRGB(0xF5, 0x4D, 0x4F)
                        tappedColor:UIColorFromRGB(0xC6, 0x3B, 0x3B)
                       disableColor:UIColorFromRGB(0xC5, 0xCA, 0xCF)
                         titleColor:[UIColor whiteColor]
                   tappedTitleColor:[UIColor whiteColor]
                  disableTitleColor:[UIColor whiteColor]
                             target:target
                             action:selector
                                tag:tag];
}


+ (UIButton *)buttonWithType:(NSUInteger)type
                       title:(NSString *)title
                       frame:(CGRect)frame
                       color:(UIColor*)color
                 tappedColor:(UIColor*)tappedColor
                disableColor:(UIColor*)disableColor
                      target:(id)target
                      action:(SEL)selector
                         tag:(NSInteger)tag{
    UIButton *button = [UIButton buttonWithType:type];
    button.frame = frame;
    if( title!=nil && title.length>0 ){
        [button setTitle:title forState:UIControlStateNormal];
        //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    
    if( color!=nil){
        [button setBackgroundImage:[UIImage kqc_imageWithColor:color size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    } else {
        [button setBackgroundImage:nil forState:UIControlStateNormal];
    }
    if( tappedColor!=nil){
        [button setBackgroundImage:[UIImage kqc_imageWithColor:tappedColor size:CGSizeMake(1, 1)]  forState:UIControlStateHighlighted];
    } else {
        [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    }
    if( disableColor!=nil){
        [button setBackgroundImage:[UIImage kqc_imageWithColor:disableColor size:CGSizeMake(1, 1)]  forState:UIControlStateDisabled];
    } else {
        [button setBackgroundImage:nil forState:UIControlStateDisabled];
    }
    
    [button.layer setBorderWidth:1.0];//画线的宽度
    [button.layer setBorderColor:[UIColor clearColor].CGColor];//颜色
    [button.layer setCornerRadius:4];//圆角
    [button.layer setMasksToBounds:YES];
    
    return button;
}

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
                         tag:(NSInteger)tag {
    UIButton * button = [UIButton buttonWithType:type title:title frame:frame color:color tappedColor:tappedColor disableColor:disableColor target:target action:selector tag:tag];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:tappedTitleColor forState:UIControlStateHighlighted];
    [button setTitleColor:disableTitleColor forState:UIControlStateDisabled];
    return button;
}

- (void) setBtnImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType titleSize:(CGFloat)sizeVal titleColor:(UIColor*)titleColor{
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    //    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:sizeVal]];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(5.0,
                                              -10.0,
                                              5.0,
                                              15.0)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeLeft];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:sizeVal]];
    [self setTitleColor:titleColor forState:UIControlStateNormal];;
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0,
                                              -20.0,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
}

@end

@implementation KQSecondaryButton

+ (KQSecondaryButton *)secondaryButtonWithType:(NSUInteger)type
                                title:(NSString *)title
                                frame:(CGRect)frame
                               target:(id)target
                               action:(SEL)selector
                                  tag:(NSInteger)tag{
    
    KQSecondaryButton *button = [super buttonWithType:type];
    button.frame = frame;
    if( title!=nil && title.length>0 ){
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    
    [button setTitleColor:UIColorFromRGB(0xF5, 0x4D, 0x4F) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xF5, 0x4D, 0x4F) forState:UIControlStateHighlighted];
    [button setTitleColor:UIColorFromRGB(0xAD, 0xB2, 0xB7) forState:UIControlStateDisabled];
    
    [button setBackgroundImage:nil  forState:UIControlStateNormal];
    [button setBackgroundImage:nil  forState:UIControlStateDisabled];
    [button setBackgroundImage:nil  forState:UIControlStateHighlighted];
    button.enabled = YES;
    
    [button.layer setBorderWidth:1.0];//画线的宽度
    [button.layer setBorderColor:UIColorFromRGB(0xF5, 0x4D, 0x4F).CGColor];//颜色
    [button.layer setCornerRadius:4];//圆角
    [button.layer setMasksToBounds:YES];
    
    return button;
}

- (void) setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if (enabled) {
        [[self layer] setBorderColor:UIColorFromRGB(0xF5, 0x4D, 0x4F).CGColor];//颜色
    } else {
        [[self layer] setBorderColor:UIColorFromRGB(0xAD, 0xB2, 0xB7).CGColor];//颜色
    }
}

@end
