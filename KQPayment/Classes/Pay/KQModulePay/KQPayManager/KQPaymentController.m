//
//  KQPaymentController.m
//  kuaiQianbao
//
//  Created by zouf on 16/1/15.
//
//

#import "KQPaymentController.h"
#import "KQPayDataInterface.h"
#import "KQPayUIManager.h"
#import "KQPaymentInfoBaseVC.h"
#import "KQPayViewData.h"
#import "KQPayOrderDataProcess.h"
#import "KQPayStatisticsMacro.h"
#import "KQPaymentMacro.h"
#import "KQPayHelpWebVC.h"
//#import "KQFidoSDKDataModel.h"
#import "KQUnivelsalAlertContainer.h"

#define KQPAYMENT_PASSWORD_FINGER_SMS       @"1201000000"
#define KQPAYMENT_PASSWORD_SMS              @"1200000000"
#define KQPAYMENT_PASSWORD                  @[@"1000000000", @"2002010000", @"2102010000"]

#define PAY_RESULT_URL  @"https://oms-cloud.99bill.com/prod/html/fft-paysuccess/default.html"

#define MallStages @[KQPayMethodPayTypeCreditCard, KQPayMethodPayTypeInstallment]
@interface KQPaymentController () <KQPaymentInfoBaseVCDelegate, KQPayViewStepBaseDelegate, KQPayViewStepDetailDelegate, KQPayViewStepModeDelegate, KQPayViewStepInstallmentDelegate, KQPayViewStepVoucherDelegate, KQPayViewStepAllVoucherDelegate, KQPayViewStepNoneVoucherDelegate, KQPayViewStepPasswordDelegate, KQPayViewStepSmsDelegate, KQPayViewStepCvv2Delegate, KQPayViewStepResultDelegate>

@property (nonatomic, weak) KQPaymentInfoBaseVC *currentVC;               //自己生成一个vc
@property (nonatomic, strong) KQPayUIManager *payUIManager;
@property (nonatomic, weak) id<KQPayDetailLoadingTypeDelegate> loadingTypeDelegate;
@property (nonatomic, assign) KQPayViewStep backFromView;

@end

@implementation KQPaymentController

SYNTHESIZE_SINGLETON_FOR_CLASS(KQPaymentController);

- (void)pay:(KQPayOrderData *)payOrderData delegate:(id<KQPayManagerDelegate>)delegate {
    [UnivelsalAlertContainer dismissAllUnivelsalAlert];
    self.payMethodInfo = nil;
    self.payAdditionalInfo = nil;
    self.payOrderData = payOrderData;
    self.unNeedOrderData = nil;
    self.delegate = delegate;
    self.oldPayOrderResultData = nil;
    self.resultDic = nil;
    [self initBackView];
}

- (void)payUnNeedOrder:(KQPayUnNeedOrderData *)payOrderData delegate:(id<KQPayManagerDelegate>)delegate {
    [UnivelsalAlertContainer dismissAllUnivelsalAlert];
    self.payMethodInfo = nil;
    self.payOrderData = nil;
    self.payAdditionalInfo = nil;
    self.unNeedOrderData = payOrderData;
    self.delegate = delegate;
    self.oldPayOrderResultData = nil;
    self.resultDic = nil;
    [self initBackView];
}

- (BOOL)existVCinNavs:(KQPaymentInfoBaseVC *)currentVC {
    NSArray *viewControllers = [KQC_Engine_UI topViewController].navigationController.childViewControllers;
    for (UIViewController *viewController in [viewControllers reverseObjectEnumerator]) {
        if (currentVC == viewController) {
            return YES;
        }
    }
    
    return NO;
}

- (void)initBackView {
    //self.currentVC不为nil，表示是重复进来
    if (self.currentVC && [self existVCinNavs:self.currentVC]) {
        //判断是否在支线流程
        if ([KQC_Engine_UI topViewController] != self.currentVC) {
            [KQC_Engine_UI popToViewController:self.currentVC];
        }
        [self.currentVC changeBackGround:self.internalCall];
    } else {
        self.currentVC = (KQPaymentInfoBaseVC*)[KQC_Engine_UI showViewControllerWithName:@"KQPaymentInfoBaseVC" param:@{@"internalCall":@(self.internalCall),@"backImage":[UIImage kqc_screenShot]} animated:NO];
    }
    self.currentVC.delegate = self;
    
    [self startPay];
}

#pragma  mark- KQPaymentInfoBaseVCDelegate
- (void)KQPaymentInfoBaseVCDidShow {
    [self.payUIManager stayHere];
}

- (void)KQPaymentInfoBaseVCTaped {
    [self paymentClose:KQPayCanceled errorNo:ERROR_CODE_USER_CANCEL];
}

#pragma  mark- KQPayViewStepBaseDelegate
- (void)back:(KQPayViewStep)viewStep {
    if (viewStep == KQPayViewStepDetail) {
        //Add by chenyidong 2017年4月11日  版本3.1.5
        [KQCStatisticsManager logEvent:KQ_TONGYIZHIFU_FUKUANXIANGQING_QUXIAO attributes:@{@"fukuanfangshi":KQC_NON_NIL([self selectedPayModeDesc]),@"fenqifangshi":KQC_NON_NIL([self selectedInstalment])}];
        [self closeAllPayView:KQPayCanceled errorNo:ERROR_CODE_USER_CANCEL];
    } else if (viewStep == KQPayViewStepResult) {
        if (self.payViewDataResult.payResult) {
            [self closeAllPayView:KQPaySuccessful errorNo:ERROR_CODE_UNKOWN];
        } else {
            [self closeAllPayView:KQPayFailed errorNo:ERROR_CODE_PAY_FAILED];
        }
    } else {
        if (self.unNeedOrderData && viewStep == KQPayViewStepPassword) {
            [PaymentController closeAllPayView:KQPayCanceled errorNo:ERROR_CODE_USER_CANCEL];
            return;
        }
        [self popPayView];
    }
}

- (BOOL)canBindCard {
    return self.payViewDataDetail.bindCardType != KQPayBindCardTypeNoneCard;
}

- (NSString * __nullable)anYiHuaPayStatus {
    __block NSString *anYiHuaStatus = @"";
    __block BOOL maShangPayTpye;
    [PaymentController.payViewDataDetail.payModeDisabledArray enumerateObjectsUsingBlock:^(KQPayMethod *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([KQPayMethodPayTypeMaShang isEqualToString:obj.payType]) {
            anYiHuaStatus = obj.status;
            maShangPayTpye = YES;
            *stop = YES;
        }
    }];
    
    if([@"180008" isEqualToString:self.payOrderData.orderType] && !maShangPayTpye){
        anYiHuaStatus = @"-1";
    }
    return anYiHuaStatus;
}

#pragma  mark- KQPayViewStepDetailDelegate

- (BOOL)isInAppCall {
    return self.internalCall;
}

- (void)getColumnInfo:(KQPayDetailInfoType)infoType resultBlock:(void(^__nullable)(NSString * __nullable info, BOOL canSelected, NSString * activityMsg, BOOL hasActivity))resultBlock {
    NSString * info = @"";
    BOOL canSelected = NO;
    NSString * activityMsg = @"";
    if (infoType == KQPayDetailInfoTypeMerchantName) {
        if (![NSString kqc_isBlank:self.payViewDataDetail.payOrderData.merchantName]) {
            info = self.payViewDataDetail.payOrderData.merchantName;
        } else if (![NSString kqc_isBlank:self.payViewDataDetail.payOrderResultData.subMerchantName]) {
            info = self.payViewDataDetail.payOrderResultData.subMerchantName;
        } else {
            info = self.payViewDataDetail.payOrderResultData.productDesc;
        }
    } else if (infoType == KQPayDetailInfoTypeAccountName) {
        info = self.payViewDataDetail.accountDisplayName;
    } else if (infoType == KQPayDetailInfoTypePaymentMode) {
        if (!self.payViewDataDetail.lockPayMethod) {
            canSelected = YES;
        }
        for (KQPayMethod *data in self.payViewDataDetail.payOrderResultData.payMethod) {
            if ([data.methodId isEqualToString:self.payViewDataPayment.selectedPayMode]) {
                NSString *stageInfo = self.payViewDataPayment.selectedInstallment.stageNumber;
                if ([KQPayMethodPayTypeMaShang isEqualToString:data.payType] && ![NSString kqc_isBlank:stageInfo]) {
                    info = [NSString stringWithFormat:@"%@(分%@期)", data.displayName, stageInfo];
                }else{
                    info = data.displayName;
                }
            }
        }
        KQPayActivity *payActivity = self.payViewDataDetail.activityDic[self.payViewDataPayment.selectedPayType];
        activityMsg = payActivity.shortMsg;

    } else if (infoType == KQPayDetailInfoTypeInstallmentMode) {
        if (!self.payViewDataDetail.lockPayInstalment) {
            canSelected = YES;
        }
        
        if (self.payViewDataPayment.selectedInstallment) {
            if (![NSString kqc_isBlank:self.payViewDataPayment.selectedInstallment.stageInfo]) {
                info = self.payViewDataPayment.selectedInstallment.stageInfo;
            } else {
                if ([self.payViewDataPayment.selectedInstallment.instalmentType isEqualToString:KQPayMethodPayTypeCreditCard]) {
                    info = [NSString stringWithFormat:@"￥%.2f×%@期(银行免息分期)", [self.payViewDataPayment.selectedInstallment.repay doubleValue], self.payViewDataPayment.selectedInstallment.stageNumber];
                }else{
                    info = [NSString stringWithFormat:@"分%@期(费率%.2f%%/月)", self.payViewDataPayment.selectedInstallment.stageNumber, [self.payViewDataPayment.selectedInstallment.rate doubleValue]*100];
                }
            }
        }
    } else if (infoType == KQPayDetailInfoTypeVoucher) {
        if (!self.payViewDataDetail.lockPayVoucher) {
            canSelected = YES;
        }
        for (KQPayVoucher *data in self.payViewDataDetail.payOrderResultData.voucher) {
            if (data == self.payViewDataPayment.selectedPayVoucher) {
                if (data.voucherAmount.integerValue == 0) {
                    info = data.name;
                } else {
                    info = [NSString stringWithFormat:@"%@:省%@元",data.name,[KQCAmount getDecimalAmount:data.voucherAmount]];
                }
                
            }
        }
        
    } else if (infoType == KQPayDetailInfoTypeRemark) {
        info = self.payViewDataDetail.payOrderResultData.memo;
    } else if (infoType == KQPayDetailInfoTypeOrderAmount) {
        info = [NSString stringWithFormat:@"%@元", [KQCAmount getDecimalAmount:self.payViewDataPayment.payAmount amountUnit:KQCAmountUnitTypeFen]];
    }
    
    if (resultBlock) {
        resultBlock(info, canSelected, activityMsg, [self hasActivity]);
    }
}

