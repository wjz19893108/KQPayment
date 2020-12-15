//
//  KQPayOrderDataProcess.m
//  KQProcess
//
//  Created by zouf on 17/1/4.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQPayOrderDataProcess.h"

@implementation KQPayOrderResultData

@end

@implementation KQPayInstalment

@end

@implementation KQPayVoucher

- (BOOL)isEqualToVoucher:(KQPayVoucher *)voucher {
    if (!voucher) {
        return NO;
    }
    
    BOOL haveEqualVoucherNo = (!self.voucherNo && !voucher.voucherNo) || [self.voucherNo isEqualToString:voucher.voucherNo];
    
    return haveEqualVoucherNo;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[KQPayVoucher class]]) {
        return NO;
    }
    
    return [self isEqualToVoucher:(KQPayVoucher *)object];
}

- (NSUInteger)hash {
    return [self.voucherNo hash];
}

@end

@implementation KQPaymentResultData

@end

@implementation KQPayRiskData

@end

@implementation KQPaySmsData

@end

@implementation KQPayInterested

@end

@implementation KQPaymentData

@end

@implementation KQPayActivity

@end

@implementation KQQueryPayResultData

@end

@implementation KQQueryRequestData

@end

@implementation KQPayOrderDataProcess

+ (KQPayOrderResultData * __nullable)getPayOrderResultDataFromObj:(Content* __nonnull)response
{
    KQPayOrderResultData *payOrderResultData = [[KQPayOrderResultData alloc] init];
    payOrderResultData.appId = response.appId;
    payOrderResultData.merchantCode = response.merchantCode;
    payOrderResultData.channelType = response.channelType;
    payOrderResultData.orderType = response.orderType;
    payOrderResultData.outTradeNo = response.outTradeNo;
    payOrderResultData.billOrderNo = response.billOrderNo;
//    payOrderResultData.resultCode = response.resultCode;
//    payOrderResultData.errorCode = response.errorCode;
//    payOrderResultData.errorInfo = response.errorInfo;
    payOrderResultData.orderStatus = response.orderStatus;
    payOrderResultData.orderAmount = [response.orderAmount kqb_decrypt];
    payOrderResultData.outOrderType = response.outOrderType;
    payOrderResultData.txnTimeStart = response.txnTimeStart;
    payOrderResultData.txnTimeExpire = response.txnTimeExpire;
    payOrderResultData.payStatus = response.payStatus;
    payOrderResultData.productInfo = [NSMutableArray array];
    payOrderResultData.payMethod = [NSMutableArray array];
    payOrderResultData.instalment = [NSMutableArray array];
    payOrderResultData.voucher = [NSMutableArray array];
    payOrderResultData.activityList = [NSMutableArray array];
    payOrderResultData.status = response.status;
    payOrderResultData.memo = response.memo;
    payOrderResultData.subMerchantName = response.subMerchantName;
    payOrderResultData.type = response.type;
    payOrderResultData.stlMerchantCode = response.stlMerchantCode;
    //TODO
    payOrderResultData.outEquityCode = response.outEquityCode;
    payOrderResultData.outEquityAmount = response.outEquityAmount;
    payOrderResultData.defaultStage = response.stages;
    
//    if (response.productInfo.count > 0) {
//        ContentProductInfo *productInfo = response.productInfo[0];
    payOrderResultData.productDesc = response.productInfo.productDesc;
//    }
    
    if (/*[NSString kqc_isBlank:payOrderResultData.appId]||*/[NSString kqc_isBlank:payOrderResultData.merchantCode]||[NSString kqc_isBlank:payOrderResultData.channelType]||[NSString kqc_isBlank:payOrderResultData.outTradeNo]||[NSString kqc_isBlank:payOrderResultData.billOrderNo]||[NSString kqc_isBlank:payOrderResultData.orderAmount]) {
        return nil;
    }
    
    [response.payMethod enumerateObjectsUsingBlock:^(ContentPayMethod *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQPayMethod *data = [KQPayOrderDataProcess getPayMethodFromObj:obj];
        if (data) {
            [payOrderResultData.payMethod addObject:data];
        }
    }];
    
    [response.instalment enumerateObjectsUsingBlock:^(ContentInstalment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQPayInstalment *instalment = [KQPayOrderDataProcess getPayInstalmentFromObj:obj];
        if (instalment) {
            [payOrderResultData.instalment addObject:instalment];
        }
    }];
    
    [response.voucher enumerateObjectsUsingBlock:^(ContentVoucher *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQPayVoucher *voucher = [KQPayOrderDataProcess getPayVoucherFromObj:obj];
        if (voucher) {
            [payOrderResultData.voucher addObject:voucher];
        }
    }];
    
    [response.interests enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQPayVoucher *interest = [KQPayOrderDataProcess getPayInterestFromObj:obj payAmount:payOrderResultData.orderAmount];
        if (interest) {
            [payOrderResultData.voucher addObject:interest];
        }
    }];
    
    [response.activity enumerateObjectsUsingBlock:^(ContentActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQPayActivity *voucher = [KQPayOrderDataProcess getKQPayActivityFromObj:obj];
        if (voucher) {
            [payOrderResultData.activityList addObject:voucher];
        }
    }];
    
    return payOrderResultData;
}

