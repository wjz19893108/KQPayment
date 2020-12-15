//
//  KQInstalmentAdapter.h
//  FenQiDemo
//
//  Created by tian qing on 2018/2/24.
//  Copyright © 2018年 tian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KQPayOrderDataProcess.h"

#define kAdapterHeight 85

@interface KQInstallmentAdapter : NSObject

typedef void(^kStallmentBlock)(NSInteger choiceInstal,BOOL popFlag);

- (instancetype)initInstallmentOffY:(CGFloat)offY;

- (void)updateByInfo:(NSArray *)data defaultInstallment:(NSString *)defaultStage clickDone:(void(^)(NSInteger  choiceInstal,BOOL popFlag))stallmentClickBlock;

- (UIView *)adapterView;

@end
