//
//  KQPayViewData.m
//  kuaiQianbao
//
//  Created by zouf on 16/11/29.
//
//

#import "KQPayViewData.h"
#import "KQPayOrderData.h"
#import "KQPayOrderDataProcess.h"

@implementation KQPayViewDataDetail

- (instancetype __nullable)initWithPayOrderData:(KQPayOrderData * __nonnull)payOrderData {
    self = [super init];
    if (self) {
        self.lockPayMethod = NO;
        self.lockPayInstalment = NO;
        self.lockPayVoucher = NO;
        self.bindCardType = KQPayBindCardTypeAllCard;
        self.payModeArray = [NSMutableArray array];
        self.payModeDisabledArray = [NSMutableArray array];
        self.activityDic = [NSMutableDictionary dictionary];
        self.enableVoucherDic = [NSMutableDictionary dictionary];
        self.disableVoucherDic = [NSMutableDictionary dictionary];
        self.defaultStageDic = [NSMutableDictionary dictionary];
        self.installmentDic = [NSMutableDictionary dictionary];
        self.payOrderData = payOrderData;
    }
    return self;
}

- (instancetype __nullable)initWithPayUnNeedOrderData:(KQPayUnNeedOrderData * __nonnull)payOrderData {
    self = [super init];
    if (self) {
        self.lockPayMethod = NO;
        self.lockPayInstalment = NO;
        self.lockPayVoucher = NO;
        self.bindCardType = KQPayBindCardTypeDebitCard;
        self.enableVoucherDic = [NSMutableDictionary dictionary];
        self.disableVoucherDic = [NSMutableDictionary dictionary];
        self.payOrderData = [[KQPayOrderData alloc] init];
    }
    return self;
}

@end

@implementation KQPayViewDataPayment

- (instancetype __nullable)initWithPayViewDataDetail:(KQPayViewDataDetail * __nonnull)payViewDataDetail {
    self = [super init];
    if (self) {
        self.payNeedSms = NO;
        self.payViewDataDetail = payViewDataDetail;
    }
    return self;
}

- (void)setSelectedPayMode:(NSString *)selectedPayMode {
    //支付方式产生变化，需要支付的金额和权益券也要修改，即支付金额复原，权益券取消选择，锁定状态也要取消
    _selectedPayMode = selectedPayMode;
    self.payAmount = self.payViewDataDetail.payOrderResultData.orderAmount;
    self.selectedPayVoucher = nil;
    self.payViewDataDetail.lockPayVoucher = NO;
    //选择默认优惠券
    NSMutableArray *voucherArray = [self.payViewDataDetail.enableVoucherDic objectForKey:_selectedPayMode];
    if ([voucherArray count] > 0) {
        self.selectedPayVoucher = [voucherArray firstObject];
    }
}

- (void)setSelectedPayVoucher:(KQPayVoucher *)selectedPayVoucher {
    //优惠券信息产生变化，需要支付的金额也要修改
    _selectedPayVoucher = selectedPayVoucher;
    if (selectedPayVoucher) {
        //这个对应选择新的权益券
        self.payAmount = selectedPayVoucher.payAmount;
    }
    else {
        //这个对应取消选择权益券
        self.payAmount = self.payViewDataDetail.payOrderResultData.orderAmount;
    }
}

- (void)resetParam {
    self.payPassword = @"";
    self.payNeedSms = NO;
    self.paySms = @"";
    self.token = @"";
}

@end

@implementation KQPayViewDataResult

- (id)init {
    self = [super init];
    if (self) {
        self.payResult = NO;
    }
    return self;
}

@end
