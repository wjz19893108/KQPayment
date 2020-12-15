//
//  KQPayPasswordNavigateView.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/30.
//  Copyright © 2015年 program. All rights reserved.
//
/*
 付款密码
 */

#import "KQBasePayHalfView.h"

@interface KQPayPasswordNavigateView : KQBasePayHalfView

@property (nonatomic, copy, nullable) NSString *touchIdInfo;          //指纹支付有问题时，显示这个文字

- (instancetype __nullable)init;

@end