- (NSString *)orderAmt{
    NSString *payAmount = self.payViewDataDetail.payOrderResultData.orderAmount;
    return payAmount;
}

- (void)selectColumn:(KQPayDetailInfoType)infoType {
    if (infoType == KQPayDetailInfoTypePaymentMode) {
        NSString *status = [self anYiHuaPayStatus];
        if (([@"1" isEqualToString:status] || [@"2" isEqualToString:status]) && [PaymentController.payViewDataDetail.payModeArray count] == 0) {//已逾期 授信过期
            //关闭统一支付 跳转安逸花
            [self paymentClose:KQPayCanceled errorNo:ERROR_CODE_USER_CANCEL];
            [KQCStatisticsManager logEvent:@"wode_anyihua"];
            [KQC_Engine_UI showViewControllerWithName:@"KQBaseWebVC" param:@{@"targetUrl":@"https://oms-cloud.99bill.com/prod/html/finance-mall/msjf/index.html"}];
        }
        if (self.payViewDataDetail.lockPayMethod) {
            return;
        }
        //冻结不可解冻，不可选择其他支付方式
        if (self.payViewDataDetail.payOrderData.freezeState == KQPayAccountFreezeUnLock) {
            [self accountFreezeAlert];
            return;
        }
        [self pushPayView:KQPayViewStepMode delegate:self withParam:nil completion:nil];
    }
    else if (infoType == KQPayDetailInfoTypeInstallmentMode) {
        if (self.payViewDataDetail.lockPayInstalment) {
            return;
        }
        [self pushPayView:KQPayViewStepInstallment delegate:self withParam:nil completion:nil];
    }
    else if (infoType == KQPayDetailInfoTypeVoucher) {
        if (self.payViewDataDetail.lockPayVoucher) {
            return;
        }
        //如果没有可用的优惠券，弹出的页面是KQPayNoneVoucherNavigateView；只要有一张可用的优惠券，弹出的页面就是KQPayVoucherNavigateView
        NSArray *enableVoucher = [self.payViewDataDetail.enableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
        NSArray *disableVoucher = [self.payViewDataDetail.disableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
        if ((enableVoucher.count + disableVoucher.count) > 0) {
            [self pushPayView:KQPayViewStepVoucher delegate:self withParam:nil completion:nil];
        }
        else {
            [self pushPayView:KQPayViewStepNoneVoucher delegate:self withParam:nil completion:nil];
        }
    }
}

// 是否显示订单信息商户名称
- (BOOL)orderInformationShow {
    return [FunctionSwitchManager.merchantNameVisible isEqualToString:@"1"];
}

- (NSUInteger)vouchersCount {
    //APP-9737，只取可用优惠券数量
    NSArray *enableVoucher = [self.payViewDataDetail.enableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
//    NSArray *disableVoucher = [self.payViewDataDetail.disableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
    return enableVoucher.count/* + disableVoucher.count*/;
}

-(NSUInteger)allVouchersCount {
    NSArray *enableVoucher = [self.payViewDataDetail.enableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
    NSArray *disableVoucher = [self.payViewDataDetail.disableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
    return enableVoucher.count + disableVoucher.count;
}
- (BOOL)hasInstalmentInfo {
    //马上分期 不在首页显示
    if ([KQPayMethodPayTypeMaShang isEqualToString:self.payViewDataPayment.selectedPayType]) {
        return false;
    }
    return ([self instalmentArray].count > 0);
}

- (NSString * __nullable)getCurrentProductCode {
    return self.payViewDataDetail.payOrderData.productCode;
}

- (BOOL)canUseVoucher {
    return self.payOrderData.useVoucher;
}

// 统一支付不需要银联优惠
- (BOOL)canUserUPayVoucher{
    return NO;
}

- (KQPayVoucherSourceFrom)maShangVoucherFrom{
    if ([KQPayMethodPayTypeMaShang isEqualToString:self.payViewDataPayment.selectedPayType]) {
        KQPayVoucher *vourch = self.payViewDataPayment.selectedPayVoucher;
        if (!vourch) {
            return KQPayUnuseVoucher;
        }
        return vourch.sourceFrom;
    }
    return KQPayVoucherFromNone;
    
}

- (NSString * __nullable)orderTrialTotalAmt{
    return PaymentController.payViewDataDetail.trialTotalAmt;
}

- (NSString * __nullable)orderTrialAmt{
    return PaymentController.payViewDataDetail.trialAmt;
}

- (NSString * __nullable)orderTrialRipAmt{
    KQPayVoucherSourceFrom voucherFrom = [self maShangVoucherFrom];
    if (voucherFrom == KQPayVoucherFromMSXF) {
        return PaymentController.payViewDataDetail.trialRipAmt;
    }else if(voucherFrom == KQPayVoucherFromVAS){
        return self.payViewDataPayment.selectedPayVoucher.voucherAmount;
    }else{
        return @"";
    }
}

- (void)confirmPayment:(id<KQPayDetailLoadingTypeDelegate>)loadingTypeDelegate {
    //Add by chenyidong 2017年4月11日  版本3.1.5
    [KQCStatisticsManager logEvent:KQ_TONGYIZHIFU_QUERENFUKUAN
                        attributes:@{@"fukuanfangshi":KQC_NON_NIL([self selectedPayModeDesc]),
                                     @"fenqifangshi":KQC_NON_NIL([self selectedInstalment])}];
    
    //当orderType为空时是一级收银台调用，这个埋点为一级收银台专用
    //线上聚合支付二级收银台埋点
    if (![NSString kqc_isBlank:self.payOrderData.orderType]) {
        NSMutableDictionary *attributesDict = [NSMutableDictionary dictionaryWithDictionary:@{ @"orderScene":KQC_NON_NIL(self.payOrderData.orderType),       //交易场景
                                        @"tradeType":@"支付",                                          //交易类型（只处理支付）
                                        @"channelType":@"InAPP",                                      //支付方式（InAPP）
                                        @"tradeNo":KQC_NON_NIL(self.payOrderData.outTradeNo),         //交易流水号
                                        @"orderNo":KQC_NON_NIL(self.payOrderData.billOrderNo),        //订单号
                                        @"payMode":KQC_NON_NIL([self selectedPayMethod].payType),    //支付方式（传支付方式ID）
                                        @"payAmount":KQC_NON_NIL([KQCAmount getDecimalAmount:self.payViewDataPayment.payAmount amountUnit:KQCAmountUnitTypeFen])}]; //支付金额
        
        if ([[self selectedPayMethod].payType isEqualToString:@"1"] || [[self selectedPayMethod].payType isEqualToString:@"5"]) {
            [attributesDict setObject:KQC_NON_NIL([self selectedPayMethod].bankId) forKey:@"bankName"]; //发卡行（可以不传）
        }
        [KQCStatisticsManager logEvent:@"KQ_zhifu"
                            attributes:attributesDict];
    }
    
    self.loadingTypeDelegate = loadingTypeDelegate;
    if ([self payConditionCheck]) {
        [self payRiskCheck];
    }
}

- (void)trialAmt:(void(^__nullable)(void))finish{
    //马上支付方式 查询分期金额
    if([KQPayMethodPayTypeMaShang isEqualToString:self.payViewDataPayment.selectedPayType]){
        [KQPayDataInterface queryTrialAmt:^(BOOL result, NSString * _Nullable error, NSString * _Nullable _NullableoutputErrorCode, KQPayShowResultWay showResult, KQPayShowAlertContent alertContent) {
            if (result) {
                if (finish) {
                    finish();
                }
            }
            else {
                [KQBToastView show:error];
            }
        }];
    }else{
        finish();
    }
}

-(void)needRequestInstalmentInfo:(void (^)(void))resultBlock{
    // 支付方式变化，若支持分期，调用试算接口
    KQPayMethod * selectedPayMethod = [self selectedPayMethod];

    // 非商城订单，并且支付方式不支持分期，返回。
    if (!selectedPayMethod.isStagable && ![self.payViewDataDetail.installmentDic objectForKey:KQPayMethodPayTypeInstallment]&&![self.payViewDataDetail.installmentDic objectForKey:KQPayMethodPayTypeCreditCard]){
        self.payViewDataPayment.selectedInstallment = nil;
        if (resultBlock) {
            resultBlock();
        }
        return;
    }
    
    // 商城分期订单，不调用试算接口，返回
    if ([self.payViewDataDetail.installmentDic objectForKey:KQPayMethodPayTypeInstallment] || [self.payViewDataDetail.installmentDic objectForKey:KQPayMethodPayTypeCreditCard]) {
        if (resultBlock) {
            resultBlock();
        }
        return;
    }
    
    NSString *defaultStageKey = [NSString stringWithFormat:@"%@%@", selectedPayMethod.methodId, PaymentController.payViewDataPayment.selectedPayVoucher.voucherNo?:@""];
    
    
    //    // 支付金额小于100，不支持分期，清空对应分期列表，返回。
    //    CGFloat payAmount =  [PaymentController.payViewDataPayment.payAmount floatValue];
    //    if (payAmount < 10000) {
    //        [self.payViewDataDetail.installmentDic removeObjectForKey:defaultStageKey];
    //
    //        if (resultBlock) {
    //            resultBlock();
    //        }
    //        return;
    //    }
    
    // 本地没有缓存对应分期列表，请求315。
    NSArray *selectedInstallArr = self.payViewDataDetail.installmentDic[defaultStageKey];
    
    if ((selectedInstallArr.count == 0)) {
        //M315
        [KQPayDataInterface calculateStageInfo:^(BOOL result, NSArray * _Nullable stages, NSString *defaultStage) {
            //解析数据，替换默认值
            if (!result) {
                if (resultBlock) {
                    resultBlock();
                }
                return;
            }
            if (stages && stages.count > 0) {
                [self.payViewDataDetail.installmentDic setObject:stages forKey:defaultStageKey];
                // 默认分期
            }
            
            if (![NSString kqc_isBlank:defaultStage]) {
                [self.payViewDataDetail.defaultStageDic setObject:defaultStage forKey:defaultStageKey];
            }
            
            // 设置默认分期
            [self setDefaultStageCount:stages defaultStage:defaultStage];
            
            if (resultBlock) {
                resultBlock();
            }
        } payMethodId:nil];
        return;
    }
    
    // 本地缓存对应分期列表，刷新页面。
    NSArray *stageArr = [self.payViewDataDetail.installmentDic objectForKey:defaultStageKey];
    NSString* defaultStageCount = [self.payViewDataDetail.defaultStageDic objectForKey:defaultStageKey];
    [self setDefaultStageCount:stageArr defaultStage:defaultStageCount];
    
    if (resultBlock) {
        resultBlock();
    }
}

- (void)setDefaultStageCount:(NSArray *)stages defaultStage:(NSString *)defaultStage{
    if (self.backFromView == KQPayViewStepMode) {
        [stages enumerateObjectsUsingBlock:^(KQPayInstalment *instalment, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0 && [NSString kqc_isBlank:defaultStage]) {
                PaymentController.payViewDataPayment.selectedInstallment = instalment;
            }
            
            if (![NSString kqc_isBlank:defaultStage]){
                if ([instalment.stageNumber isEqualToString:defaultStage]) {
                    PaymentController.payViewDataPayment.selectedInstallment = instalment;
                }
            }
        }];
        self.backFromView = KQPayViewStepDetail;
    }
}

#pragma  mark- KQPayViewStepModeDelegate
- (NSUInteger)payMethodCount {
    return self.payViewDataDetail.payModeArray.count;
}

- (NSUInteger)payMethodDisabledCount {
    return self.payViewDataDetail.payModeDisabledArray.count;
}

- (void)maShangCell:(NSUInteger)index resultBlock:(void(^__nullable)(BOOL maShang))resultBlock {
    if (index < self.payViewDataDetail.payModeArray.count) {
        KQPayMethod *payMethodData = [self.payViewDataDetail.payModeArray objectAtIndex:index];
        if (resultBlock) {
            resultBlock([KQPayMethodPayTypeMaShang isEqualToString:self.payViewDataPayment.selectedPayType] && [KQPayMethodPayTypeMaShang isEqualToString:payMethodData.payType]);
        }
    }
}

- (void)payMethodInfo:(NSUInteger)index resultBlock:(void(^__nullable)(NSString * __nullable payType, NSString * __nullable bankId, NSString * __nullable displayName, NSString * __nullable limitInfo, NSString * __nullable icon, BOOL selected, BOOL showIcon, NSString * activityMsg))resultBlock {
    KQPayMethod *payMethodData;
    if (index < self.payViewDataDetail.payModeArray.count) {
        payMethodData = [self.payViewDataDetail.payModeArray objectAtIndex:index];
    } else {
        payMethodData = [self.payViewDataDetail.payModeDisabledArray objectAtIndex:(index - self.payViewDataDetail.payModeArray.count - 1)];
    }
    if (resultBlock) {
        KQPayActivity *payActivity = self.payViewDataDetail.activityDic[payMethodData.payType];
        resultBlock(payMethodData.payType, payMethodData.bankId, payMethodData.displayName, payMethodData.limitInfo, payMethodData.icon, [payMethodData.methodId isEqualToString:self.payViewDataPayment.selectedPayMode], YES,payActivity.message);
    }
}

- (BOOL)payMethodShouldHide:(NSUInteger)index {
    return NO;
}

- (void)selectPayMethod:(NSUInteger)index {
    KQPayMethod *payMethodData = [self.payViewDataDetail.payModeArray objectAtIndex:index];

    if ([payMethodData.payType isEqualToString:KQPayMethodPayTypeInstallment]) {
        //检查快易花是否通过申请
        __weak typeof(&*self) weakSelf = self;
        [self checkFaceAuthorizationStatus:^(KQPayActionResultType resultType) {
            if (resultType == KQPayActionResultTypeSuccess) {
                weakSelf.payViewDataPayment.selectedPayMode = payMethodData.methodId;
                PaymentController.payViewDataPayment.selectedPayType = payMethodData.payType;
                self.backFromView = KQPayViewStepMode;
                [weakSelf popPayView];
            }
        }];
    }
    else {
        self.payViewDataPayment.selectedPayMode = payMethodData.methodId;
        PaymentController.payViewDataPayment.selectedPayType = payMethodData.payType;
        if ([KQPayMethodPayTypeMaShang isEqualToString:self.payViewDataPayment.selectedPayType]) {
            return;
        }
        self.backFromView = KQPayViewStepMode;
        [self popPayView];
    }
}

- (void)addNewCard {
    NSString *cardType;
    if (self.payViewDataDetail.bindCardType == KQPayBindCardTypeCreditCard) {
        cardType = @"1";
    } else if (self.payViewDataDetail.bindCardType == KQPayBindCardTypeDebitCard) {
        cardType = @"2";
    } else if (self.payViewDataDetail.bindCardType == KQPayBindCardTypeAllCard) {
        cardType = @"3";
    } else {
        return;
    }
    
    __weak typeof(&*self) weakSelf = self;
    [self.delegate payOrderData:self.payViewDataDetail.payOrderData bindCard:cardType resultBlock:^(KQPayActionResultType resultType) {
        [KQC_Engine_UI popToViewController:weakSelf.currentVC];
        if (resultType == KQPayActionResultTypeSuccess) {
            [weakSelf startPay];
        }
    }];
}

#pragma  mark- KQPayViewStepInstallmentDelegate
- (NSUInteger)installmentCount {
    return [self instalmentArray].count;
}

- (void)installmentInfo:(NSUInteger)index resultBlock:(void(^__nullable)(NSString * __nullable rate, NSString * __nullable cost, NSString * __nullable total, BOOL selected))resultBlock {
    KQPayInstalment *installmentData = [[self instalmentArray] objectAtIndex:index];
    
    NSString * rate;
    NSString * cost;
    NSString * total;
    
    if ([NSString kqc_isBlank:installmentData.stageInfo]) {
        rate = [NSString stringWithFormat:@"分%@期(费率%.2f%%/月)", installmentData.stageNumber, [installmentData.rate doubleValue]*100];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *repay = [NSString stringWithFormat:@"%0.2f", [installmentData.repay doubleValue]];
        NSString *formatrepay = [formatter stringFromNumber:[NSNumber numberWithDouble:[repay doubleValue]]];
        cost = [NSString stringWithFormat:@"每期应还 %@(含每期手续费%0.2f)", formatrepay, [installmentData.cost doubleValue]];
        total = [NSString stringWithFormat:@"应还总额(元):%0.2f", [installmentData.total doubleValue]];
    } else {
        rate = installmentData.stageInfo;
        cost = installmentData.feeInfo;
        total = installmentData.totalfeeInfo;
    }
    
    if (resultBlock) {
        resultBlock(rate, cost, total, [installmentData isEqual:self.payViewDataPayment.selectedInstallment]);
    }
}
- (void)selectInstallment:(NSUInteger)index {
    KQPayInstalment *installmentData = [[self instalmentArray] objectAtIndex:index];
    self.payViewDataPayment.selectedInstallment = installmentData;
    [PaymentController popPayView];
}

- (KQPayMethod *)maShangPayMethod{
    __block KQPayMethod *payMEthod;
    [self.payViewDataDetail.payModeArray enumerateObjectsUsingBlock:^(KQPayMethod  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([KQPayMethodPayTypeMaShang isEqualToString:obj.payType]) {
            payMEthod = obj;
        }
    }];
    return payMEthod;
}

- (void)selectInstallment:(NSUInteger)index popFlag:(BOOL)popFlag{
    KQPayMethod *payMethod = [self maShangPayMethod];
    NSString *defaultKey;
    //针对马上金服的分期做特殊处理
    if ([KQPayMethodPayTypeMaShang isEqualToString: payMethod.payType] &&
        [KQPayMethodPayTypeMaShang isEqualToString:self.payViewDataPayment.selectedPayType]) {
        //选择第一个优惠券
        defaultKey = [self defaultStageKey:payMethod.methodId];

        //获取分期
        NSArray *installments = self.payViewDataDetail.installmentDic[defaultKey];
        if (installments && [installments count] > 0) {
            KQPayInstalment *installmentData = [installments objectAtIndex:index];
            self.payViewDataPayment.selectedInstallment = installmentData;
            [self.payViewDataDetail.defaultStageDic objectForKey:defaultKey];
            [self.payViewDataDetail.defaultStageDic setObject:installmentData.stageNumber forKey:defaultKey];
            if (popFlag) {
                self.backFromView = KQPayViewStepMode;
                [PaymentController popPayView];
            }
        }else{
            [KQBToastView show:@"无可用的分期方式"];
        }
    }
}

- (NSArray *)instalmentArray {
    KQPayMethod * selectedPayMethod = [self selectedPayMethod];
    if (selectedPayMethod && ([self.payViewDataDetail.installmentDic objectForKey:KQPayMethodPayTypeInstallment] || [self.payViewDataDetail.installmentDic objectForKey:KQPayMethodPayTypeCreditCard])) {
         NSMutableArray *instalmentArr = [PaymentController.payViewDataDetail.installmentDic objectForKey:selectedPayMethod.payType];
        return instalmentArr;
    }
    
    NSString *defaultStageKey = [NSString stringWithFormat:@"%@%@", selectedPayMethod.methodId, PaymentController.payViewDataPayment.selectedPayVoucher.voucherNo?:@""];
    
    NSMutableArray *instalmentArray = [PaymentController.payViewDataDetail.installmentDic objectForKey:defaultStageKey];
    return instalmentArray;
}

#pragma  mark- KQPayViewStepVoucherDelegate
- (NSUInteger)voucherEnableCount {
    NSArray * enableVoucherArray = [self.payViewDataDetail.enableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
    return enableVoucherArray.count;
}

- (NSUInteger)voucherDisableCount {
    NSArray * disableVoucherArray = [self.payViewDataDetail.disableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
    return disableVoucherArray.count;
}

- (void)voucherInfo:(NSUInteger)index resultBlock:(void(^__nullable)(NSString * __nullable voucherInfo, NSString * __nullable name, NSString * __nullable expDate, KQPayVoucherType payVoucherType, BOOL enable, BOOL selected, KQPayVoucherSourceFrom sourceFrom))resultBlock {
    KQPayVoucher *voucher;
    NSArray * enableVoucherArray = [self.payViewDataDetail.enableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
    NSArray * disableVoucherArray = [self.payViewDataDetail.disableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
    if (index < enableVoucherArray.count) {
        voucher = [enableVoucherArray objectAtIndex:index];
        if (resultBlock) {
            resultBlock(voucher.voucherInfo, voucher.name, voucher.expDate,voucher.voucherType, YES, (voucher == self.payViewDataPayment.selectedPayVoucher), voucher.sourceFrom);
        }
    }
    else {
        NSInteger row = index - enableVoucherArray.count;
        voucher = [disableVoucherArray objectAtIndex:row];
        if (resultBlock) {
            resultBlock(voucher.voucherInfo, voucher.name, voucher.expDate,voucher.voucherType, NO, NO, voucher.sourceFrom);
        }
    }
}
- (void)selectVoucher:(NSUInteger)index {
    KQPayVoucher *voucher;
    NSArray * enableVoucherArray = [self.payViewDataDetail.enableVoucherDic objectForKey:self.payViewDataPayment.selectedPayMode];
    if (index < enableVoucherArray.count) {
        voucher = [enableVoucherArray objectAtIndex:index];
        if (self.payViewDataPayment.selectedPayVoucher == voucher) {
            self.payViewDataPayment.selectedPayVoucher = nil;
        } else {
            self.payViewDataPayment.selectedPayVoucher = voucher;
        }
        self.backFromView = KQPayViewStepVoucher;
        [PaymentController popPayView];
    }
    
    [PaymentController.payViewDataDetail.payModeDisabledArray removeAllObjects];
    [PaymentController.payViewDataDetail.payModeArray removeAllObjects];
    
    [PaymentController.payViewDataDetail.payOrderResultData.payMethod enumerateObjectsUsingBlock:^(KQPayMethod * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.available isEqualToString:@"true"]) {
            if (![PaymentController.payViewDataDetail.payModeArray containsObject:obj]) {
                // 支付方式限额或余额 小于订单金额（减过优惠券）,改为不可用支付方式
                CGFloat payAmount = PaymentController.payViewDataPayment.payAmount.floatValue;
                CGFloat remainSum = obj.remainingSum.floatValue;
                
                if (remainSum > payAmount) {
                    [PaymentController.payViewDataDetail.payModeArray addObject:obj];
                } else {
                    if (![PaymentController.payViewDataDetail.payModeDisabledArray containsObject:obj]) {
                        [PaymentController.payViewDataDetail.payModeDisabledArray addObject:obj];
                    }
                }
            }
        } else {
            if (![PaymentController.payViewDataDetail.payModeDisabledArray containsObject:obj]) {
                [PaymentController.payViewDataDetail.payModeDisabledArray addObject:obj];
            }
        }
    }];
}


#pragma  mark- KQPayViewStepAllVoucherDelegate
- (NSUInteger)voucherAllCount {
    return self.payViewDataDetail.payOrderResultData.voucher.count;
}

- (void)allVoucherInfo:(NSUInteger)index resultBlock:(void(^__nullable)(NSString * __nullable voucherInfo, NSString * __nullable name, NSString * __nullable expDate, KQPayVoucherType payVoucherType,BOOL enable, BOOL selected, KQPayVoucherSourceFrom sourceFrom))resultBlock {
    KQPayVoucher *voucher = [self.payViewDataDetail.payOrderResultData.voucher objectAtIndex:index];
    if (resultBlock) {
        resultBlock(voucher.voucherInfo, voucher.name, voucher.expDate,voucher.voucherType, NO, NO, voucher.sourceFrom);
    }
}


#pragma  mark- KQPayViewStepNoneVoucherDelegate
- (void)otherVouchers {
    if (self.payViewDataDetail.payOrderResultData.voucher.count > 0) {
        //有券才可以点
        [self pushPayView:KQPayViewStepAllVoucher delegate:self withParam:nil completion:nil];
    }
}

#pragma  mark- KQPayViewStepPasswordDelegate
- (void)inputPayPassword:(NSString * __nullable)password loadingTypeDelegate:(id<KQPayDetailLoadingTypeDelegate> __nullable)loadingTypeDelegate {
    self.loadingTypeDelegate = loadingTypeDelegate;
    [PaymentController payOrderByPassword:password];
}

- (void)forgetPayPassword {
    [PaymentController findPayPassword];
}

#pragma  mark- KQPayViewStepSmsDelegate
- (void)getPaySms:(void(^__nullable)(void))finish {
    [KQPayDataInterface getPaySms:^(BOOL result, NSString * _Nullable error) {
        if (result) {
            if (finish) {
                finish();
            }
        }
        else {
            [KQBToastView show:error];
        }
    }];
}

- (void)inputSms:(NSString * __nullable)sms loadingTypeDelegate:(id<KQPayDetailLoadingTypeDelegate> __nullable)loadingTypeDelegate {
    self.loadingTypeDelegate = loadingTypeDelegate;
    [PaymentController payOrderBySms:sms];
}

#pragma  mark- KQPayViewStepCvv2Delegate
- (void)inputCvv2:(NSString * __nullable)cvv2 {
    [KQPayDataInterface modifyBankCardCVV2:cvv2 completion:^(BOOL result) {
        //成功后跳转到订单详情页
        if (result) {
            [self.payUIManager popToFirstPayView:nil];
        }
    }];
}

#pragma  mark- KQPayViewStepResultDelegate
- (NSString * __nullable)customDescription {
    if ([PaymentController.delegate respondsToSelector:@selector(customDescription:)]) {
        return [PaymentController.delegate customDescription:self.payViewDataDetail.payOrderData];
    }
    return @"";
}

- (UIView * __nullable)bannerView {
    if ([PaymentController.delegate respondsToSelector:@selector(bannerView:)]) {
        return [PaymentController.delegate bannerView:self.payViewDataDetail.payOrderData];
    }
    return nil;
}

- (void)resultViewDidAppear:(UIView * __nullable)resultView isSuccess:(BOOL)isSuccess {
    if ([PaymentController.delegate respondsToSelector:@selector(payOrderData:resultViewDidAppear:fingerPay:isSuccess:)]) {
        BOOL isOpen = (([self.payViewDataDetail.payOrderResultData.status isEqualToString:@"1"]) || ([self.payViewDataDetail.payOrderResultData.status isEqualToString:@"2"]));
        if (![@"9" isEqualToString:self.unNeedOrderData.fingerStatus] ) {
            [PaymentController.delegate payOrderData:self.payViewDataDetail.payOrderData resultViewDidAppear:resultView fingerPay:isOpen isSuccess:isSuccess];
        }
    }
}

- (void)modifyCardInfo {
    KQPayMethod *payMethod = [PaymentController selectedPayMethod];
    if (payMethod) {
        [self.delegate payOrderData:self.payViewDataDetail.payOrderData modifyBankCard:payMethod.bankCard bankName:payMethod.bankName resultBlock:^(KQPayActionResultType resultType) {
            [KQC_Engine_UI popToViewController:self.currentVC];
            if (resultType == KQPayActionResultTypeSuccess) {
                if (self.payViewDataResult.payResult) {
                    [self closeAllPayView:KQPaySuccessful errorNo:ERROR_CODE_UNKOWN];
                }
                else {
                    [self closeAllPayView:KQPayFailed errorNo:ERROR_CODE_PAY_FAILED];
                }
            }
        }];
    } else {
        [KQBToastView show:@"支付方式信息为空"];
    }
}

- (void)rePay {
    [self startPay];
}

#pragma  mark- function
/*
 绑完卡、实完名回来可以掉这个重新支付
 */
- (void) startPay
{
    @synchronized(PaymentController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.unNeedOrderData) {
                self.payViewDataDetail = [[KQPayViewDataDetail alloc] initWithPayUnNeedOrderData:self.unNeedOrderData];
                self.payViewDataPayment = [[KQPayViewDataPayment alloc] initWithPayViewDataDetail:self.payViewDataDetail];
                self.payViewDataResult = [[KQPayViewDataResult alloc] init];
                self.payViewDataPayment.payMethod = self.unNeedOrderData.payMethod;
                self.payViewDataPayment.payAmount = self.unNeedOrderData.orderAmount;
                self.payViewDataDetail.payOrderResultData = [[KQPayOrderResultData alloc] init];
                self.payViewDataDetail.payOrderResultData.status = self.unNeedOrderData.fingerStatus;
                self.payViewDataDetail.payOrderResultData.billOrderNo = self.unNeedOrderData.outTradeNo;
                self.payViewDataDetail.payOrderData.supportFinger = self.unNeedOrderData.supportFinger;
                self.payViewDataDetail.payOrderData.txnFlag = self.unNeedOrderData.txnFlag;
            } else {
                self.payViewDataDetail = [[KQPayViewDataDetail alloc] initWithPayOrderData:self.payOrderData];
                self.payViewDataPayment = [[KQPayViewDataPayment alloc] initWithPayViewDataDetail:self.payViewDataDetail];
                self.payViewDataResult = [[KQPayViewDataResult alloc] init];
                self.payViewDataDetail.accountDisplayName = [KQB_Manager_UserInfo.userInfo displayAccount];
            }

            [self checkRealName];
        });
    }
}

- (void)checkRealName{
    [self.delegate payOrderData:self.payViewDataDetail.payOrderData realName:^(KQPayActionResultType resultType) {
        if (resultType == KQPayActionResultTypeSuccess) {
            [self checkPayPassword];
        } else {
            [self paymentClose:KQPayCanceled errorNo:ERROR_CODE_USER_CANCEL];
        }
    }];
}

- (void)checkPayPassword{
    [self.delegate payOrderData:self.payViewDataDetail.payOrderData payPassword:^(KQPayActionResultType resultType) {
        if (resultType == KQPayActionResultTypeSuccess) {
            [self queryPayOrderInfo];
        } else {
            [self paymentClose:KQPayCanceled errorNo:ERROR_CODE_USER_CANCEL];
        }
    }];
}

- (void)queryPayOrderInfo{
    if ([self.delegate respondsToSelector:@selector(willQueryPayOrderInfo:)]) {
        [self.delegate willQueryPayOrderInfo:self.payViewDataDetail.payOrderData];
    }
    if ([self.delegate respondsToSelector:@selector(specialPayMethodForOrder:)]) {
        self.payMethodInfo = [self.delegate specialPayMethodForOrder:self.payViewDataDetail.payOrderData];
    }
    if ([self.delegate respondsToSelector:@selector(forAdditionalInformation)]) {
        self.payAdditionalInfo = [self.delegate forAdditionalInformation];
    }
    self.payUIManager = [[KQPayUIManager alloc] initAllView:self.currentVC.view];
    if (!self.payUIManager) {
        return;
    }
    if (self.unNeedOrderData) {
        [self payRiskCheck];
        return;
    }
    [KQPayDataInterface getPayOrderResultData:^(BOOL result, NSString *error, NSString *errorNo) {
        self.oldPayOrderResultData = self.payViewDataDetail.payOrderResultData;
        if ([self.delegate respondsToSelector:@selector(didQueryPayOrderInfo:)]) {
            [self.delegate didQueryPayOrderInfo:self.payViewDataDetail.payOrderData];
        }
        if (result) {
            @synchronized(PaymentController) {
                //Add by chenyidong 2017年4月11日  版本3.1.5
                [KQCStatisticsManager logEvent:KQ_TONGYIZHIFU_FUKUANXIANGQING attributes:@{@"fukuanfangshi":KQC_NON_NIL([self selectedPayModeDesc]),@"fenqifangshi":KQC_NON_NIL([self selectedInstalment])}];
                //马上金服分期信息
                NSString *payMethodId = [self needRequestMaShang];
                if (![NSString kqc_isBlank:payMethodId]) {
                    [KQPayDataInterface calculateStageInfo:^(BOOL result, NSArray * _Nullable stages, NSString * _Nullable defaultStage) {
                        NSArray *vourceAry = PaymentController.payViewDataDetail.enableVoucherDic[payMethodId];
                        KQPayVoucher *voucher = (vourceAry && [vourceAry count] > 0)?vourceAry[0]:nil;
                        NSString *defaultStageKey = [NSString stringWithFormat:@"%@%@", payMethodId, voucher.voucherNo?:@""];
                        
                        if (stages && stages.count > 0) {
                            [self.payViewDataDetail.installmentDic setObject:stages forKey:defaultStageKey];
                            // 默认分期
                        }
                        
                        if (![NSString kqc_isBlank:defaultStage]) {
                            [self.payViewDataDetail.defaultStageDic setObject:defaultStage forKey:defaultStageKey];
                        }
                        
                        //首次为马上金服 设置默认分期
                        KQPayMethod *firstMaShangMethodId = [PaymentController.payViewDataDetail.payModeArray firstObject];
                        if (firstMaShangMethodId && [KQPayMethodPayTypeMaShang isEqualToString:firstMaShangMethodId.payType]) {
                            [stages enumerateObjectsUsingBlock:^(KQPayInstalment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (defaultStage && [defaultStage isEqualToString:obj.stageNumber]) {
                                    self.payViewDataPayment.selectedInstallment = obj;
                                }
                            }];
                        }
                        [self pushPayView:KQPayViewStepDetail delegate:self withParam:nil completion:nil];
                    } payMethodId:payMethodId];
                }else{
                    [self pushPayView:KQPayViewStepDetail delegate:self withParam:nil completion:nil];
                }
            }
        }
        else {
            //获取订单失败，或者订单失效等，无法继续支付，提示错误信息
            __weak typeof(&*self) weakSelf = self;
            [UIAlertView showWithTitle:error
                               message:@""
                     cancelButtonTitle:@"确定"
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                                  [weakSelf closeAllPayView:KQPayFailed errorNo:errorNo];
                              }];
        }
    }];
}

- (NSString*)defaultStageKey:(NSString*)payMethodId{
    NSArray *vourceAry = PaymentController.payViewDataDetail.enableVoucherDic[payMethodId];
    KQPayVoucher *voucher = (vourceAry && [vourceAry count] > 0)?vourceAry[0]:nil;
    return [NSString stringWithFormat:@"%@%@", payMethodId, voucher.voucherNo?:@""];
}

- (NSString*)needRequestMaShang{
    //包含安逸花
    __block NSString *maShangPayId;
    __block BOOL maShangPayTpye;
    [PaymentController.payViewDataDetail.payModeArray enumerateObjectsUsingBlock:^(KQPayMethod *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([KQPayMethodPayTypeMaShang isEqualToString:obj.payType]) {
            maShangPayId = obj.methodId;
            maShangPayTpye = YES;
            *stop = YES;
        }
    }];
    
    //没有安逸花分期 TODO
    NSArray *instalmentAry = PaymentController.payViewDataDetail.installmentDic[[self defaultStageKey:maShangPayId]];
    __block BOOL instalmentFlag = instalmentAry && [instalmentAry count] > 0;
    
    //有安逸花 且 安逸花的分期为空
    return (maShangPayTpye && !instalmentFlag)?maShangPayId:@"";
}

/*
 支付前各种条件检查
 */
- (BOOL)payConditionCheck {
    if ([NSString kqc_isBlank:self.payViewDataPayment.selectedPayMode]) {
        [KQBToastView show:@"请选择支付方式"];
        return NO;
    }
    else {
        //即使不为空，也要查找一下能否找到对应的
        BOOL hasFound = NO;
        for (KQPayMethod *data in self.payViewDataDetail.payOrderResultData.payMethod) {
            if ([data.methodId isEqualToString:self.payViewDataPayment.selectedPayMode]) {
                hasFound = YES;
            }
        }
        if (!hasFound) {
            [KQBToastView show:@"请选择支付方式"];
            return NO;
        }
    }
    
    for (KQPayMethod *data in self.payViewDataDetail.payOrderResultData.payMethod) {
        if ([data.methodId isEqualToString:self.payViewDataPayment.selectedPayMode]) {
            if ([data.payType isEqualToString:KQPayMethodPayTypeInstallment]) {
                if (!self.payViewDataPayment.selectedInstallment) {
                    [KQBToastView show:@"请选择分期方式"];
                    return NO;
                }
                else {
                    //即使不为空，也要查找一下能否找到对应的
                    BOOL hasFound = NO;
                    for (KQPayInstalment *data in [self instalmentArray]) {
                        if ([data.id isEqualToString:self.payViewDataPayment.selectedInstallment.id]) {
                            hasFound = YES;
                        }
                    }
                    if (!hasFound) {
                        [KQBToastView show:@"请选择分期方式"];
                        return NO;
                    }
                }
            }
            //判断余额是否充足，只有以下几种情况才有意义，其他的暂不考虑
            if (![NSString kqc_isBlank:data.remainingSum]) {
                if ([data.remainingSum doubleValue] < [self.payViewDataPayment.payAmount doubleValue]) {
                    if ([data.payType isEqualToString:KQPayMethodPayTypeAccount]) {
                        [KQBToastView show:@"支付账户余额不足"];
                    } else if ([data.payType isEqualToString:KQPayMethodPayTypeFinancial]) {
                        [KQBToastView show:@"飞凡宝余额不足"];
                    } else if ([data.payType isEqualToString:KQPayMethodPayTypeInstallment]) {
                        [KQBToastView show:@"快易花可用额度不足"];
                    } else if ([data.payType isEqualToString:@"1"]||[data.payType isEqualToString:@"5"]) {
                        [KQBToastView show:@"银行卡可用额度不足"];
                    } else if ([data.payType isEqualToString:KQPayMethodPayTypeMedical]) {
                        [KQBToastView show:@"信用诊疗可用额度不足"];
                    } else {
                        [KQBToastView show:@"余额不足"];
                    }
                    return NO;
                }
            }
        }
    }
    return YES;
}

/*
 风控检查
 */
- (void)payRiskCheck {
    __weak typeof(&*self) weakSelf = self;
    if (self.unNeedOrderData) {
        [KQPayDataInterface payUnNeedOrderRiskCheck:^(KQPayRiskShowResult result, NSString * __nullable validateElement, NSString * _Nullable error) {
            [weakSelf M271Process:result validateElement:validateElement error:error];
        }];
        return;
    }
    
    [KQPayDataInterface payRiskCheck:^(KQPayRiskShowResult result, NSString * __nullable validateElement, NSString * _Nullable error) {
        [weakSelf M271Process:result validateElement:validateElement error:error];
    }];
}

- (void)M271Process:(KQPayRiskShowResult)result validateElement:(NSString * __nullable)validateElement error:(NSString* _Nullable)error {
    __weak typeof(&*self) weakSelf = self;
    [self.payViewDataPayment resetParam];
    if (result == KQPayRiskShowResultNone) {
        self.payViewDataDetail.payOrderData.isUnFreeze = false;
        self.payViewDataDetail.payOrderData.freezeState = KQPayAccountUnFreeze;
        if ([self.payViewDataDetail.payOrderResultData.status isEqualToString:@"1"]) {
            //验指纹
            if ([NSString kqc_isBlank:self.payViewDataDetail.payOrderData.txnFlag]) {
                //指纹校验码为空怎么办=>应该不存在这种情况，为1表示开通，并且指纹校验值相同
            } else {
//                [weakSelf checkTouchID];
            }
        } else if ([self.payViewDataDetail.payOrderResultData.status isEqualToString:@"2"]) {
            //这里不需要再判断系统版本是否满足iOS>=9.0，前面M251中的supportFinger字段已指示是否满足iOS>=9.0
            //开通了指纹支付，但指纹校验码不同
            if ([NSString kqc_isBlank:self.payViewDataDetail.payOrderData.txnFlag]) {
                //密码界面要提示“指纹支付已经失效”，并且还要关闭指纹支付
//                [weakSelf closeTouchIDPay];
                [weakSelf gotoPasswordNavigateView:BiometryPaymentInvalidInfo];
            } else {
                //密码界面要提示“指纹支付更新”
                [weakSelf gotoPasswordNavigateView:BiometryPaymentChangedInfo];
            }
        }
        else {
            //指纹支付未开通，正常输入密码
            [weakSelf gotoPasswordNavigateView:nil];
        }
    }
    else if (result == KQPayRiskShowResultSms) {
        if ([self.payViewDataDetail.payOrderResultData.status isEqualToString:@"1"]) {
            if ([validateElement isEqualToString:KQPAYMENT_PASSWORD_FINGER_SMS]) {
                self.payViewDataPayment.payNeedSms = YES;
//                [weakSelf checkTouchID];
            } else if ([KQPAYMENT_PASSWORD containsObject:validateElement]) {
                [weakSelf gotoPasswordNavigateView:nil];
            } else if ([validateElement isEqualToString:KQPAYMENT_PASSWORD_SMS]) {
                self.payViewDataPayment.payNeedSms = YES;
                [weakSelf gotoPasswordNavigateView:nil];
            } else {
                [weakSelf tipChangePayMethod:error];
            }
        } else {
            if ([validateElement isEqualToString:KQPAYMENT_PASSWORD_SMS]||[validateElement isEqualToString:KQPAYMENT_PASSWORD_FINGER_SMS]) {
                self.payViewDataPayment.payNeedSms = YES;
                [weakSelf gotoPasswordNavigateView:nil];
            } else {
                [weakSelf tipChangePayMethod:error];
            }
        }
    }
    else if (result == KQPayRiskShowResultAlert) {
        [weakSelf tipChangePayMethod:error];
    }
    else if (result == KQPayRiskShowResultFreezeUnbreak) {
        self.payViewDataDetail.payOrderData.freezeState = KQPayAccountFreezeUnLock;
        [weakSelf accountFreezeAlert];
    }
    else if (result == KQPayRiskShowResultFreeze) {
        self.payViewDataDetail.payOrderData.isUnFreeze = true;
        self.payViewDataDetail.payOrderData.freezeState = KQPayAccountFreezeLock;
        NSString *stageInfo = self.payViewDataPayment.selectedInstallment.stageNumber;
        for (KQPayMethod *data in self.payViewDataDetail.payOrderResultData.payMethod) {
            if ([data.methodId isEqualToString:self.payViewDataPayment.selectedPayMode]) {
                if ([KQPayMethodPayTypeMaShang isEqualToString:data.payType] && ![NSString kqc_isBlank:stageInfo]) {
                }else{
                    void (^unFreezeBlock)(BOOL unFreezeSuccess) = ^void(BOOL unFreezeSuccess) {
                        [KQC_Engine_UI popViewControllerWithAnimated:NO];
                        if (unFreezeSuccess) {
                            //解冻成功,开始支付
                            self.payViewDataDetail.payOrderData.isUnFreeze = false;
                            self.payViewDataDetail.payOrderData.freezeState = KQPayAccountUnFreeze;
                            [self M271Process:KQPayRiskShowResultNone validateElement:nil error:nil];
                        }else{
                            //解冻失败,换卡支付
                            [self pushPayView:KQPayViewStepMode delegate:self withParam:nil completion:nil];
                        }
                    };
                    NSDictionary *paramDic = @{@"memberBankAcctID":data.memberBankAcctId,@"cardType":data.payType,@"unFreezeBlock":unFreezeBlock};
                    [KQC_Engine_UI showViewControllerWithName:@"KQPaymentUnfreezeCodeFillVC" param:paramDic];
                }
            }
        }
    }
    else {
        [KQBToastView show:error];
        if (self.unNeedOrderData) {
            [self closeAllPayView:KQPayCanceled errorNo:ERROR_CODE_PAY_RISK_FAILED];
        }
    }
}

///*
// 校验指纹
// */
//- (void)checkTouchID {
//    __weak typeof(&*self) weakSelf = self;
//    NSDictionary *requestDic = @{@"businessType":@"2"};
//    [KQHttpService request:requestDic bizType:@"M298" successBlock:^(Content *response) {
//        NSString *uafRequest = [KQFidoSDKDataModel checkServerResponseFormat:response.extData1];
//        if (![NSString kqc_isBlank:uafRequest]) {
//            NSString *fidoResponse;
//            KQFidoSDKResponse fidoSDKResponse = [KQFidoSDKDataModel callFidoSDK:uafRequest response:&fidoResponse];
//            if (fidoSDKResponse == KQFidoSDKResponseSuccess) {
//                NSDictionary *requestDic = @{@"txnFlag":[KQPayOrderDataProcess stringNilIfTxnFlagIsEmpty:self.payViewDataDetail.payOrderData.txnFlag],
//                                             @"extData1":fidoResponse,
//                                             @"billOrderNo":self.payViewDataDetail.payOrderResultData.billOrderNo};
//                [KQHttpService request:requestDic bizType:@"M302" successBlock:^(Content *response) {
//                    self.payViewDataPayment.token = response.token;
//                    if (self.payViewDataPayment.payNeedSms) {
//                        //需要验证短信
//                        [self pushPayView:KQPayViewStepSms delegate:self withParam:nil completion:nil];
//                    } else {
//                        //支付
//                        [self payOrder];
//                    }
//                } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
//                    //后面的验证错误需要提示用户，并跳输入密码界面
//                    [KQBToastView show:errorMessage];
//                    [weakSelf gotoPasswordNavigateView:nil];
//                } showWaitMode:KQHttpServiceWaitingViewModeShow];
//            } else if (fidoSDKResponse == KQFidoSDKResponseFailure) {
//                [KQBToastView show:BiometryPaymentFailedInfo];
//                [weakSelf gotoPasswordNavigateView:nil];
//            } else if (fidoSDKResponse == KQFidoSDKResponseCanceled) {
//                [weakSelf gotoPasswordNavigateView:nil];
//            } else if (fidoSDKResponse == KQFidoSDKResponseNoMatch) {
//                //关闭指纹支付，同时跳密码输入界面
//                [weakSelf closeTouchIDPay];
//                [weakSelf gotoPasswordNavigateView:BiometryPaymentInvalidInfo];
//            } else {
//                [KQBToastView show:@"响应错误"];
//                [weakSelf gotoPasswordNavigateView:nil];
//            }
//        } else {
//            //前面的错误不需要提示用户，直接跳输入密码界面
//            [weakSelf gotoPasswordNavigateView:nil];
//        }
//    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
//        //前面的错误不需要提示用户，直接跳输入密码界面
//        [weakSelf gotoPasswordNavigateView:nil];
//    } showWaitMode:KQHttpServiceWaitingViewModeShow];
//}
//
//- (void)installmentInfos:(NSString *)installmentType resultBlock:(void(^__nullable)(NSArray * __nullable installments, NSString * __nullable defaultInstallment, BOOL selectedMaShang))resultBlock{
//    __block NSString *payMethodId;
//    [self.payViewDataDetail.payModeArray enumerateObjectsUsingBlock:^(KQPayMethod *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj.payType isEqualToString:installmentType]) {
//            payMethodId = obj.methodId;
//        }
//    }];
//    NSArray *installmentAry = PaymentController.payViewDataDetail.installmentDic[[self defaultStageKey:payMethodId]];
//    if(resultBlock){
//        NSString *defaultStage = self.payViewDataDetail.defaultStageDic[[self defaultStageKey:payMethodId]];
//        resultBlock(installmentAry,
//                    defaultStage,
//                    [KQPayMethodPayTypeMaShang isEqualToString:self.payViewDataPayment.selectedPayType]);
//    }
//}
//
//- (void)closeTouchIDPay {
//    NSDictionary *requestDic = @{};
//    [KQHttpService request:requestDic bizType:@"M301" successBlock:^(Content *response) {
//        NSString *uafRequest = [KQFidoSDKDataModel checkServerResponseFormat:response.extData1];
//        if (![NSString kqc_isBlank:uafRequest]) {
//            NSString *fidoResponse;
//            KQFidoSDKResponse fidoSDKResponse = [KQFidoSDKDataModel callFidoSDK:uafRequest response:&fidoResponse];
//            if (fidoSDKResponse == KQFidoSDKResponseSuccess) {
//                KQB_Manager_UserInfo.userInfo.touchIdPayStatus = @"NO";
//            }
//        }
//    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
//        //静默执行，不进行提示
//    } showWaitMode:KQHttpServiceWaitingViewModeShow];
//}

- (void)tipChangePayMethod:(NSString * __nullable)errorMsg {
    [UIAlertView showWithTitle:KQC_NON_NIL(errorMsg)
                       message:@""
             cancelButtonTitle:@"取消"
             otherButtonTitles:@[@"更换支付方式"]
                      tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                          if (buttonIndex == 1) {
                              //这里不考虑PaymentController.lockPayMethod，买万能险是理财场景，暂不考虑
                              [self pushPayView:KQPayViewStepMode delegate:self withParam:nil completion:nil];
                          }
                      }];
}

- (void)accountFreezeAlert{
    [UIAlertView showWithTitle:@"账户异常"
                       message:@"您近期交易频次低，为保障账户安全已为您冻结，请联系客服进行解冻"
             cancelButtonTitle:@"知道了"
             otherButtonTitles:@[@"联系客服"]
                      tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                          if (buttonIndex == 1) {
                              NSString *telString = DescriptionManager.BC050T000014;
                              NSString *dialUrl = KQC_FORMAT(@"tel:%@", telString);
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dialUrl]];
                          }
                      }];
}

