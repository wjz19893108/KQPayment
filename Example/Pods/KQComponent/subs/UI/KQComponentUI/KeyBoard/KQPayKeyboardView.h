//
//  KQPayKeyboardView.h
//  PassCode
//
//  Created by LiuBin on 14-6-16.
//  Copyright (c) 2014年 LiuBin. All rights reserved.
//

@class KQPayKeyboardView;

#import <UIKit/UIKit.h>

@protocol KQPaykeyboardViewDelegate <NSObject>
@required
-(void)doneButton:(KQPayKeyboardView*)keyboard;
-(void)numberButton:(KQPayKeyboardView*)keyboard value:(NSInteger)value;
-(void)deleteButton:(KQPayKeyboardView*)keyboard;
@end

@interface KQPayKeyboardView : UIView
@property(nonatomic, assign) id<KQPaykeyboardViewDelegate> delegate;
@property(nonatomic, assign) BOOL isRandomShuffle; //数字键盘乱序 默认NO
@end