+ (KQPayMethod * __nullable)getPayMethodFromObj:(ContentPayMethod* __nonnull)obj
{
    KQPayMethod *payMethod = [[KQPayMethod alloc] init];
    payMethod.methodId = obj.methodId;
    payMethod.bankCard = obj.bankCard;
    payMethod.bankName = obj.bankName;
    payMethod.bankId = obj.bankId;
    payMethod.payType = obj.payType;
    payMethod.phoneNo = [obj.phoneNo kqb_decrypt];
    payMethod.desc = obj.desc;
    payMethod.remainingSum = [obj.remainingSum kqb_decrypt];
    payMethod.limitInfo = [obj.limitInfo kqb_decrypt];
    payMethod.available = obj.available;
    payMethod.displayName = [obj.displayName kqb_decrypt];
    payMethod.icon = obj.icon;
    payMethod.status = obj.status;
    payMethod.isStagable = [obj.isStagable isEqualToString:@"true"];
    payMethod.memberBankAcctId = obj.memberBankAcctId;
    
    if ([NSString kqc_isBlank:payMethod.methodId]||[NSString kqc_isBlank:payMethod.payType]) {
        return nil;
    }
    
    return payMethod;
}

+ (KQPayInstalment * __nullable)getPayInstalmentFromObj:(ContentInstalment* __nonnull)obj
{
    KQPayInstalment *installment = [[KQPayInstalment alloc] init];
    installment.id = obj.id;
    installment.stageNumber = obj.stageCount;
    installment.rate = obj.feeRate;
    installment.cost = obj.cost;
    installment.repay = obj.repay;
    installment.total = obj.total;
    installment.instalmentType = obj.instalmentType;
    
    installment.stageInfo = obj.stageInfo;
    installment.feeInfo = obj.feeInfo;
    installment.totalfeeInfo = obj.totalFeeInfo;

    if ([NSString kqc_isBlank:installment.id]/*||[NSString kqc_isBlank:installment.instalmentType]*/) {
        return nil;
    }
    return installment;
}

