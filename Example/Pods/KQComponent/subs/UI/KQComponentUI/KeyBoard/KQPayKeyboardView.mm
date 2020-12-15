//
//  KQPayKeyboardView.m
//  PassCode
//
//  Created by LiuBin on 14-6-16.
//  Copyright (c) 2014年 LiuBin. All rights reserved.
//

#import "KQPayKeyboardView.h"
#import <vector>
#import <algorithm>

using namespace std;

@implementation KQPayKeyboardView

- (id)init{
    self = [super init];
    if (self) {
        CGFloat viewHeight = KQC_HAS_NOTCH ? 250.f + 34.f : 250.f;
        [self setFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, viewHeight)];
        
        _isRandomShuffle = NO;
        [self addCustomButtonToKeyboard:_isRandomShuffle];
        
        self.backgroundColor = UIColorFromRGB(0xc8, 0xd2, 0xd5);
    }
    return self;
}

-(void)setIsRandomShuffle:(BOOL)isRandomShuffle{
    if (_isRandomShuffle != isRandomShuffle) {
        _isRandomShuffle = isRandomShuffle;
        [self updatecustomkeyboard];
    }
}

- (void)updatecustomkeyboard{
    [self addCustomButtonToKeyboard:_isRandomShuffle];
}

- (void)addKeyboardButton:(CGRect)rect
              normalImage:(UIImage*)normal
         highlightedImage:(UIImage*)highlighted
                    title:(NSString*)title
                  withTag:(int)btag
                   action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:25.0f];
    button.frame = rect;
    [button setBackgroundImage:[UIImage kqc_imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage kqc_imageWithColor:UIColorFromRGB(0xB0, 0xBD, 0xC1) size:CGSizeMake(1, 1)] forState:UIControlStateHighlighted];

    if (normal) {
        [button setImage:normal forState:UIControlStateNormal];
    }
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x10, 0x10, 0x10) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    button.tag = btag;
    [self addSubview:button];
}

- (void)addCustomButtonToKeyboard:(BOOL)isRandomShuffle {
    for (UIView* subView in [self subviews]) {
        [subView removeFromSuperview];
    }
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.text = @"快钱安全键盘";
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = UIColorFromRGB(0x7e, 0x85, 0x87);
    lbl.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:lbl];
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage kqb_imageNamed:@"secure_gray"]];
    [self addSubview:bgView];
    
    CGSize size = [NSString kqc_calcStrSize:lbl.text font:lbl.font maxWidth:320];
    CGFloat offsetX = (KQC_SCREEN_WIDTH - size.width - 18 -5)/2;
    lbl.frame = CGRectMake(offsetX + 5 + 18, 0, size.width, 36);
    bgView.frame = CGRectMake(offsetX, 9, 18, 18);
    
    vector<int> keyNumbers;
    for (int i= 0;i<9; i++) {
        keyNumbers.push_back(i+1);
    }
    keyNumbers.push_back(0);
    if(isRandomShuffle){
        random_shuffle(keyNumbers.begin(),keyNumbers.end());
    }
    
    int width = (KQC_SCREEN_WIDTH - 2)/ 3;
    int height = 53;
    int offsety = 36;
    
    for(int i=0; i<keyNumbers.size()-1; i++){
        int currentObj = keyNumbers[i];

        [self addKeyboardButton:CGRectMake((i%3)* (width+1) , (i/3)*(height+1)+offsety, width + ((((i +1)%3) == 0) ? (((NSInteger)KQC_SCREEN_WIDTH - 2) % 3):0), height)
                    normalImage:nil
               highlightedImage:nil
                          title:[NSString stringWithFormat:@"%d",currentObj]
                        withTag:currentObj
                         action:@selector(numberButtonClick:)];
    }
    
    //底部中间数字
    int currentObj = keyNumbers[keyNumbers.size()-1];
    [self addKeyboardButton:CGRectMake(width+1, 3*(height+1)+offsety, width, height)
                normalImage:nil
           highlightedImage:nil
                      title:[NSString stringWithFormat:@"%d",currentObj]
                    withTag:currentObj
                     action:@selector(numberButtonClick:)];
    
    //删除按钮
    [self addKeyboardButton:CGRectMake(2*(width+1), 3*(height+1)+offsety, width, height)
                normalImage:[UIImage kqb_imageNamed:@"keyboard_del_btn"]
           highlightedImage:nil
                      title:@""
                    withTag:11
                     action:@selector(deleteButtonClick:)];
}

-(void)numberButtonClick:(id)sender{
    UIButton *bt = (UIButton *)sender;
    
    [_delegate numberButton:self value:bt.tag];
}

-(void)updateButtonClick:(id)sender{
    [self addCustomButtonToKeyboard:_isRandomShuffle];
}

-(void)deleteButtonClick:(id)sender{
    [_delegate deleteButton:self];
}

-(void)dealloc{
    _delegate = nil;
}

@end