- (void)gotoPasswordNavigateView:(NSString * __nullable)touchIdInfo
{
    NSDictionary *param = nil;
    if (![NSString kqc_isBlank:touchIdInfo]) {
        param = @{@"touchIdInfo":touchIdInfo};
    }
    [self pushPayView:KQPayViewStepPassword delegate:self withParam:param completion:nil];
}

- (void)payOrderByPassword:(NSString * __nonnull)password {
    self.payViewDataPayment.payPassword = password;
    if (self.payViewDataPayment.payNeedSms) {
        //需要短信验证
        [PaymentController verifyPayPassword];
    }
    else {
        [PaymentController payOrder];
    }
}

- (void)payOrderBySms:(NSString * __nonnull)sms {
    self.payViewDataPayment.paySms = sms;
    [PaymentController payOrder];
}

- (void)payOrder {
    if (self.loadingTypeDelegate&&[self.loadingTypeDelegate respondsToSelector:@selector(payDetailLoadingType:)]) {
        [self.loadingTypeDelegate payDetailLoadingType:KQPayDetailLoadingTypeStart];
    }
    __weak typeof(self) weakSelf = self;
    if (self.unNeedOrderData) {
        [KQPayDataInterface payUnNeedOrderPay:^(BOOL result, NSString *error, NSString *outputErrorCode, KQPayShowResultWay showResult, KQPayShowAlertContent alertContent) {
            if (self.loadingTypeDelegate&&[self.loadingTypeDelegate respondsToSelector:@selector(payDetailLoadingType:)]) {
                [self.loadingTypeDelegate payDetailLoadingType:KQPayDetailLoadingTypeClose];
            }
            if (result) {
                [weakSelf showResultView:YES ShowResultWay:showResult];
            }
            else {
                //支付失败
                [weakSelf payPasswordError:error outputErrorCode:outputErrorCode ShowResultWay:showResult ShowAlertContent:alertContent];
            }
        } showWait:!self.loadingTypeDelegate];
        return;
    }
    [KQPayDataInterface payOrder:^(BOOL result, NSString *error, NSString *outputErrorCode, KQPayShowResultWay showResult, KQPayShowAlertContent alertContent) {
        if (self.loadingTypeDelegate&&[self.loadingTypeDelegate respondsToSelector:@selector(payDetailLoadingType:)]) {
            [self.loadingTypeDelegate payDetailLoadingType:KQPayDetailLoadingTypeClose];
        }
        if (result) {
            [weakSelf showResultView:YES ShowResultWay:showResult];
        }
        else {
            //支付失败
            [weakSelf payPasswordError:error outputErrorCode:outputErrorCode ShowResultWay:showResult ShowAlertContent:alertContent];
        }
    } showWait:!self.loadingTypeDelegate];
}