+ (KQPayVoucher * __nullable)getPayVoucherFromObj:(ContentVoucher* __nonnull)obj
{
    KQPayVoucher *voucher = [[KQPayVoucher alloc] init];
    voucher.voucherInfo = obj.voucherInfo;
    voucher.name = obj.name;
    voucher.expDate = obj.expDate;
    voucher.status = obj.status;
    voucher.voucherNo = obj.voucherNo;
    voucher.voucherAmount = [obj.voucherAmount kqb_decrypt];
    voucher.payAmount = [obj.payAmount kqb_decrypt];
    voucher.voucherType = KQPayVoucherTypeActive;
    voucher.supportedMethodIdList = [NSArray arrayWithArray:obj.supportedMethodIdList];
    voucher.sourceFrom = KQPayVoucherFromNone;
    if ([NSString kqc_isBlank:voucher.status]||[NSString kqc_isBlank:voucher.voucherNo]||[NSString kqc_isBlank:voucher.voucherAmount]||[NSString kqc_isBlank:voucher.payAmount]) {
        return nil;
    }
    return voucher;
}

+ (KQPayVoucher * __nullable)getPayInterestFromObj:(ContentInterest* __nonnull)obj payAmount:(NSString *)payAmount
{
    //TODO:数据 PK
    KQPayVoucher *voucher = [[KQPayVoucher alloc] init];
    
    voucher.voucherNo = obj.oid;
    voucher.name = obj.name;
    voucher.instruction = obj.instruction;
    voucher.status = obj.status;
    voucher.supportedMethodIdList = obj.supportedMethodIdList;
    voucher.voucherAmount = obj.discountAmount;
    voucher.voucherType = KQPayVoucherTypePassive;
    voucher.payAmount = obj.payAmount;
    voucher.expDate = obj.expDate;
    voucher.voucherInfo = obj.interestInfo;
    voucher.mediaType = obj.voucherType;
    voucher.sourceFrom = KQPayVoucherFromNone;
    if([@"MSXF" isEqualToString:obj.sourceFrom]){
        voucher.sourceFrom = KQPayVoucherFromMSXF;
    }
    if([@"VAS" isEqualToString:obj.sourceFrom]){
        voucher.sourceFrom = KQPayVoucherFromVAS;
    }
//    //****** MBP 未返回payAmout，7.26 上线后删除计算
//    if ([NSString kqc_isBlank:voucher.payAmount]) {
//        NSInteger calculatedPayAmount = payAmount.integerValue - voucher.voucherAmount.integerValue;
//        if (calculatedPayAmount >= 0) {
//            voucher.payAmount = KQC_FORMAT(@"%ld", (unsigned long)calculatedPayAmount);
//        }
//    }
//    //******
    
    if ([NSString kqc_isBlank:voucher.status]||[NSString kqc_isBlank:voucher.voucherNo]||[NSString kqc_isBlank:voucher.voucherAmount]||[NSString kqc_isBlank:voucher.payAmount]) {
        return nil;
    }
    return voucher;
}

+ (KQPayActivity * __nullable)getKQPayActivityFromObj:(ContentActivity * __nonnull)obj
{
    KQPayActivity *activity = [[KQPayActivity alloc] init];
    activity.activeId = obj.activeId;
    activity.shortMsg = obj.shortMsg;
    activity.message = obj.message;
    activity.payType = obj.payType;
    
    if ([NSString kqc_isBlank:activity.message]||[NSString kqc_isBlank:activity.activeId]) {
        return nil;
    }
    return activity;
}

+ (KQPayRiskData * __nullable)getPayRiskDataFromObj:(KQPayOrderResultData* __nonnull)obj
{
    KQPayRiskData *riskData = [[KQPayRiskData alloc] init];
    riskData.outTradeNo = obj.outTradeNo;
    riskData.channelType = obj.channelType;
    riskData.payAmount = obj.orderAmount;
    riskData.merchantCode = obj.merchantCode;
    riskData.sysVersion = [KQCApplication version];
    riskData.orderType = obj.orderType;
    
    if ([NSString kqc_isBlank:riskData.outTradeNo]||[NSString kqc_isBlank:riskData.channelType]||[NSString kqc_isBlank:riskData.payAmount]||[NSString kqc_isBlank:riskData.merchantCode]) {
        return nil;
    }
    
    return riskData;
}

