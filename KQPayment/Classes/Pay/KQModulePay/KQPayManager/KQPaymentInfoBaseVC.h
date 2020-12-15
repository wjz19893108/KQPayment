//
//  KQPaymentInfoBaseVC.h
//  kuaiQianbao
//
//  Created by zouf on 15/12/8.
//  Copyright © 2015年 program. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <KQCore/KQCAppBaseViewController.h>

@protocol KQPaymentInfoBaseVCDelegate <NSObject>

@optional
- (void)KQPaymentInfoBaseVCDidShow;
- (void)KQPaymentInfoBaseVCTaped;

@end

@interface KQPaymentInfoBaseVC : KQCAppBaseViewController

@property (nonatomic, weak, nullable) id<KQPaymentInfoBaseVCDelegate> delegate;
@property (nonatomic, assign) BOOL isBackFromHelp;

- (void)changeBackGround:(BOOL)internalCall;

@end
