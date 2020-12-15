//
//  KQKeyboardView.h
//  KQPayPlugin
//
//  Created by Hunter Li on 14-3-3.
//
//

@class KQKeyboardView;

#import <UIKit/UIKit.h>

@protocol KQkeyboardViewDelegate <NSObject>

@required
-(void)doneButton:(KQKeyboardView*)keyboard;
-(void)numberButton:(KQKeyboardView*)keyboard value:(NSInteger)value;
-(void)deleteButton:(KQKeyboardView*)keyboard;

@end
@interface KQKeyboardView : UIView

@property(nonatomic, assign) id<KQkeyboardViewDelegate> delegate;
@property(nonatomic, assign) BOOL isRandomShuffle; //数字键盘乱序 默认NO
@end