+ (KQPaySmsData * __nullable)getPaySmsDataFromObj:(KQPayOrderResultData* __nonnull)obj
{
    KQPaySmsData *paySmsData = [[KQPaySmsData alloc] init];
    paySmsData.appId = obj.appId;
    //phoneNo剥离 feng.zou 2016-03-22
    //paySmsData.phone = KQB_CurrentUser.phoneNo;
    paySmsData.outTradeNo = obj.outTradeNo;
    paySmsData.merchantCode = obj.merchantCode;
    
    if ([NSString kqc_isBlank:paySmsData.appId]/*||[NSString kqc_isBlank:paySmsData.phone]*/||[NSString kqc_isBlank:paySmsData.outTradeNo]||[NSString kqc_isBlank:paySmsData.merchantCode]) {
        return nil;
    }
    
    return paySmsData;
}

+ (KQPaySmsData * __nullable)getUnNeedPaySmsDataFromObj:(KQPayUnNeedOrderData* __nonnull)obj{
    KQPaySmsData *paySmsData = [[KQPaySmsData alloc] init];
    paySmsData.outTradeNo = obj.outTradeNo;
    paySmsData.merchantCode = obj.merchantCode;
    
    if ([NSString kqc_isBlank:paySmsData.outTradeNo]||[NSString kqc_isBlank:paySmsData.merchantCode]) {
        return nil;
    }
    
    return paySmsData;
}

+ (KQPaymentData * __nullable)getPaymentDataFromObj:(KQPayOrderResultData* __nonnull)obj
{
    KQPaymentData *paymentData = [[KQPaymentData alloc] init];
    paymentData.appId = obj.appId;
    paymentData.merchantCode = obj.merchantCode;
    paymentData.billOrderNo = obj.billOrderNo;
    paymentData.outTradeNo = obj.outTradeNo;
    paymentData.channelType = obj.channelType;
    paymentData.orderAmount = obj.orderAmount;
    paymentData.orderType = obj.orderType;
    
    if (/*[NSString kqc_isBlank:paymentData.appId]||*/[NSString kqc_isBlank:paymentData.merchantCode]||[NSString kqc_isBlank:paymentData.billOrderNo]||[NSString kqc_isBlank:paymentData.outTradeNo]||[NSString kqc_isBlank:paymentData.channelType]||[NSString kqc_isBlank:paymentData.orderAmount]) {
        return nil;
    }
    
    return paymentData;
}

+ (NSArray * __nullable)getPayStageDataFromObj:(Content* __nonnull)response{
    NSMutableArray *stageList = [NSMutableArray array];
    
    NSArray *stageArr = response.instalment;
    [stageArr enumerateObjectsUsingBlock:^(ContentInstalment * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQPayInstalment *instalment = [KQPayOrderDataProcess getPayInstalmentFromObj:obj];
        if (instalment) {
            [stageList addObject:instalment];
        }
    }];
    return stageList;
}

+ (NSString * __nullable)getPayDefaultStageFromObj:(Content* __nonnull)response{
    return response.stages;
}

+ (KQPaymentData * __nullable)getUnNeedOrderPaymentDataFromObj:(KQPayUnNeedOrderData* __nonnull)obj
{
    KQPaymentData *paymentData = [[KQPaymentData alloc] init];
    paymentData.merchantCode = obj.merchantCode;
    paymentData.outTradeNo = obj.outTradeNo;
    paymentData.channelType = obj.channelType;
    paymentData.orderAmount = obj.orderAmount;
    paymentData.orderType = obj.orderType;
    
    if ([NSString kqc_isBlank:paymentData.merchantCode]||[NSString kqc_isBlank:paymentData.outTradeNo]||[NSString kqc_isBlank:paymentData.channelType]||[NSString kqc_isBlank:paymentData.orderAmount]) {
        return nil;
    }
    
    return paymentData;
}

