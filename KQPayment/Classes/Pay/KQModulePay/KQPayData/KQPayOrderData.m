//
//  KQPayOrderData.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/24.
//
//

#import "KQPayOrderData.h"

@implementation KQPayMethodInfoBeforePay

@end

@implementation KQPayAdditionalInfo

@end

@implementation KQPayOrderData

- (id)init {
    self = [super init];
    if (self) {
        self.useVoucher = YES;
//        self.isShowDefaultResPage = YES;
    }
    return self;
}

@end

@implementation KQPaymentDeskData

@end

@implementation KQPayMethod

- (BOOL)isEqualToVoucher:(KQPayMethod *)method {
    if (!method) {
        return NO;
    }
    
    BOOL haveEqualMethodId = (!self.methodId && !method.methodId) || [self.methodId isEqualToString:method.methodId];
    
    return haveEqualMethodId;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[KQPayMethod class]]) {
        return NO;
    }
    
    return [self isEqualToVoucher:(KQPayMethod *)object];
}

- (NSUInteger)hash {
    return [self.methodId hash];
}

@end

@implementation KQPayResultInfo

- (id)init {
    self = [super init];
    if (self) {
        //枚举初始化
        self.errorBtnType = KQPayResultErrorBtnTypeNormal;
    }
    return self;
}

- (NSArray *)analyzeEquityInfoArr:(NSArray *)arr{
    NSMutableArray * SourceArr = [[NSMutableArray alloc] init];
    NSMutableArray * DataArr   = [[NSMutableArray alloc] init];
    NSMutableArray * resultVoucherArr = [[NSMutableArray alloc] init];
    
    NSString * KQequitySource;
    for (int i = 0 ; i < arr.count; i ++) {
        ContentEquityInfo * info = arr[i];
        if (i == 0) {
            KQequitySource = info.equitySource;
            [SourceArr addObject:info.equitySource];
        }else{
            if (![KQequitySource isEqualToString:info.equitySource]) {
                KQequitySource = info.equitySource;
                [SourceArr addObject:info.equitySource];
            }
        }
    }
    KQequitySource = nil;
    
    [SourceArr enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *objarr=[NSMutableArray array];
        [objarr addObject:obj];
        [DataArr addObject:objarr];
    }];
    
    [arr enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ContentEquityInfo * info =obj;
        NSString *sourcesTit = info.equitySource;
        for (NSMutableArray * infoArr in DataArr) {
            if ([[infoArr firstObject] isEqualToString:sourcesTit]) {
                KQPayResultVoucherInfo * vouvher = [[KQPayResultVoucherInfo alloc] initWithVoucherInfoTitle:info.equityType Data:info.equityAmount];
                [infoArr addObject:vouvher];
            }
        }
    }];
    
    [DataArr enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *objarr=obj;
        if (objarr.count <= 1) {
            [DataArr removeObject:obj];
        }else{
            NSString * tittle = [objarr firstObject];
            [objarr removeObjectAtIndex:0];
            KQPayResultVoucherArr * VoucherArr = [[KQPayResultVoucherArr alloc] initWithVoucherInfoArr:objarr Source:tittle];
            [resultVoucherArr addObject:VoucherArr];
        }
    }];
    
    [SourceArr removeAllObjects];
    [DataArr removeAllObjects];
    return resultVoucherArr;
}
@end

@implementation KQPayResultVoucherArr
- (id)initWithVoucherInfoArr:(NSArray *)arr Source:(NSString *)sourece {
    self = [super init];
    if (self) {
        self.payVoucherSource = sourece;
        self.payVoucherArr    = arr;
    }
    return self;
}
@end

@implementation KQPayResultVoucherInfo
- (id)initWithVoucherInfoTitle:(NSString *)title Data:(NSString *)data {
    self = [super init];
    if (self) {
        self.payVoucherTitle   = title;
        self.payVoucherData    = data;
    }
    return self;
}
@end

@implementation KQPayUnNeedOrderData

@end
