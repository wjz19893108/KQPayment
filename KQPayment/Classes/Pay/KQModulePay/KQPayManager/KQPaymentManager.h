//
//  KQPaymentManager.h
//  KQProcess
//
//  Created by zouf on 17/1/5.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQPayOrderData.h"
#import "KQPayViewStepDelegate.h"
#import "KQPayManagerDelegate.h"

@interface KQPaymentManager : NSObject

/**
 开始支付

 @param payOrderData 订单数据结构
 @param internalCall 是否App内部调用
 @param viewStepDelegate view定制delegate
 @param delegate 其他支线流程delegate
 */
+ (void)pay:(KQPayOrderData * __nonnull)payOrderData internalCall:(BOOL)internalCall viewStepDelegate:(id<KQPayViewStepDelegate> __nullable)viewStepDelegate delegate:(id<KQPayManagerDelegate> __nullable)delegate;

/**
 开始支付 无需下单情况
 
 @param payOrderData 订单数据结构
 @param internalCall 是否App内部调用
 @param viewStepDelegate view定制delegate
 @param delegate 其他支线流程delegate
 */
+ (void)payUnNeedOrder:(KQPayUnNeedOrderData * __nonnull)payOrderData internalCall:(BOOL)internalCall viewStepDelegate:(id<KQPayViewStepDelegate> __nullable)viewStepDelegate delegate:(id<KQPayManagerDelegate> __nullable)delegate;

@end