+ (KQPaymentResultData * __nullable)getPaymentResultDataFromObj:(Content* __nonnull)obj
{
    KQPaymentResultData *paymentResultData = [[KQPaymentResultData alloc] init];
    paymentResultData.appId = obj.appId;
    paymentResultData.billOrderNo = obj.billOrderNo;
    paymentResultData.orderAmount = [obj.orderAmount kqb_decrypt];
    paymentResultData.payAmount = [obj.payAmount kqb_decrypt];
//    paymentResultData.errorCode = obj.errorCode;
//    paymentResultData.errorInfo = obj.errorInfo;
    paymentResultData.orderStatus = obj.orderStatus;
    paymentResultData.tradeId = obj.tradeId;
    paymentResultData.txnEndTime = obj.txnEndTime;
    paymentResultData.equityAmount = [obj.equityAmount kqb_decrypt];
    
    paymentResultData.amt = obj.amt;
//        paymentResultData.bankAcctName = obj
    paymentResultData.channelType = obj.channelType;
//    paymentResultData.currencyCode = obj
    paymentResultData.merchantCode = obj.merchantCode;
    paymentResultData.orderType = obj.orderType;
    paymentResultData.outEquityAmount = obj.outEquityAmount;
    paymentResultData.outOrderType = obj.outOrderType;
    paymentResultData.payMode = obj.payMode;
    paymentResultData.payStatus = obj.payStatus;
    paymentResultData.queryInterval = obj.queryInterval;
    paymentResultData.queryTimes = obj.queryTimes;
    paymentResultData.subMerchantName = obj.subMerchantName;
    paymentResultData.tradeStatus = obj.tradeStatus;
    paymentResultData.txnTimeStart = obj.txnTimeStart;
    
//    @property (nonatomic, strong, nullable) NSString *bankAcctName;       //银行名称
//    @property (nonatomic, strong, nullable) NSString *currencyCode;       //币种
    //已经到结果了，暂时不对任何字段进行校验
    
    return paymentResultData;
}

+ (KQPaymentResultData * __nullable)getUnNeedOrderPaymentResultDataFromObj:(Content* __nonnull)obj
{
    KQPaymentResultData *paymentResultData = [[KQPaymentResultData alloc] init];
    paymentResultData.billOrderNo = obj.billOrderNo;
    paymentResultData.orderAmount = [obj.orderAmount kqb_decrypt];
    paymentResultData.payAmount = [obj.payAmount kqb_decrypt];
//    paymentResultData.resultCode = obj.resultCode;
//    paymentResultData.errorCode = obj.errorCode;
//    paymentResultData.errorInfo = obj.errorInfo;
    paymentResultData.orderStatus = obj.orderStatus;
    paymentResultData.tradeId = obj.tradeId;
    paymentResultData.txnEndTime = obj.txnEndTime;
    return paymentResultData;
}

+ (void)fillPayOrderDataByPayOrderResultData:(KQPayOrderData * __nonnull)payOrderData payOrderResultData:(KQPayOrderResultData * __nonnull)payOrderResultData {
    if ([NSString kqc_isBlank:payOrderData.appId]) {
        payOrderData.appId = KQC_NON_NIL(payOrderResultData.appId);
    }
    if ([NSString kqc_isBlank:payOrderData.merchantCode]) {
        payOrderData.merchantCode = KQC_NON_NIL(payOrderResultData.merchantCode);
    }
    if ([NSString kqc_isBlank:payOrderData.channelType]) {
        payOrderData.channelType = KQC_NON_NIL(payOrderResultData.channelType);
    }
    if ([NSString kqc_isBlank:payOrderData.orderType]) {
        payOrderData.orderType = KQC_NON_NIL(payOrderResultData.orderType);
    }
    if ([NSString kqc_isBlank:payOrderData.outTradeNo]) {
        payOrderData.outTradeNo = KQC_NON_NIL(payOrderResultData.outTradeNo);
    }
    if ([NSString kqc_isBlank:payOrderData.billOrderNo]) {
        payOrderData.billOrderNo = KQC_NON_NIL(payOrderResultData.billOrderNo);
    }
}