- (void)verifyPayPassword {
    __weak typeof(self) weakSelf = self;
    [KQPayDataInterface verifyPayPassword:^(BOOL result, NSString * _Nullable error, NSString *outputErrorCode, KQPayShowResultWay showResult, KQPayShowAlertContent alertContent) {
        if (result) {
            [self pushPayView:KQPayViewStepSms delegate:self withParam:nil completion:nil];
        }
        else {
            //支付密码验证失败
            [weakSelf payPasswordError:error outputErrorCode:outputErrorCode ShowResultWay:showResult ShowAlertContent:alertContent];
        }
    }];
}

- (void)payPasswordError:(NSString*)error outputErrorCode:(NSString *)code ShowResultWay:(KQPayShowResultWay)showResult ShowAlertContent:(KQPayShowAlertContent)alertContent {
    if (showResult == KQPayShowResultWayAlert) {
        NSString *leftTip = @"";
        NSString *rightTip = @"";
        if (alertContent == KQPayShowAlertContentOkFindpwd) {
            leftTip = @"确定";
            rightTip = @"找回密码";
        }
        else if (alertContent == KQPayShowAlertContentOkOnly) {
            leftTip = @"确定";
            rightTip = nil;
        }
        else if (alertContent == KQPayShowAlertContentReinputForgetpwd) {
            leftTip = @"重新输入";
            rightTip = @"忘记密码";
        }
        if (![NSString kqc_isBlank:leftTip]||![NSString kqc_isBlank:rightTip]) {
            UIAlertView *alertView = [UIAlertView showWithTitle:error
                                                        message:@""
                                              cancelButtonTitle:leftTip
                                              otherButtonTitles:rightTip?@[rightTip]:nil
                                                       tapBlock:nil];
            //解决进入找回密码UI时，键盘会闪一下，在didDismissBlock中跳转找回密码UI
            alertView.didDismissBlock = ^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    if ((alertContent == KQPayShowAlertContentOkFindpwd)||(alertContent == KQPayShowAlertContentReinputForgetpwd)) {
                        [PaymentController findPayPassword];
                    }
                }
                else {
                    if (alertContent == KQPayShowAlertContentReinputForgetpwd) {
                        [self.payUIManager stayHere];
                    }
                    else {
                        //选确定，直接退出支付
                        [self closeAllPayView:KQPayCanceled errorNo:ERROR_CODE_USER_CANCEL];
                    }
                }
            };
        }
    } else if (showResult == KQPayShowResultWayFailedView) {
        [self showResultView:NO ShowResultWay:showResult];
    } else if (showResult == KQPayShowResultWayTips) {
        [KQBToastView show:error];
        [self.payUIManager stayHere];
    } else if (showResult == KQPayShowResultWayBankCardPhoneNoError) {
        [KQErrorAlertView showWithTitle:error message:code butttonImage:nil cancelButtonTitle:@"更换支付方式" otherButtonTitles:@[@"放弃付款"] tapBlock:^(KQErrorAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self.payUIManager popToFirstPayView:^{
                    [self pushPayView:KQPayViewStepMode delegate:self withParam:nil completion:nil];
                }];
            }
            else {
                [self showResultView:NO ShowResultWay:showResult];
            }
        }];

    } else if (showResult == KQPayShowResultWayBankCardCVV2Error) {
        
        [KQErrorAlertView showWithTitle:error message:code butttonImage:nil cancelButtonTitle:@"修改卡信息" otherButtonTitles:@[@"更换支付方式"] tapBlock:^(KQErrorAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            [self.payUIManager popToFirstPayView:^{
                if (buttonIndex == 1) {
                    [self pushPayView:KQPayViewStepCvv2 delegate:self withParam:nil completion:nil];
                } else {
                    [self pushPayView:KQPayViewStepMode delegate:self withParam:nil completion:nil];
                }
            }];
            
        }];

    } else if (showResult == KQPayShowResultSwitchPayMothedError) {
        
        [KQErrorAlertView showWithTitle:error message:code butttonImage:nil cancelButtonTitle:@"更换支付方式" otherButtonTitles:@[@"放弃付款"] tapBlock:^(KQErrorAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self.payUIManager popToFirstPayView:^{
                    [self pushPayView:KQPayViewStepMode delegate:self withParam:nil completion:nil];
                }];
            } else {
                [self showResultView:NO ShowResultWay:showResult];
            }
        }];
    } else if (showResult == KQPayShowResultUnionPayInvalidError) {
        __weak typeof(self) weakSelf = self;
        [KQErrorAlertView showWithTitle:error message:code butttonImage:[UIImage imageNamed:@"help"] cancelButtonTitle:@"更换支付方式" otherButtonTitles:@[@"放弃付款"] tapBlock:^(KQErrorAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            
            if (buttonIndex == 1) {
                [self.payUIManager popToFirstPayView:^{
                    [self pushPayView:KQPayViewStepMode delegate:self withParam:nil completion:nil];
                }];
            } else if (buttonIndex == 0) {
                [self showResultView:NO ShowResultWay:showResult];
            } else if (buttonIndex == -1) {
                KQPayHelpBackHandler handler = ^() {
                    [alertView show];
                    weakSelf.currentVC.isBackFromHelp = YES;
                };
                
                NSString *targetURL = @"";
                if ([KQCApplication environmentType] == KQCAppEnvironmentTypePro) {
                    targetURL = @"https://oms-cloud.99bill.com/prod/html/app-base/market/union-online-pay/index.htm";
                } else {
                    targetURL = @"https://oms-cloud.99bill.com/stage2/html/app-base/market/union-online-pay/index.html";
                }
            
                NSDictionary *param = @{@"handler":handler,
                                        @"targetUrl":targetURL,
                                        @"screenTitle":@"帮助"};
                [KQC_Engine_UI showViewControllerWithName:@"KQPayHelpWebVC" param:param];
            }
        }];
    } else if (showResult == KQPayShowResultUnbindCardError){
         __weak typeof(self) weakSelf = self;
        [KQErrorAlertView showWithTitle:error message:code butttonImage:nil cancelButtonTitle:@"解绑银行卡" otherButtonTitles:@[@"更换支付方式"] tapBlock:^(KQErrorAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                [weakSelf.payUIManager popToFirstPayView:^{
                    if (buttonIndex == 1) {
                        NSDictionary *param = @{@"handler":^{
                            [weakSelf startPay];
                        }};
                        [KQC_Engine_UI showViewControllerWithName:@"KQTiedCardViewController" param:param];
                    } else {
                        [weakSelf pushPayView:KQPayViewStepMode delegate:self withParam:nil completion:nil];
                    }
                }];

        }];
    } else {
        [KQBToastView show:@"未知错误"];
        [self.payUIManager stayHere];
    }
}

