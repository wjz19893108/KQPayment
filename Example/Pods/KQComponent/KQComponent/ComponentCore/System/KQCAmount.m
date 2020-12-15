//
//  KQCAmount.m
//  KQCore
//
//  Created by xy on 2016/11/1.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCAmount.h"

@implementation KQCAmount

#pragma mark - 分/厘转元
+ (NSString *)getDecimalAmount:(NSString *)amount{
    return [KQCAmount getDecimalAmount:amount amountUnit:KQCAmountUnitTypeFen];
}

+ (NSString *)getDecimalAmount:(NSString *)amount amountUnit:(KQCAmountUnitType)amountUnit{
    if (!amount) {
        return @"0.00";
    }
    
    NSString *balanceString;
    //去掉可能出现的小数点
    NSRange range = [amount rangeOfString:@"."];
    if (range.location != NSNotFound) {
        amount = [amount substringWithRange:NSMakeRange(0, range.location)];
    }
    if (amount.length <= 0 + amountUnit) {
        balanceString = @"0.00";
    }else if(amount.length == 1 + amountUnit) {
        balanceString = KQC_FORMAT(@"0.0%@", [amount substringWithRange:NSMakeRange(0, 1)]);
    }else if(amount.length == 2 + amountUnit) {
        balanceString = KQC_FORMAT(@"0.%@", [amount substringWithRange:NSMakeRange(0, 2)]);
    }else{
        balanceString = KQC_FORMAT(@"%@.%@", [amount substringWithRange:NSMakeRange(0, amount.length - (2 + amountUnit))],[amount substringWithRange:NSMakeRange(amount.length - (2 + amountUnit), 2)]);
    }
    return balanceString;
}

#pragma mark - 元转分
+ (NSString *)getIntegerAmount:(NSString *)string{
    NSString *balanceString;
    if (([string rangeOfString:@"."].location !=NSNotFound)) {
        NSArray *dismantlingArray = [string componentsSeparatedByString:@"."];
        NSInteger beforeDecimalInteger = [dismantlingArray[0] integerValue];
        NSString *beforeDecimal = @"";
        if (beforeDecimalInteger > 0) {
            beforeDecimal = KQC_FORMAT(@"%ld",(long)beforeDecimalInteger);
        }
        NSString *afterDecimal = dismantlingArray[1];
        if (afterDecimal.length == 0) {
            afterDecimal = @"00";
        } else if (afterDecimal.length == 1) {
            afterDecimal = KQC_FORMAT(@"%@0", afterDecimal);
        } else {
            afterDecimal = afterDecimal;
        }
        balanceString = KQC_FORMAT(@"%@%@", beforeDecimal,afterDecimal);
    } else {
        balanceString = KQC_FORMAT(@"%ld00",(long)[string integerValue]);
    }
    return balanceString;
}

+ (NSString *)amount2BankAmount:(NSString *)amount{
    double srcAmount = [amount doubleValue];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    return [numberFormatter stringFromNumber:@(srcAmount)];
}

+ (NSString *)amount2BankAmountWithoutCode:(NSString *)amount{
    NSInteger srcAmount = [amount integerValue];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,###;"];
    return [numberFormatter stringFromNumber:@(srcAmount)];
}

@end