+ (NSDictionary * __nullable)getM251Dic:(KQPayOrderData * __nonnull)payOrderData
{
    NSMutableDictionary *m251Dic = [NSMutableDictionary dictionary];
    if (![NSString kqc_isBlank:payOrderData.appId]) {
        [m251Dic setObject:payOrderData.appId forKey:@"appId"];
    }
    if (![NSString kqc_isBlank:payOrderData.merchantCode]) {
        [m251Dic setObject:payOrderData.merchantCode forKey:@"merchantCode"];
    }
    if (![NSString kqc_isBlank:payOrderData.outTradeNo]) {
        [m251Dic setObject:payOrderData.outTradeNo forKey:@"outTradeNo"];
    }
    if (![NSString kqc_isBlank:payOrderData.billOrderNo]) {
        [m251Dic setObject:payOrderData.billOrderNo forKey:@"billOrderNo"];
    }
    if (![NSString kqc_isBlank:payOrderData.productCode]) {
        [m251Dic setObject:payOrderData.productCode forKey:@"productCode"];
    }
    if (![NSString kqc_isBlank:payOrderData.channelType]) {
        [m251Dic setObject:payOrderData.channelType forKey:@"channelType"];
    }
    if (![NSString kqc_isBlank:payOrderData.orderType]) {
        [m251Dic setObject:payOrderData.orderType forKey:@"orderType"];
    }
    [m251Dic setObject:payOrderData.supportFinger forKey:@"supportFinger"];
    [m251Dic setObject:[KQPayOrderDataProcess stringNilIfTxnFlagIsEmpty:payOrderData.txnFlag] forKey:@"txnFlag"];
    
    return m251Dic;
}

+ (NSDictionary* __nullable)getM271Dic:(KQPayRiskData * __nonnull)payRiskData;
{
    NSMutableDictionary *m271Dic = [NSMutableDictionary dictionary];
    [m271Dic setObject:payRiskData.outTradeNo forKey:@"outTradeNo"];
    [m271Dic setObject:payRiskData.channelType forKey:@"channelType"];
    [m271Dic setObject:payRiskData.payAmount forKey:@"payAmount"];
    [m271Dic setObject:payRiskData.merchantCode forKey:@"merchantCode"];
    if (![NSString kqc_isBlank:payRiskData.validateElement]) {
        [m271Dic setObject:payRiskData.validateElement forKey:@"validateElement"];
    }
//    [m271Dic setObject:payRiskData.sysVersion forKey:@"appVersion"];
    [m271Dic setObject:payRiskData.payMethodId forKey:@"payMethodId"];
    if (![NSString kqc_isBlank:payRiskData.orderType]) {
        [m271Dic setObject:payRiskData.orderType forKey:@"orderType"];
    }
    return m271Dic;
}

+ (NSDictionary* __nullable)getM270Dic:(KQPaySmsData * __nonnull)paySmsData
{
    NSMutableDictionary *m270Dic = [NSMutableDictionary dictionary];
    [m270Dic setObject:paySmsData.appId forKey:@"appId"];
    //phoneNo剥离 feng.zou 2016-03-22
    //[m270Dic setObject:paySmsData.phone forKey:@"phone"];
    [m270Dic setObject:paySmsData.outTradeNo forKey:@"outTradeNo"];
    [m270Dic setObject:paySmsData.merchantCode forKey:@"merchantCode"];
    return m270Dic;
}
+ (NSDictionary* __nullable)getUnNeedOrderM270Dic:(KQPaySmsData * __nonnull)paySmsData{
    NSMutableDictionary *m270Dic = [NSMutableDictionary dictionary];
    //phoneNo剥离 feng.zou 2016-03-22
    //[m270Dic setObject:paySmsData.phone forKey:@"phone"];
    [m270Dic setObject:paySmsData.outTradeNo forKey:@"outTradeNo"];
    [m270Dic setObject:paySmsData.merchantCode forKey:@"merchantCode"];
    return m270Dic;
}

