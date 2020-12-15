//
//  KQPayErrorAlertView.h
//  KQPayErrorAlertView
//
//  Created by Guanyi on 2018/1/2.
//  Copyright © 2018年 yiguan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KQErrorAlertView : UIView

typedef void (^KQErrorAlertViewCompletionBlock) (KQErrorAlertView * __nonnull alertView, NSInteger buttonIndex);

+ (nonnull instancetype)showWithTitle:(nullable NSString *)title
                              message:(nullable NSString *)message
                         butttonImage:(nullable UIImage *)image
                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                    otherButtonTitles:(nullable NSArray *)otherButtonTitles
                             tapBlock:(nullable KQErrorAlertViewCompletionBlock)tapBlock;


- (void)show;

@end
