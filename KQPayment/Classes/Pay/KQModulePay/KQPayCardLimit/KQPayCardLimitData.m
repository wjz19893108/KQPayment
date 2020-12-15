//
//  KQPayCardLimitData.m
//  kuaiQianbao
//
//  Created by zouf on 16/3/7.
//
//

#import "KQPayCardLimitData.h"

@implementation KQPayCardLimitData

static NSDictionary *KQPayDebitBanksLimitDic = nil;

+ (void)initialize{
    KQPayDebitBanksLimitDic = @{@"CMB":@"单笔5万，单日5万"
                                ,@"HXB":@"单笔5万，单日50万"
                                ,@"PAB":@"单笔5万，单日50万"
                                ,@"ICBC":@"单笔5千，单日5万，单月5万"
                                ,@"CEB":@"单笔5千，单日5千"
                                ,@"CCB":@"单笔5万，单日50万"
                                ,@"CMBC":@"单笔5千，单日5千"
                                ,@"ABC":@"单笔5万，单日50万"
                                ,@"BOC":@"单笔1万，单日1万"
                                ,@"CITIC":@"单笔5万，单日50万,需开通银联在线支付"};
}

+ (instancetype __nullable)getPayCardLimitDataFromObj:(ContentBankLimitAmountDto* __nonnull)obj
{
    KQPayCardLimitData *data = [[KQPayCardLimitData alloc] init];
    data.id = obj.id;
    data.bankId = obj.bankId;
    data.cardType = obj.cardType;
    data.productCode = obj.productCode;
    data.dayAmount = [obj.dayAmount kqb_decrypt];
    data.monthAmount = [obj.monthAmount kqb_decrypt];
    data.singleAmount = [obj.singleAmount kqb_decrypt];
    
    if ([NSString kqc_isBlank:data.bankId]||[NSString kqc_isBlank:data.cardType]||[NSString kqc_isBlank:data.productCode]) {
        return nil;
    }
    
    NSInteger singleValue = [data.singleAmount integerValue];
    NSInteger dayValue = [data.dayAmount integerValue];
    NSInteger monthValue = [data.monthAmount integerValue];
    NSString *singleDesc, *dayDesc, *monthDesc;
    if (singleValue <= 0) {
        singleDesc = @"";
    }
    else {
        if (singleValue >= 10000) {
            singleDesc = [NSString stringWithFormat:@"单笔%@万", [self stringDisposeWithFloat:singleValue/10000.0]];
        }
        else {
            singleDesc = [NSString stringWithFormat:@"单笔%@千", [self stringDisposeWithFloat:singleValue/1000.0]];
        }
    }
    if (dayValue <= 0) {
        dayDesc = @"";
    }
    else {
        if (dayValue >= 10000) {
            dayDesc = [NSString stringWithFormat:@"单日%@万", [self stringDisposeWithFloat:dayValue/10000.0]];
        }
        else {
            dayDesc = [NSString stringWithFormat:@"单日%@千", [self stringDisposeWithFloat:dayValue/1000.0]];
        }
    }
    if (monthValue <= 0) {
        monthDesc = @"";
    }
    else {
        if (monthValue >= 10000) {
            monthDesc = [NSString stringWithFormat:@"单月%@万", [self stringDisposeWithFloat:monthValue/10000.0]];
        }
        else {
            monthDesc = [NSString stringWithFormat:@"单月%@千", [self stringDisposeWithFloat:monthValue/1000.0]];
        }
    }
    if (![NSString kqc_isBlank:singleDesc]) {
        data.payCardLimitDesc = [NSString stringWithFormat:@"%@", singleDesc];
    }
    if (![NSString kqc_isBlank:dayDesc]) {
        if ([NSString kqc_isBlank:data.payCardLimitDesc]) {
            data.payCardLimitDesc = [NSString stringWithFormat:@"%@", dayDesc];
        }
        else {
            data.payCardLimitDesc = [NSString stringWithFormat:@"%@，%@", data.payCardLimitDesc, dayDesc];
        }
    }
    if (![NSString kqc_isBlank:monthDesc]) {
        if ([NSString kqc_isBlank:data.payCardLimitDesc]) {
            data.payCardLimitDesc = [NSString stringWithFormat:@"%@", monthDesc];
        }
        else {
            data.payCardLimitDesc = [NSString stringWithFormat:@"%@，%@", data.payCardLimitDesc, monthDesc];
        }
    }
    if ([NSString kqc_isBlank:data.payCardLimitDesc]) {
        data.payCardLimitDesc = KQPayDebitBanksLimitDic[data.bankId];
    }
    
    return data;
}

+ (NSString*)stringDisposeWithFloat:(double)doubleValue
{
    NSString *str = [NSString stringWithFormat:@"%f",doubleValue];
    long len = str.length;
    for (int i = 0; i < len; i++)
    {
        if (![str hasSuffix:@"0"])
            break;
        else
            str = [str substringToIndex:[str length]-1];
    }
    if ([str hasSuffix:@"."])//避免像2.0000这样的被解析成2.
    {
        return [str substringToIndex:[str length]-1];//s.substring(0, len - i - 1);
    }
    else
    {
        return str;
    }
}

@end