+ (NSDictionary* __nullable)getM341Dic:(KQPaymentData * __nonnull)paymentData{
    NSMutableDictionary *m341Dic = [NSMutableDictionary dictionary];
    [m341Dic setObject:paymentData.merchantCode forKey:@"merchantCode"];
    [m341Dic setObject:paymentData.outTradeNo forKey:@"outTradeNo"];
    [m341Dic setObject:paymentData.channelType forKey:@"channelType"];
    [m341Dic setObject:paymentData.orderAmount forKey:@"orderAmount"];
    [m341Dic setObject:paymentData.payAmount forKey:@"payAmount"];
    if (![NSString kqc_isBlank:paymentData.payPassword]) {
        [m341Dic setObject:paymentData.payPassword forKey:@"payPassword"];
    }
    [m341Dic setObject:paymentData.payMethodId forKey:@"payMethodId"];
    
    if (![NSString kqc_isBlank:paymentData.sMsCode]) {
        [m341Dic setObject:paymentData.sMsCode forKey:@"sMsCode"];
    }
    if (![NSString kqc_isBlank:paymentData.token]) {
        [m341Dic setObject:paymentData.token forKey:@"token"];
    }
    if (![NSString kqc_isBlank:paymentData.orderType]) {
        [m341Dic setObject:paymentData.orderType forKey:@"orderType"];
    }
    if (![NSString kqc_isBlank:paymentData.province]) {
        [m341Dic setObject:paymentData.province forKey:@"province"];
    }
    if (![NSString kqc_isBlank:paymentData.city]) {
        [m341Dic setObject:paymentData.city forKey:@"city"];
    }
    if (![NSString kqc_isBlank:paymentData.branchBank]) {
        [m341Dic setObject:paymentData.branchBank forKey:@"branchBank"];
    }
    if (![NSString kqc_isBlank:paymentData.businessType]) {
        [m341Dic setObject:paymentData.businessType forKey:@"businessType"];
    }
    
    [m341Dic setObject:[KQPayOrderDataProcess stringNilIfTxnFlagIsEmpty:paymentData.txnFlag] forKey:@"txnFlag"];
    return m341Dic;
}