// TODO 改为轮询后，支付完成页跳H5
//- (void)showResultView:(BOOL)bResult ShowResultWay:(KQPayShowResultWay)showResult
//{
//    if (self.loadingTypeDelegate&&[self.loadingTypeDelegate respondsToSelector:@selector(payDetailLoadingType:)]) {
//        [self.loadingTypeDelegate payDetailLoadingType:bResult?KQPayDetailLoadingTypeSuccess:KQPayDetailLoadingTypeFailed];
//    }
//    //给2秒的展示时间
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.loadingTypeDelegate?(int64_t)(2 * NSEC_PER_SEC):0), dispatch_get_main_queue(), ^{
//        if (self.loadingTypeDelegate&&[self.loadingTypeDelegate respondsToSelector:@selector(payDetailLoadingType:)]) {
//            [self.loadingTypeDelegate payDetailLoadingType:KQPayDetailLoadingTypeClose];
//        }
//        self.payViewDataResult.payResult = bResult;
//
//        if (self.payOrderData.isShowDefaultResPage && self.payViewDataResult.payResult) {
//            NSString *jsonString = @"";
//            if (self.resultDic && self.resultDic.count > 0) {
//                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.resultDic options:NSJSONWritingPrettyPrinted error:nil];
//                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//            }
//
//            NSString *url = KQC_FORMAT(@"%@?msg=%@", PAY_RESULT_URL,jsonString);
//
//            [self pushPayView:KQPayViewStepResult delegate:self withParam:@{@"payResultUrl":[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]} completion:nil];
//
//        } else {
//            if (self.payViewDataResult.payResult) {
//                [self closeAllPayView:KQPaySuccessful errorNo:ERROR_CODE_UNKOWN];
//            } else {
//                [self closeAllPayView:KQPayFailed errorNo:ERROR_CODE_PAY_FAILED];
//            }
//        }
//
//    });
//}

// TODO 比较上面的方法
- (void)showResultView:(BOOL)bResult ShowResultWay:(KQPayShowResultWay)showResult
{
    if (self.loadingTypeDelegate&&[self.loadingTypeDelegate respondsToSelector:@selector(payDetailLoadingType:)]) {
        [self.loadingTypeDelegate payDetailLoadingType:bResult?KQPayDetailLoadingTypeSuccess:KQPayDetailLoadingTypeFailed];
    }
    //给2秒的展示时间
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.loadingTypeDelegate?(int64_t)(2 * NSEC_PER_SEC):0), dispatch_get_main_queue(), ^{
        if (self.loadingTypeDelegate&&[self.loadingTypeDelegate respondsToSelector:@selector(payDetailLoadingType:)]) {
            [self.loadingTypeDelegate payDetailLoadingType:KQPayDetailLoadingTypeClose];
        }
        
        //线上聚合支付请求成功埋点
        if (![NSString kqc_isBlank:self.payOrderData.orderType]) {
            NSMutableDictionary *attributesDict = [@{@"orderScene":KQC_NON_NIL(self.payOrderData.orderType),//交易场景
                                                     @"tradeType":@"支付",             //交易类型（只处理支付）
                                                     @"channelType":@"InAPP",         //支付方式（InAPP）
                                                     @"tradeNo":KQC_NON_NIL(self.payOrderData.outTradeNo), //交易流水号
                                                     @"orderNo":KQC_NON_NIL(self.payOrderData.billOrderNo),//订单号
                                                     @"payMode":KQC_NON_NIL([self selectedPayMethod].payType),    //支付方式（传支付方式ID）
                                                     @"payAmount":KQC_NON_NIL([KQCAmount getDecimalAmount:self.payViewDataPayment.payAmount amountUnit:KQCAmountUnitTypeFen]),//支付金额
                                                     @"resultCode":bResult?@"success":@"fail"} mutableCopy];//支付结果（确认支付埋点不需要传）
            
            if ([[self selectedPayMethod].payType isEqualToString:@"1"] || [[self selectedPayMethod].payType isEqualToString:@"5"]) {
                [attributesDict setObject:KQC_NON_NIL([self selectedPayMethod].bankId) forKey:@"bankName"]; //发卡行（可以不传）
            }
            if (!bResult) {
                [attributesDict setObject:KQC_NON_NIL(self.payViewDataResult.paymentResultData.errorInfo) forKey:@"errorInfo"];  //错误信息（支付错误时的错误信息）
            }
            
            [KQCStatisticsManager logEvent:@"KQ_zhifujieguotongzhi"
                                attributes:attributesDict];
        }
        
        if (bResult && !self.payOrderData.isShowDefaultResPage) {
            //支付成功的情况下，只有几只情况才显示结果页面
            if ([self.delegate respondsToSelector:@selector(shouldShowPaySuccessView:)]) {
                if (![self.delegate shouldShowPaySuccessView:self.payViewDataDetail.payOrderData]) {
                    [self closeAllPayView:KQPaySuccessful errorNo:ERROR_CODE_UNKOWN];
                    return;
                }
            }
        }
        self.payViewDataResult.payResult = bResult;
        KQPayResultInfo *resultInfo = [[KQPayResultInfo alloc] init];
        KQPayMethod *payMethod = nil;
        if (self.unNeedOrderData) {
            payMethod = self.unNeedOrderData.payMethod;
        }else{
            for (KQPayMethod *data in self.payViewDataDetail.payOrderResultData.payMethod) {
                if ([data.methodId isEqualToString:self.payViewDataPayment.selectedPayMode]) {
                    payMethod = data;
                }
            }
        }
        resultInfo.payMethod = payMethod.displayName;
        resultInfo.payAmount = self.payViewDataResult.paymentResultData.payAmount;
        resultInfo.orderAmount = self.payViewDataResult.paymentResultData.orderAmount;
        resultInfo.payVoucherData = self.payViewDataResult.paymentResultData.equityAmount;
        
        if ([NSString kqc_isBlank:self.payViewDataResult.paymentResultData.txnEndTime]) {
            resultInfo.txnTimeStart = @"";
        } else {
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
            NSDate *date = [dateFormat dateFromString:self.payViewDataResult.paymentResultData.txnEndTime];
            [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            resultInfo.txnTimeStart = [dateFormat stringFromDate:date];
        }
        
        resultInfo.result = bResult;
        if (!bResult) {
            //银行卡电话号码错误时，错误按钮是"修改卡信息"
            if (showResult == KQPayShowResultWayBankCardPhoneNoError) {
                resultInfo.errorBtnType = KQPayResultErrorBtnTypeModifyPayCard;
            } else {
                resultInfo.errorBtnType = KQPayResultErrorBtnTypeNormal;
            }
        }
        
        resultInfo.errorInfo = self.payViewDataResult.paymentResultData.errorInfo;
        
        //线上聚合支付结果页埋点
        if (![NSString kqc_isBlank:self.payOrderData.orderType]) {
            NSMutableDictionary *attributesDict = [@{@"orderScene":KQC_NON_NIL(self.payOrderData.orderType),//交易场景
                                                     @"tradeType":@"支付",             //交易类型（只处理支付）
                                                     @"channelType":@"InAPP",         //支付方式（InAPP）
                                                     @"tradeNo":KQC_NON_NIL(self.payOrderData.outTradeNo), //交易流水号
                                                     @"orderNo":KQC_NON_NIL(self.payOrderData.billOrderNo),//订单号
                                                     @"payMode":KQC_NON_NIL(payMethod.payType),    //支付方式（传支付方式ID）
                                                     @"payAmount":KQC_NON_NIL([KQCAmount getDecimalAmount:self.payViewDataPayment.payAmount amountUnit:KQCAmountUnitTypeFen]),//支付金额
                                                     @"resultCode":bResult?@"success":@"fail"} mutableCopy];//支付结果（确认支付埋点不需要传）
            
            if ([[self selectedPayMethod].payType isEqualToString:@"1"] || [[self selectedPayMethod].payType isEqualToString:@"5"]) {
                [attributesDict setObject:KQC_NON_NIL(payMethod.bankId) forKey:@"bankName"]; //发卡行（可以不传）
            }
            if (!bResult) {
                [attributesDict setObject:KQC_NON_NIL(resultInfo.errorInfo) forKey:@"errorInfo"];  //错误信息（支付错误时的错误信息）
            }
            
            [KQCStatisticsManager logEvent:@"KQ_zhifujieguoxianshi"
                                attributes:attributesDict];
        }
        
        [self pushPayView:KQPayViewStepResult delegate:self withParam:@{@"payResultInfo":resultInfo} completion:nil];
    });
}

