//
//  KQPaymentManager.m
//  KQProcess
//
//  Created by zouf on 17/1/5.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQPaymentManager.h"
#import "KQPaymentController.h"

@implementation KQPaymentManager

+ (void)pay:(KQPayOrderData * __nonnull)payOrderData internalCall:(BOOL)internalCall viewStepDelegate:(id<KQPayViewStepDelegate> __nullable)viewStepDelegate delegate:(id<KQPayManagerDelegate> __nullable)delegate {
    PaymentController.internalCall = internalCall;
    PaymentController.viewStepDelegate = viewStepDelegate;
    [PaymentController pay:payOrderData delegate:delegate];
}

+ (void)payUnNeedOrder:(KQPayUnNeedOrderData * __nonnull)payOrderData internalCall:(BOOL)internalCall viewStepDelegate:(id<KQPayViewStepDelegate> __nullable)viewStepDelegate delegate:(id<KQPayManagerDelegate> __nullable)delegate{
    PaymentController.internalCall = internalCall;
    PaymentController.viewStepDelegate = viewStepDelegate;
    [PaymentController payUnNeedOrder:payOrderData delegate:delegate];
}

@end