+ (NSDictionary* __nullable)getM250Dic:(KQPaymentData * __nonnull)paymentData
{
    NSMutableDictionary *m250Dic = [NSMutableDictionary dictionary];
//    [m250Dic setObject:paymentData.appId forKey:@"appId"];
    [m250Dic setObject:paymentData.merchantCode forKey:@"merchantCode"];
    [m250Dic setObject:paymentData.billOrderNo forKey:@"billOrderNo"];
    [m250Dic setObject:paymentData.outTradeNo forKey:@"outTradeNo"];
    [m250Dic setObject:paymentData.channelType forKey:@"channelType"];
    [m250Dic setObject:paymentData.orderAmount forKey:@"orderAmount"];
    [m250Dic setObject:paymentData.payAmount forKey:@"payAmount"];
    
    if (![NSString kqc_isBlank:paymentData.payPassword]) {
        [m250Dic setObject:paymentData.payPassword forKey:@"payPassword"];
    }
    [m250Dic setObject:paymentData.payMethodId forKey:@"payMethodId"];
    if (![NSString kqc_isBlank:paymentData.authCode]) {
        [m250Dic setObject:paymentData.authCode forKey:@"authCode"];
    }
    if (![NSString kqc_isBlank:paymentData.equityCode]) {
        [m250Dic setObject:paymentData.equityCode forKey:@"equityCode"];
    }
    if (![NSString kqc_isBlank:paymentData.equityAmount]) {
        [m250Dic setObject:paymentData.equityAmount forKey:@"equityAmount"];
    }
    if (![NSString kqc_isBlank:paymentData.outEquityCode]) {
        [m250Dic setObject:paymentData.outEquityCode forKey:@"outEquityCode"];
    }
    if (![NSString kqc_isBlank:paymentData.outEquityAmount]) {
        [m250Dic setObject:paymentData.outEquityAmount forKey:@"outEquityAmount"];
    }
    if (![NSString kqc_isBlank:paymentData.instalmentId]) {
        [m250Dic setObject:paymentData.instalmentId forKey:@"instalmentId"];
    }
    if (![NSString kqc_isBlank:paymentData.sMsCode]) {
        [m250Dic setObject:paymentData.sMsCode forKey:@"sMsCode"];
    }
    if (![NSString kqc_isBlank:paymentData.token]) {
        [m250Dic setObject:paymentData.token forKey:@"token"];
    }
    if (![NSString kqc_isBlank:paymentData.notifyMode]) {
        [m250Dic setObject:paymentData.notifyMode forKey:@"notifyMode"];
    }
    if (![NSString kqc_isBlank:paymentData.orderType]) {
        [m250Dic setObject:paymentData.orderType forKey:@"orderType"];
    }
    if (![NSString kqc_isBlank:paymentData.stageCount]) {
        [m250Dic setObject:KQC_NON_NIL(paymentData.stageCount) forKey:@"stageCount"];
    }
    
    if (![NSString kqc_isBlank:paymentData.feeRate]) {
        [m250Dic setObject:KQC_NON_NIL(paymentData.feeRate) forKey:@"feeRate"];
    }
    
    if (![NSString kqc_isBlank:paymentData.stlMerchantCode]) {
        [m250Dic setObject:KQC_NON_NIL(paymentData.stlMerchantCode) forKey:@"stlMerchantCode"];
    }
    
    [m250Dic setObject:[KQPayOrderDataProcess stringNilIfTxnFlagIsEmpty:paymentData.txnFlag] forKey:@"txnFlag"];
    if (paymentData.equityInfo && (paymentData.equityInfo.count > 0) ) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paymentData.equityInfo options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
        [m250Dic setObject:KQC_NON_NIL(jsonString) forKey:@"equityMessage"];
    }
    return m250Dic;
}
// TODO
//+ (NSDictionary * __nullable)getM315Dic:(KQPayStageData * __nonnull)payStageData{
//    NSMutableDictionary *m315Dic = [NSMutableDictionary dictionary];
//    [m315Dic setObject:KQC_NON_NIL(payStageData.pwid) forKey:@"pwid"];
//    [m315Dic setObject:KQC_NON_NIL(payStageData.merchantCode) forKey:@"merchantCode"];
//    [m315Dic setObject:KQC_NON_NIL(payStageData.orderAmount) forKey:@"orderAmount"];
//    [m315Dic setObject:KQC_NON_NIL(payStageData.orderType) forKey:@"orderType"];
//    [m315Dic setObject:KQC_NON_NIL(payStageData.payMethodId) forKey:@"payMethodId"];
//    
//    return m315Dic;
//}

+ (KQPayRiskData * __nullable)getPayRiskDataFromUnNeedOrder:(KQPayUnNeedOrderData* __nonnull)obj{
    KQPayRiskData *riskData = [[KQPayRiskData alloc] init];
    riskData.outTradeNo = obj.outTradeNo;
    riskData.channelType = obj.channelType;
    riskData.payAmount = obj.orderAmount;
    riskData.merchantCode = obj.merchantCode;
    riskData.sysVersion = [KQCApplication version];
    
    if ([NSString kqc_isBlank:riskData.outTradeNo]||[NSString kqc_isBlank:riskData.channelType]||[NSString kqc_isBlank:riskData.payAmount]||[NSString kqc_isBlank:riskData.merchantCode]) {
        return nil;
    }
    
    return riskData;
}

+ (NSString * __nonnull)stringNilIfTxnFlagIsEmpty:(NSString * __nullable)txnFlag {
    return [NSString kqc_isBlank:txnFlag]?@"nil":txnFlag;
}

@end