- (void)pushPayView:(KQPayViewStep)payViewStep delegate:(id __nonnull)delegate withParam:(NSDictionary* __nullable)paramDic completion:(void (^ __nullable)(BOOL finished))completion {
    UIView * payView = nil;
    if (self.viewStepDelegate && [self.viewStepDelegate respondsToSelector:@selector(payViewStepShowWhich:)]) {
        payView = [self.viewStepDelegate payViewStepShowWhich:payViewStep];
    }
    if (payView) {
        [self.payUIManager pushPayViewWithView:payView withParam:paramDic completion:completion];
    } else {
        [self.payUIManager pushPayViewWithStep:payViewStep delegate:delegate withParam:paramDic completion:completion];
    }
}

- (void)popPayView {
    [self.payUIManager popPayView:nil];
}

- (void)closeAllPayView:(KQPayResultType)payResult errorNo:(NSString * __nonnull)errorNo {
    [self.payUIManager popAllPayView:^{
        [self paymentClose:payResult errorNo:errorNo];
    }];
}

- (BOOL)hasActivity {
    return self.payViewDataDetail.activityDic.count > 0;
}

- (void)findPayPassword{
    [self.delegate payOrderData:self.payViewDataDetail.payOrderData findPayPassword:^(KQPayActionResultType resultType) {
        [KQC_Engine_UI popToViewController:self.currentVC];
    }];
}

