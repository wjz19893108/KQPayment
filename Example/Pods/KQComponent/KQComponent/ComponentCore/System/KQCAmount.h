//
//  KQCAmount.h
//  KQCore
//
//  Created by xy on 2016/11/1.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQCAmountUnitType) {
    KQCAmountUnitTypeFen = 0,   //金额单位为分
    KQCAmountUnitTypeLi         //金额单位为厘
};

@interface KQCAmount : NSObject

/**
 金额转换，分转元

 @param amount 分为单位的金额
 @return 元为单位的金额
 */
+ (NSString *)getDecimalAmount:(NSString *)amount;

/**
 金额转换，分\厘转元

 @param amount 分或厘为单位的金额
 @param amountUnit 指定输入的金额的单位
 @return 元为单位的金额
 */
+ (NSString *)getDecimalAmount:(NSString *)amount amountUnit:(KQCAmountUnitType)amountUnit;

/**
 元转分

 @param amount 元为单位的金额
 @return 分为单位的金额
 */
+ (NSString *)getIntegerAmount:(NSString *)amount;

/**
 将金额转化为###,##0.00的格式。 sample： 1234.8转换后变1,234.80

 @param amount 源金额
 @return 格式化的金额
 */
+ (NSString *)amount2BankAmount:(NSString *)amount;

/**
 将金额转化为###,###的格式。 sample： 1234.8转换后变1,234

 @param amount 源金额
 @return 格式化的金额
 */
+ (NSString *)amount2BankAmountWithoutCode:(NSString *)amount;

@end