- (void)checkFaceAuthorizationStatus:(void(^)(KQPayActionResultType resultType))resultBlock{
    if ([self.delegate respondsToSelector:@selector(payOrderData:faceAuthorization:)]) {
        [self.delegate payOrderData:self.payViewDataDetail.payOrderData faceAuthorization:resultBlock];
    }
}

- (void)paymentClose:(KQPayResultType)payResult errorNo:(NSString*)errorNo
{
    if (self.currentVC) {
        //        [[FFAPPKit currentNavigator] popViewControllerAnimated:NO];
        [self.currentVC.navigationController popViewControllerAnimated:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(payResult:errorCode:payMethodDesc:resultDic:)]) {
        [self.delegate payResult:payResult errorCode:errorNo payMethodDesc:[self selectedPayModeDesc] resultDic:self.resultDic];
        
    }
}

- (KQPayMethod * __nullable)selectedPayMethod
{
    for (KQPayMethod *data in self.payViewDataDetail.payOrderResultData.payMethod) {
        if ([data.methodId isEqualToString:self.payViewDataPayment.selectedPayMode]) {
            return data;
        }
    }
    return nil;
}

- (NSString *)selectedPayModeDesc
{
    KQPayMethod *payMethod = [self selectedPayMethod];
    if (payMethod) {
        return payMethod.displayName;
    }
    return @"";
}

//Add by chenyidong 2017年4月11日  版本3.1.5  方便埋点使用，平时不用
- (NSString *)selectedInstalment{
    if (![NSString kqc_isBlank:self.payViewDataPayment.selectedInstallment.stageInfo]) {
        return self.payViewDataPayment.selectedInstallment.stageInfo;
    }
    
    if (self.payViewDataPayment.selectedInstallment) {
        return [NSString stringWithFormat:@"分%@期(费率%.2f%%/月)", self.payViewDataPayment.selectedInstallment.stageNumber, [self.payViewDataPayment.selectedInstallment.rate doubleValue]*100];
    }
    return @"";
}

@end
