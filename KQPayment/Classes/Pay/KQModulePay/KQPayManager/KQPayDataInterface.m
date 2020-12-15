//
//  KQPayDataInterface.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/24.
//
//

#import "KQPayDataInterface.h"
#import "KQPaymentMacro.h"
#import "KQPaymentController.h"
#import "KQPayViewData.h"
#import "KQPayOrderDataProcess.h"

#define KQPAYMENT_SP_PAY_WITH_FINGER                    @"SP_PAY_WITH_FINGER"
#define KQPAYMENT_SP_ONLY_PSW                           @"SP_ONLY_PSW"
#define KQPAYMENT_SP_PAY_WITH_FINGER_AND_SP_SIGN        @"SP_PAY_WITH_FINGER&&SP_SIGN"
#define KQPAYMENT_SP_SIGN                               @"SP_SIGN"

#define SpecialStages @[KQPayMethodPayTypeCreditCard, KQPayMethodPayTypeInstallment]
#define KPullTimesUninitValue ( -1 )

@implementation KQPayDataInterface

+ (void)getPayOrderResultData:(PrepareForPayBlock)payBlock {
    NSString *fingerFlag = @"";
    NSData *fingerData = nil;
    KQCFingerStatus fingerStatus = [KQBFingerManager isSystemFingerPayOn:&fingerData];
    if (fingerData) {
        fingerFlag = [fingerData base64EncodedStringWithOptions:0];
    }
    //系统版本满足，就表示有指纹这种硬件，并且系统是iOS9以上，这里还要加上OMS的指纹支付开关判断
    if (fingerStatus < KQCFingerStatusUnsupportSystemVersion) {
        PaymentController.payViewDataDetail.payOrderData.supportFinger = @"true";
    } else {
        PaymentController.payViewDataDetail.payOrderData.supportFinger = @"false";
    }
    PaymentController.payViewDataDetail.payOrderData.txnFlag = fingerFlag;
    
    NSDictionary *m251Dic = [KQPayOrderDataProcess getM251Dic:PaymentController.payViewDataDetail.payOrderData];
     // M250 -> M359
    [KQHttpService request:m251Dic bizType:@"M359" successBlock:^(Content *response) {
        //Modify by chenyidong at Version3.1.6 移除APP端订单异常状态操作处理，改为mbp自行判断
        PaymentController.payViewDataDetail.payOrderResultData = [KQPayOrderDataProcess getPayOrderResultDataFromObj:response];
        if (PaymentController.payViewDataDetail.payOrderResultData) {
            //回调js接口时需要billOrderNo等参数
            [KQPayOrderDataProcess fillPayOrderDataByPayOrderResultData:PaymentController.payViewDataDetail.payOrderData payOrderResultData:PaymentController.payViewDataDetail.payOrderResultData];
            //现在肯定知道需付款，后面选择默认支付方式、优惠券后还会更新需付款
            PaymentController.payViewDataPayment.payAmount = PaymentController.payViewDataDetail.payOrderResultData.orderAmount;
            //如果不显示优惠券，就过滤掉所有优惠券
            if (!PaymentController.payOrderData.useVoucher) {
                PaymentController.payViewDataDetail.payOrderResultData.voucher = [NSMutableArray array];
            }
            //支付方式分类
            [PaymentController.payViewDataDetail.payOrderResultData.payMethod enumerateObjectsUsingBlock:^(KQPayMethod * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.available isEqualToString:@"true"]) {
                    if (![PaymentController.payViewDataDetail.payModeArray containsObject:obj]) {
                        [PaymentController.payViewDataDetail.payModeArray addObject:obj];
                    }
                } else {
                    if (![PaymentController.payViewDataDetail.payModeDisabledArray containsObject:obj]) {
                        [PaymentController.payViewDataDetail.payModeDisabledArray addObject:obj];
                    }
                }
            }];
            //找默认支付方式，要考虑available是否为@"true"
            if (PaymentController.payViewDataDetail.payOrderResultData.payMethod) {
                if (PaymentController.oldPayOrderResultData) {
                    //如果oldPaymentResultData不为空，就对比查找出最新添加的支付方式，作为默认支付方式，如果没有找到新的支付方式，那么self.PaymentController.payViewDataDetail.defaultPayMode就是空的
                    NSMutableDictionary *payMethodDic = [NSMutableDictionary dictionary];
                    [PaymentController.oldPayOrderResultData.payMethod enumerateObjectsUsingBlock:^(KQPayMethod *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *key = [NSString stringWithFormat:@"%@%@", obj.bankCard, obj.bankId];
                        [payMethodDic setObject:obj forKey:key];
                    }];
                    [PaymentController.payViewDataDetail.payOrderResultData.payMethod enumerateObjectsUsingBlock:^(KQPayMethod *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *key = [NSString stringWithFormat:@"%@%@", obj.bankCard, obj.bankId];
                        if ((![payMethodDic objectForKey:key])&&([obj.available isEqualToString:@"true"])) {
                            PaymentController.payViewDataPayment.selectedPayMode = obj.methodId;
                            PaymentController.payViewDataPayment.selectedPayType = obj.payType;
                            *stop = YES;
                        }
                    }];
                }
                //第一次找默认支付方式或没有新的支付方式，就选第一个
                if ([NSString kqc_isBlank:PaymentController.payViewDataPayment.selectedPayMode]) {
                    [PaymentController.payViewDataDetail.payOrderResultData.payMethod enumerateObjectsUsingBlock:^(KQPayMethod *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.available isEqualToString:@"true"]) {
                            PaymentController.payViewDataPayment.selectedPayMode = obj.methodId;
                            PaymentController.payViewDataPayment.selectedPayType = obj.payType;
                            *stop = YES;
                        }
                    }];
                }
            }
            //优惠券分类
            //优惠券分类
            NSMutableDictionary *enablePassiveDic = [@{} mutableCopy];
            NSMutableDictionary *disablePassiveDic = [@{} mutableCopy];
            [PaymentController.payViewDataDetail.payOrderResultData.voucher enumerateObjectsUsingBlock:^(KQPayVoucher *voucher, NSUInteger idx, BOOL * _Nonnull stop) {
                [voucher.supportedMethodIdList enumerateObjectsUsingBlock:^(NSString *payMethodId, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSMutableDictionary *voucherDic = nil;
                    if ([voucher.status isEqualToString:@"true"]) {
                        if (voucher.voucherType == KQPayVoucherTypeActive) {
                            voucherDic = PaymentController.payViewDataDetail.enableVoucherDic;
                        } else {
                            voucherDic = enablePassiveDic;
                        }
                    }
                    else {
                        if (voucher.voucherType == KQPayVoucherTypeActive) {
                            voucherDic = PaymentController.payViewDataDetail.disableVoucherDic;
                        } else {
                            voucherDic = disablePassiveDic;
                        }
                    }
                    NSMutableArray *voucherArray = [voucherDic objectForKey:payMethodId];
                    if (!voucherArray) {
                        voucherArray = [NSMutableArray array];
                        [voucherDic setObject:voucherArray forKey:payMethodId];
                    }
                    if (![voucherArray containsObject:voucher]) {
                        //插入时就排好序
                        if (voucher.sourceFrom == KQPayVoucherFromMSXF) {
                            [voucherArray insertObject:voucher atIndex:0];
                        }else{
                            //                            插入时就排好序
                            NSUInteger count = voucherArray.count;
                            NSUInteger i = 0;
                            for (; i < count; i++)
                            {
                                KQPayVoucher *obj = [voucherArray objectAtIndex:i];
                                if (([voucher.voucherAmount doubleValue] > [obj.voucherAmount doubleValue]) && (voucher.sourceFrom != KQPayVoucherFromMSXF)) {
                                    [voucherArray insertObject:voucher atIndex:i];
                                    break;
                                }
                            }
                            //前面没有位置插入，插最后
                            if (i >= count) {
                                [voucherArray addObject:voucher];
                            }
                        }
                    }
                }];
            }];

            [enablePassiveDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSArray *passiveAry = [enablePassiveDic objectForKey:key];
                NSMutableArray *voucherArray = [PaymentController.payViewDataDetail.enableVoucherDic objectForKey:key];
                if (!voucherArray) {
                    voucherArray = [NSMutableArray array];
                    [PaymentController.payViewDataDetail.enableVoucherDic setObject:voucherArray forKey:key];
                }
                NSRange range = NSMakeRange(0, passiveAry.count);
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                [voucherArray insertObjects:passiveAry atIndexes:set];
            }];
            [disablePassiveDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSArray *passiveAry = [disablePassiveDic objectForKey:key];
                NSMutableArray *voucherArray = [PaymentController.payViewDataDetail.disableVoucherDic objectForKey:key];
                if (!voucherArray) {
                    voucherArray = [NSMutableArray array];
                    [PaymentController.payViewDataDetail.disableVoucherDic setObject:voucherArray forKey:key];
                }
                NSRange range = NSMakeRange(0, passiveAry.count);
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                [voucherArray insertObjects:passiveAry atIndexes:set];
            }];

            //如果没有锁定优惠券，则选择支付方式对应的优惠券
            //选择默认优惠券
            
            //商城分期方式分类
            [PaymentController.payViewDataDetail.payOrderResultData.instalment enumerateObjectsUsingBlock:^(KQPayInstalment *instalment, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray *instalmentArray = [PaymentController.payViewDataDetail.installmentDic objectForKey:instalment.instalmentType];
                if (!instalmentArray) {
                    instalmentArray = [NSMutableArray array];
                    if ([SpecialStages containsObject:instalment.instalmentType]) {
                        [PaymentController.payViewDataDetail.installmentDic setObject:instalmentArray forKey:instalment.instalmentType];
                    }
                }
                if (![instalmentArray containsObject:instalment]) {
                    [instalmentArray addObject:instalment];
                }
            }];
            
            // 选择默认优惠券
            if (!PaymentController.payViewDataPayment.selectedPayVoucher) {
                NSMutableArray *voucherArray = [PaymentController.payViewDataDetail.enableVoucherDic objectForKey:PaymentController.payViewDataPayment.selectedPayMode];
                if ([voucherArray count] > 0) {
                    PaymentController.payViewDataPayment.selectedPayVoucher = [voucherArray firstObject];
                }
            }
            
            //------- 新分期列表
            KQPayMethod * firstPayMethod;
            if (PaymentController.payViewDataDetail.payOrderResultData.payMethod.count > 0) {
                firstPayMethod = [PaymentController.payViewDataDetail.payOrderResultData.payMethod objectAtIndex:0];
            }
            
            
            if (firstPayMethod.isStagable && (PaymentController.payViewDataDetail.payOrderResultData.instalment.count > 0)) {
                NSString *defaultStageKey = [NSString stringWithFormat:@"%@%@", firstPayMethod.methodId, PaymentController.payViewDataPayment.selectedPayVoucher.voucherNo?:@""];
                NSMutableArray *instalmentArray = [PaymentController.payViewDataDetail.installmentDic objectForKey:defaultStageKey];
                // 默认分期
                [PaymentController.payViewDataDetail.defaultStageDic setObject:PaymentController.payViewDataDetail.payOrderResultData.defaultStage forKey:defaultStageKey];
                
                if (!instalmentArray) {
                    instalmentArray = [NSMutableArray array];
                    [PaymentController.payViewDataDetail.installmentDic setObject:instalmentArray forKey:defaultStageKey];
                }
                
                //分期方式分类
                [PaymentController.payViewDataDetail.payOrderResultData.instalment enumerateObjectsUsingBlock:^(KQPayInstalment *instalment, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx == 0 && [NSString kqc_isBlank:PaymentController.payViewDataDetail.payOrderResultData.defaultStage]) {
                        PaymentController.payViewDataPayment.selectedInstallment = instalment;
                    }
                    
                    if (![NSString kqc_isBlank:PaymentController.payViewDataDetail.payOrderResultData.defaultStage]){
                        if ([instalment.stageNumber isEqualToString:PaymentController.payViewDataDetail.payOrderResultData.defaultStage]) {
                            PaymentController.payViewDataPayment.selectedInstallment = instalment;
                        }
                    }
                    
                    if (![instalmentArray containsObject:instalment]) {
                        [instalmentArray addObject:instalment];
                    }
                }];
            }
            //------- 新分期列表

            //------- 新绑卡支持的支付方式类型
            NSArray *supportPayTypeArray = [PaymentController.payViewDataDetail.payOrderResultData.type componentsSeparatedByString:@","];
            if ([supportPayTypeArray containsObject:@"1"]&&[supportPayTypeArray containsObject:@"5"]) {
                PaymentController.payViewDataDetail.bindCardType = KQPayBindCardTypeAllCard;
            } else {
                if ([supportPayTypeArray containsObject:@"1"]) {
                    PaymentController.payViewDataDetail.bindCardType = KQPayBindCardTypeDebitCard;
                } else if ([supportPayTypeArray containsObject:@"5"]) {
                    PaymentController.payViewDataDetail.bindCardType = KQPayBindCardTypeCreditCard;
                } else {
                    PaymentController.payViewDataDetail.bindCardType = KQPayBindCardTypeNoneCard;
                }
            }
            //------- 支付方式锁定，H5传入
            //查找支付方式列表和优惠券列表是否有对应值
            if ([PaymentController.payMethodInfo.payType isEqualToString:@"1"]||[PaymentController.payMethodInfo.payType isEqualToString:@"5"]) {
                //银行卡和信用卡必须对比卡号和类型都一样
                if (![NSString kqc_isBlank:PaymentController.payMethodInfo.bankCard]) {
                    for (KQPayMethod *data in PaymentController.payViewDataDetail.payOrderResultData.payMethod) {
                        if ([data.payType isEqualToString:PaymentController.payMethodInfo.payType]&&[data.bankCard hasSuffix:PaymentController.payMethodInfo.bankCard]&&[data.bankId isEqualToString:PaymentController.payMethodInfo.bankId]) {
                            PaymentController.payViewDataPayment.selectedPayMode = data.methodId;
                            PaymentController.payViewDataDetail.lockPayMethod = YES;
                        }
                    }
                }
            } else {
                //其他情况只要类型一样
                for (KQPayMethod *data in PaymentController.payViewDataDetail.payOrderResultData.payMethod) {
                    if ([data.payType isEqualToString:PaymentController.payMethodInfo.payType]) {
                        PaymentController.payViewDataPayment.selectedPayMode = data.methodId;
                        PaymentController.payViewDataDetail.lockPayMethod = YES;
                    }
                }
            }
            //------- 支付方式锁定，H5传入
            
            //------- 分期锁定
            for (KQPayMethod *data in PaymentController.payViewDataDetail.payOrderResultData.payMethod) {
                if ([data.methodId isEqualToString:PaymentController.payViewDataPayment.selectedPayMode]) {
                    if ([data.payType isEqualToString:KQPayMethodPayTypeInstallment]) {
                        //如果是快易花支付方式要检查一下，不需要选择默认分期
                        [PaymentController checkFaceAuthorizationStatus:^(KQPayActionResultType resultType) {
                            if (resultType != KQPayActionResultTypeSuccess) {
                                PaymentController.payViewDataPayment.selectedPayMode = @"";
                                PaymentController.payViewDataDetail.lockPayMethod = NO;
                            }
                        }];
                    } else if ([data.payType isEqualToString:KQPayMethodPayTypeCreditCard]) {
                        //如果信用卡支付方式，并且已经锁定，则检查一下分期，选择第一个并锁定
                        NSMutableArray *instalment = [PaymentController.payViewDataDetail.installmentDic objectForKey:KQPayMethodPayTypeCreditCard];
                        for (KQPayInstalment * obj in instalment) {
                            PaymentController.payViewDataPayment.selectedInstallment = obj;
                            PaymentController.payViewDataDetail.lockPayInstalment = YES;
                        }
                        //如果信用卡分期方式多于1个，就不锁定
                        if (instalment.count > 1) {
                            PaymentController.payViewDataDetail.lockPayInstalment = NO;
                        }
                    }
                }
            }
            //------- 分期锁定
            
            //------- 优惠券锁定
            if (PaymentController.payViewDataDetail.lockPayMethod) {
                //锁定优惠券的前提是支付方式已经锁定，否则没有意义
                if (![NSString kqc_isBlank:PaymentController.payMethodInfo.voucherNo]) {
                    for (KQPayVoucher *data in PaymentController.payViewDataDetail.payOrderResultData.voucher) {
                        if ([data.voucherNo isEqualToString:PaymentController.payMethodInfo.voucherNo]) {
                            PaymentController.payViewDataPayment.selectedPayVoucher = data;
                            PaymentController.payViewDataDetail.lockPayVoucher = YES;
                        }
                    }
                }
            }
            //------- 优惠券锁定

            [PaymentController.payViewDataDetail.payOrderResultData.activityList enumerateObjectsUsingBlock:^(KQPayActivity * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj) {
                    [obj.payType enumerateObjectsUsingBlock:^(NSString * obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![NSString kqc_isBlank:obj1]) {
                            [PaymentController.payViewDataDetail.activityDic setObject:obj forKey:obj1];
                        }
                        
                    }];
                }
            }];

            payBlock(YES, @"可以支付", nil);
        }
        else {
            payBlock(NO, @"参数为空", ERROR_CODE_PAY_WRONG_ORDER_STATUS);
        }
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, Content *response) {
        payBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], ERROR_CODE_PAY_CALL_FAILED);
    } showWaitMode:KQHttpServiceWaitingViewModeShow];
}

+ (void)payRiskCheck:(PayRiskBlock)payRiskBlock
{
    KQPayRiskData *payRiskData = [KQPayOrderDataProcess getPayRiskDataFromObj:PaymentController.payViewDataDetail.payOrderResultData];
    if (!payRiskData) {
        payRiskBlock(NO, nil, @"参数为空");
        return;
    }
    payRiskData.payMethodId = PaymentController.payViewDataPayment.selectedPayMode;
    
    BOOL fingerFlag = [PaymentController.payViewDataDetail.payOrderResultData.status isEqualToString:@"1"];
    if (!SecureCertManager.isCertAvailable) {
        [self requestM271:payRiskData fingerFlag:fingerFlag certFlag:NO completion:payRiskBlock];
        return;
    }
    
    [SecureCertManager checkCertStatus:^(KQSecureCertStatus certStatus) {
        BOOL certFlag = certStatus == KQSecureCertStatusInstalled;
        [self requestM271:payRiskData fingerFlag:fingerFlag certFlag:certFlag completion:payRiskBlock];
    }];
}

+ (void)payUnNeedOrderRiskCheck:(PayRiskBlock __nullable)payRiskBlock{
    NSString *fingerFlagStr = @"";
    NSData *fingerData = nil;
    KQCFingerStatus fingerStatus = [KQBFingerManager isSystemFingerPayOn:&fingerData];
    if (fingerData) {
        fingerFlagStr = [fingerData base64EncodedStringWithOptions:0];
    }
    //系统版本满足，就表示有指纹这种硬件，并且系统是iOS9以上，这里还要加上OMS的指纹支付开关判断
    if (fingerStatus < KQCFingerStatusUnsupportSystemVersion) {
        PaymentController.payViewDataDetail.payOrderData.supportFinger = @"true";
    } else {
        PaymentController.payViewDataDetail.payOrderData.supportFinger = @"false";
    }
    PaymentController.payViewDataDetail.payOrderData.txnFlag = fingerFlagStr;
    
    KQPayRiskData *payRiskData = [KQPayOrderDataProcess getPayRiskDataFromUnNeedOrder:PaymentController.unNeedOrderData];
    if (!payRiskData) {
        payRiskBlock(NO, nil, @"参数为空");
        return;
    }
    payRiskData.payMethodId = PaymentController.unNeedOrderData.payMethod.methodId;
    
    BOOL fingerFlag = [PaymentController.unNeedOrderData.fingerStatus isEqualToString:@"1"];
    if (!SecureCertManager.isCertAvailable) {
        [self requestM271:payRiskData fingerFlag:fingerFlag certFlag:NO completion:payRiskBlock];
        return;
    }
    
    [SecureCertManager checkCertStatus:^(KQSecureCertStatus certStatus) {
        BOOL certFlag = certStatus == KQSecureCertStatusInstalled;
        [self requestM271:payRiskData fingerFlag:fingerFlag certFlag:certFlag completion:payRiskBlock];
    }];
}

+ (void)requestM271:(KQPayRiskData *)payRiskData fingerFlag:(BOOL)fingerFlag certFlag:(BOOL)certFlag completion:(PayRiskBlock)payRiskBlock
{
    if (fingerFlag && certFlag) {
        payRiskData.validateElement = KQPAYMENT_SP_PAY_WITH_FINGER_AND_SP_SIGN;
    } else if (fingerFlag) {
        payRiskData.validateElement = KQPAYMENT_SP_PAY_WITH_FINGER;
    } else if (certFlag) {
        payRiskData.validateElement = KQPAYMENT_SP_SIGN;
    } else {
        payRiskData.validateElement = KQPAYMENT_SP_ONLY_PSW;
    }
    NSArray *codeArray = [FunctionSwitchManager.m271ChangePayModeErrorCode componentsSeparatedByString:@","];
    // 风控支付金额
    payRiskData.payAmount = PaymentController.payViewDataPayment.payAmount;
    
    NSDictionary *m271Dic = [KQPayOrderDataProcess getM271Dic:payRiskData];

    [KQHttpService request:m271Dic bizType:@"M271" successBlock:^(Content *response) {
        if ([response.status isEqualToString:KQPAYMENT_RASK_CHECK_FREEZEUNBREAK]) {
            payRiskBlock(KQPayRiskShowResultFreezeUnbreak, nil, nil);
        }else if ([response.status isEqualToString:KQPAYMENT_RASK_CHECK_FREEZE]) {
            payRiskBlock(KQPayRiskShowResultFreeze, nil, nil);
        }else{
            payRiskBlock(KQPayRiskShowResultNone, nil, nil);
        }
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, Content *response) {
        if ([errorCode isEqualToString:KQPAYMENT_RASK_CHECK_TOAST]) {
            payRiskBlock(KQPayRiskShowResultToast, nil, errorMessage);
        }
        else if ([errorCode isEqualToString:KQPAYMENT_RASK_CHECK_SMS]) {
            payRiskBlock(KQPayRiskShowResultSms, response.validateElement, errorMessage);
        }
        else if ([codeArray containsObject:errorCode]) {
            payRiskBlock(KQPayRiskShowResultAlert, nil, errorMessage);
        }
        else {//add by lihui 所有未列出错误码改为弹出Toast。 2016年10月26日
            payRiskBlock(KQPayRiskShowResultToast, nil, errorMessage);
        }
    } showWaitMode:KQHttpServiceWaitingViewModeShow];
}

+ (void)queryTrialAmt:(PayResultBlock)payResBlock{
    //通过选择优惠券的类型 访问接口 VAS: 快钱权益 MSXF:马上消费
    KQPayVoucher *selectedVoucher = PaymentController.payViewDataPayment.selectedPayVoucher;
    //    if (!selectedVoucher) {
    //        payResBlock(YES, nil, nil, KQPayShowResultWayNone, KQPayShowAlertContentNone);
    //        return;
    //    }
    
    NSMutableDictionary *requestDic = [@{@"businessType":@"2",
                                         @"payMethodId":PaymentController.payViewDataPayment.selectedPayMode,
                                         @"instalmentId":PaymentController.payViewDataPayment.selectedInstallment.id, @"orderType":KQC_NON_NIL(PaymentController.payViewDataDetail.payOrderResultData.orderType),
                                         @"merchantCode":KQC_NON_NIL(PaymentController.payViewDataDetail.payOrderResultData.merchantCode)
                                         } mutableCopy];
    
    if (selectedVoucher){
        requestDic[@"orderAmount"] = selectedVoucher.payAmount;
    }else{
        requestDic[@"orderAmount"] = PaymentController.payViewDataPayment.payAmount;
    }
    if (selectedVoucher && selectedVoucher.sourceFrom == KQPayVoucherFromMSXF) {//马上卷
        requestDic[@"id"] = selectedVoucher.voucherNo;
    }
    
    [KQHttpService request:requestDic bizType:@"M354" successBlock:^(Content *response) {
        PaymentController.payViewDataDetail.trialTotalAmt = response.totalAmt;
        PaymentController.payViewDataDetail.trialAmt = response.amt;
        PaymentController.payViewDataDetail.trialRipAmt = response.ripAmount;
        payResBlock(YES, nil, nil, KQPayShowResultWayNone, KQPayShowAlertContentNone);
    }];
}

+ (void)verifyPayPassword:(PayResultBlock)payResBlock
{
    //验证密码
    //M071接口phoneNo剥离 feng.zou 2016-03-21
    NSDictionary *m071Dic = @{/*@"phoneNo":KQB_CurrentUser.phoneNo,*/
                              @"password":PaymentController.payViewDataPayment.payPassword,
                              @"passwordType":@"2",
                              @"validateCode":@"",
                              @"token":@"",
                              @"optionType":@"1"};
    [KQHttpService request:m071Dic bizType:@"M071" successBlock:^(id response) {
        payResBlock(YES, nil, nil,KQPayShowResultWayNone, KQPayShowAlertContentNone);
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        if ([errorCode isEqualToString:ERROR_CODE_M071_PWD_FAILED]) {
            //忘记密码
            payResBlock(NO, errorMessage, nil, KQPayShowResultWayAlert, KQPayShowAlertContentReinputForgetpwd);
        }
        else if ([errorCode isEqualToString:ERROR_CODE_M071_PWD_FROZEN]) {
            //密码锁定
            payResBlock(NO, errorMessage, nil, KQPayShowResultWayAlert, KQPayShowAlertContentOkFindpwd);
        }
        else {
            payResBlock(NO, errorMessage, nil, KQPayShowResultWayTips, KQPayShowAlertContentNone);
        }
    } showWaitMode:KQHttpServiceWaitingViewModeShow];
}

+ (void)getPaySms:(PaySmsBlock)paySmsBlock
{
    KQPaySmsData *paySmsData;
    if (PaymentController.unNeedOrderData) {
        paySmsData = [KQPayOrderDataProcess getUnNeedPaySmsDataFromObj:PaymentController.unNeedOrderData];
    }else{
        paySmsData = [KQPayOrderDataProcess getPaySmsDataFromObj:PaymentController.payViewDataDetail.payOrderResultData];
        
    }
    if (!paySmsData) {
        paySmsBlock(NO, @"参数为空");
        return;
    }
    
    NSDictionary *m270Dic;
    if (PaymentController.unNeedOrderData) {
        m270Dic = [KQPayOrderDataProcess getUnNeedOrderM270Dic:paySmsData];
    }else{
        m270Dic = [KQPayOrderDataProcess getM270Dic:paySmsData];
    }
    
    [KQHttpService request:m270Dic bizType:@"M270" successBlock:^(id response) {
        paySmsBlock(YES, nil);
    } showWaitMode:KQHttpServiceWaitingViewModeShow];
}

+ (void)modifyBankCardCVV2:(NSString*)cvv2 completion:(PayCVV2Block)payCVV2Block {
    KQPayMethod *payMethod = nil;
    for (KQPayMethod *data in PaymentController.payViewDataDetail.payOrderResultData.payMethod) {
        if ([data.methodId isEqualToString:PaymentController.payViewDataPayment.selectedPayMode]) {
            payMethod = data;
        }
    }
    
    NSDictionary *m314Dic = @{@"phoneNo":KQC_NON_NIL(payMethod.phoneNo),
                              @"payMethodId":PaymentController.payViewDataPayment.selectedPayMode,
                              @"cvv2":cvv2};
    [KQHttpService request:m314Dic bizType:@"M314" successBlock:^(id response) {
        [KQBToastView show:@"CVV2保存成功"];
        if (payCVV2Block) {
            payCVV2Block(YES);
        }
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        [KQBToastView show:errorMessage];
        if (payCVV2Block) {
            payCVV2Block(NO);
        }
    } showWaitMode:KQHttpServiceWaitingViewModeShow];
}

+ (void)endPull
{
    PaymentController.pullMaxTry = KPullTimesUninitValue;
    PaymentController.leftPullMaxTry = 0;

}

+ (void)payOrder:(PayResultBlock)payResBlock showWait:(BOOL)showWait {
    KQPaymentData *paymentData = [KQPayOrderDataProcess getPaymentDataFromObj:PaymentController.payViewDataDetail.payOrderResultData];
    if (!paymentData) {
        payResBlock(NO, @"参数为空", nil, KQPayShowResultWayTips, KQPayShowAlertContentNone);
        return;
    }
    
    NSString *txnFlag = @"";
    NSData *fingerData = nil;
    [KQBFingerManager isSystemFingerPayOn:&fingerData];
    if (fingerData) {
        txnFlag = [fingerData base64EncodedStringWithOptions:0];
    }
    
    paymentData.payAmount = PaymentController.payViewDataDetail.payOrderResultData.orderAmount;
    paymentData.payPassword = PaymentController.payViewDataPayment.payPassword;
    paymentData.payMethodId = PaymentController.payViewDataPayment.selectedPayMode;
    paymentData.instalmentId = PaymentController.payViewDataPayment.selectedInstallment.id;
    paymentData.sMsCode = PaymentController.payViewDataPayment.paySms;
    paymentData.token = PaymentController.payViewDataPayment.token;
    paymentData.txnFlag = txnFlag;
    paymentData.stlMerchantCode = PaymentController.payViewDataDetail.payOrderResultData.stlMerchantCode;
    if (PaymentController.payViewDataPayment.selectedPayVoucher) {
        paymentData.equityCode = PaymentController.payViewDataPayment.selectedPayVoucher.voucherNo;
        paymentData.equityAmount = PaymentController.payViewDataPayment.selectedPayVoucher.voucherAmount;
    }
    
    paymentData.notifyMode = PaymentController.payViewDataDetail.payOrderData.orderSource;

    KQPayVoucher *voucher = PaymentController.payViewDataPayment.selectedPayVoucher;
    if (PaymentController.payViewDataPayment.selectedPayVoucher) {
        NSDictionary *equityDic = (voucher.voucherType == KQPayVoucherTypeActive)?@{@"equityCode":KQC_NON_NIL(voucher.voucherNo), @"equityType":KQC_NON_NIL(voucher.mediaType)}:
        @{@"equityId":KQC_NON_NIL(voucher.voucherNo),
          @"equityType":KQC_NON_NIL(voucher.mediaType),
          @"sourceFrom":voucher.sourceFrom==KQPayVoucherFromMSXF? @"MSXF" : @"VAS",
          };
        paymentData.equityInfo = [NSMutableArray array];
        [paymentData.equityInfo addObject:equityDic];
    }
    
    NSMutableDictionary *m250Dic = [[KQPayOrderDataProcess getM250Dic:paymentData] mutableCopy];
    if (PaymentController.payOrderData && PaymentController.payOrderData.payOrigin == KQPayFromJs) {
        m250Dic[@"showVoucher"] = PaymentController.payOrderData.useVoucher?@"1":@"0";
    }
    
    if (PaymentController.payViewDataDetail.payOrderData && PaymentController.payViewDataDetail.payOrderData.siedc.length > 0 && ![PaymentController.payViewDataDetail.payOrderData.siedc isEqualToString:@"nil"]) {
        m250Dic[@"siedc"] = PaymentController.payViewDataDetail.payOrderData.siedc;
    }
    
    // M250 -> M360
    [KQHttpService request:m250Dic bizType:@"M360" successBlock:^(Content *response) {
        KQQueryRequestData *queryData = [KQQueryRequestData new];
        queryData.billOrderNo = paymentData.billOrderNo;
        queryData.businessType = @"2";
        queryData.merchantCode = paymentData.merchantCode;
        queryData.payMethodId = paymentData.payMethodId;
        queryData.outTradeNo = paymentData.outTradeNo;
        
        PaymentController.pullMaxTry = KPullTimesUninitValue;

        [KQPayDataInterface pullPayResult:queryData result:payResBlock];
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, Content *response) {
        PaymentController.payViewDataResult.paymentResultData = [KQPayOrderDataProcess getPaymentResultDataFromObj:response];
        PaymentController.payViewDataResult.paymentResultData.errorInfo = [KQPayDataInterface checkErrorMessage:errorMessage];
        NSString *outputErrorCode = response.sMsCode.length > 0 ? [NSString stringWithFormat:@"[%@]", response.sMsCode] : nil;
        
        [self paymentErrorHandler:errorCode message:errorMessage outputErrorCode:outputErrorCode result:payResBlock];
    } showWaitMode:showWait?KQHttpServiceWaitingViewModeShow:KQHttpServiceWaitingViewModeNotShow];
}

+ (void)payUnNeedOrderPay:(PayResultBlock)payResBlock showWait:(BOOL)showWait {
    //指纹相关
    KQPaymentData *paymentData = [KQPayOrderDataProcess getUnNeedOrderPaymentDataFromObj:PaymentController.unNeedOrderData];
    if (!paymentData) {
        payResBlock(NO, @"参数为空", nil, KQPayShowResultWayTips, KQPayShowAlertContentNone);
        return;
    }
    
    NSString *txnFlag = @"";
    NSData *fingerData = nil;
    [KQBFingerManager isSystemFingerPayOn:&fingerData];
    if (fingerData) {
        txnFlag = [fingerData base64EncodedStringWithOptions:0];
    }
    
    paymentData.payAmount = PaymentController.unNeedOrderData.orderAmount;
    paymentData.payPassword = PaymentController.payViewDataPayment.payPassword;
    paymentData.payMethodId = PaymentController.unNeedOrderData.payMethod.methodId;
    paymentData.sMsCode = PaymentController.payViewDataPayment.paySms;
    paymentData.token = PaymentController.payViewDataPayment.token;
    paymentData.txnFlag = PaymentController.unNeedOrderData.txnFlag;
    paymentData.branchBank = PaymentController.payAdditionalInfo.branchBank;
    paymentData.city = PaymentController.payAdditionalInfo.city;
    paymentData.province = PaymentController.payAdditionalInfo.province;
    paymentData.businessType = PaymentController.payAdditionalInfo.businessType;
    
    NSMutableDictionary *m341Dic = [[KQPayOrderDataProcess getM341Dic:paymentData] mutableCopy];
    m341Dic[@"orderType"] = PaymentController.unNeedOrderData.orderType;
//    m341Dic[@"businessType"] = @"0";
    [KQHttpService request:m341Dic bizType:@"M341" successBlock:^(Content *response) {
        PaymentController.payViewDataResult.paymentResultData = [KQPayOrderDataProcess getUnNeedOrderPaymentResultDataFromObj:response];
        payResBlock(YES, nil, nil, KQPayShowResultWayNone, KQPayShowAlertContentNone);
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, Content *response) {
        if (![response isKindOfClass:[Content class]]) {
            payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], nil, KQPayShowResultWayAlert, KQPayShowAlertContentOkOnly);
            return;
        }
        PaymentController.payViewDataResult.paymentResultData = [KQPayOrderDataProcess getUnNeedOrderPaymentResultDataFromObj:response];
        PaymentController.payViewDataResult.paymentResultData.errorInfo = [KQPayDataInterface checkErrorMessage:errorMessage];
        
        if ([errorCode isEqualToString:ERROR_CODE_PAY_PWD_FAILED]) {
            //忘记密码
            payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], nil, KQPayShowResultWayAlert, KQPayShowAlertContentReinputForgetpwd);
        } else if ([errorCode isEqualToString:ERROR_CODE_PAY_PWD_FROZEN]) {
            //密码锁定
            payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], nil, KQPayShowResultWayAlert, KQPayShowAlertContentOkFindpwd);
        } else if ([errorCode isEqualToString:ERROR_CODE_M341_CARD_INFO_FAILED]){
            //银行卡手机号码错误
            payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], nil, KQPayShowResultWayBankCardPhoneNoError, KQPayShowAlertContentNone);
        } else if ([errorCode isEqualToString:ERROR_CODE_M341_CVV2_FAILED]){
            //银行卡CVV2错误
            payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], nil, KQPayShowResultWayBankCardCVV2Error, KQPayShowAlertContentNone);
        } else if ([errorCode isEqualToString:ERROR_CODE_M341_SWITCH_PAY_METHOD]){
            //M341返回特殊的错误码
            payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], nil, KQPayShowResultSwitchPayMothedError, KQPayShowAlertContentNone);
        } else {
            //支付失败页：显示错误信息，点击确定转至交易结果页，不在以上abcd的统一到支付失败页
            payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], nil, KQPayShowResultWayFailedView, KQPayShowAlertContentNone);
        }
    } showWaitMode:showWait?KQHttpServiceWaitingViewModeShow:KQHttpServiceWaitingViewModeNotShow];
}

+ (NSString*)checkErrorMessage:(NSString*)errorMessage{
  if (![NSString kqc_isBlank:errorMessage]) {
        return errorMessage;
    } else {
        return @"未知错误";
    }
}

+ (void)calculateStageInfo:(PayStageBlock __nullable)payStageBlock payMethodId:(NSString *)payMethodId{
    NSString *amt = PaymentController.payViewDataPayment.payAmount;
    //马上金服 优惠券金额 或者原金额
    if (![NSString kqc_isBlank:payMethodId] ) {
        NSArray *vourceAry = PaymentController.payViewDataDetail.enableVoucherDic[payMethodId];
        KQPayVoucher *voucher = vourceAry[0];
        amt = voucher? voucher.payAmount : PaymentController.payViewDataDetail.payOrderResultData.orderAmount;
    }
    
    NSDictionary *m354Dic = @{@"merchantCode":KQC_NON_NIL(PaymentController.payViewDataDetail.payOrderResultData.merchantCode),
                              @"orderAmount":KQC_NON_NIL(amt),
                              @"orderType":KQC_NON_NIL(PaymentController.payViewDataDetail.payOrderResultData.orderType),
                              @"payMethodId":KQC_NON_NIL(payMethodId?:PaymentController.payViewDataPayment.selectedPayMode)};
    [KQHttpService request:m354Dic bizType:@"M354" successBlock:^(id response) {
        payStageBlock(YES, [KQPayOrderDataProcess getPayStageDataFromObj:response], [KQPayOrderDataProcess getPayDefaultStageFromObj:response]);

    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        payStageBlock(NO, nil, nil);

    } showWaitMode:KQHttpServiceWaitingViewModeShow];
}


+ (void)pullPayResult:(KQQueryRequestData *)queryData result:(PayResultBlock)payResBlock {
    if (!queryData.merchantCode || !queryData.outTradeNo || !queryData.businessType || !queryData.billOrderNo || !queryData.payMethodId ) {
        [KQBToastView show:@"轮询参数异常"];
        return;
    }
    
    NSMutableDictionary *m361Dic = [NSMutableDictionary dictionary];
    
    [m361Dic setObject:queryData.merchantCode forKey:@"merchantCode"];
    [m361Dic setObject:queryData.outTradeNo forKey:@"outTradeNo"];
    [m361Dic setObject:queryData.businessType forKey:@"businessType"];
    [m361Dic setObject:queryData.billOrderNo forKey:@"billOrderNo"];
    [m361Dic setObject:KQC_NON_NIL(queryData.tradeId) forKey:@"tradeId"];
    [m361Dic setObject:queryData.payMethodId forKey:@"payMethodId"];
    
    [KQHttpService request:m361Dic bizType:@"M361" successBlock:^(id response) {
        [KQPayDataInterface endPull];
        //PaymentController.resultDic = self.pullApi.payQueryResultDic; 支付结果回传
        // 2018-01-10 本期未实现
        PaymentController.payViewDataResult.paymentResultData = [KQPayOrderDataProcess getPaymentResultDataFromObj:response];
        payResBlock(YES, nil,nil, KQPayShowResultWayNone, KQPayShowAlertContentNone);
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        PaymentController.payViewDataResult.paymentResultData = [KQPayOrderDataProcess getPaymentResultDataFromObj:response];

        if ([errorCode isEqualToString:@"03"]) {
            //TODO:最大次数判断
            if (PaymentController.pullMaxTry == KPullTimesUninitValue) {
                PaymentController.pullMaxTry = PaymentController.payViewDataResult.paymentResultData.queryTimes.integerValue;
                PaymentController.pollingInterval = PaymentController.payViewDataResult.paymentResultData.queryInterval.doubleValue/1000;
                PaymentController.leftPullMaxTry = PaymentController.pullMaxTry;
            }
            PaymentController.leftPullMaxTry--;
            
            if (PaymentController.leftPullMaxTry > 0) {
                int64_t delayInSeconds = PaymentController.pollingInterval;// 延迟的时间
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [KQPayDataInterface pullPayResult:queryData result:payResBlock];
                });
            } else {
                //PaymentController.resultDic = self.pullApi.payQueryResultDic; 支付结果回传
                // 2018-01-10 本期未实现
                payResBlock(NO, @"支付超时，请到账单中查看支付结果", nil, KQPayShowResultWayAlert, KQPayShowAlertContentOkOnly);
            }
        } else {
            
            NSString *outputErrorCode = KQC_NON_NIL([response valueForKey:@"sMsCode"]);
            outputErrorCode = outputErrorCode.length > 0 ? [NSString stringWithFormat:@"[%@]",outputErrorCode] : nil;
            PaymentController.payViewDataResult.paymentResultData.errorInfo = [KQPayDataInterface checkErrorMessage:errorMessage];
            
            [self paymentErrorHandler:errorCode message:errorMessage outputErrorCode:outputErrorCode result:payResBlock];
        }
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
}


/**
 用于处理原M250接口错误码，现M250改为M360。
 并添加M361接口错误码处理。
 
 @param errorCode 错误码
 @param errorMessage 错误信息
 @param outputErrorCode 对外错误码
 @param payResBlock 处理结果回掉
 */
+ (void)paymentErrorHandler:(NSString *)errorCode message:(NSString *)errorMessage outputErrorCode:(NSString *)outputErrorCode result:(PayResultBlock)payResBlock {
    
    if ([errorCode isEqualToString:ERROR_CODE_PAY_PWD_ERROR]) {
        //忘记密码
        payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], outputErrorCode, KQPayShowResultWayAlert, KQPayShowAlertContentReinputForgetpwd);
    } else if ([errorCode isEqualToString:ERROR_CODE_PAY_PWD_LOCK]) {
        //密码锁定
        payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], outputErrorCode, KQPayShowResultWayAlert, KQPayShowAlertContentOkFindpwd);
    } else if ([errorCode isEqualToString:ERROR_CODE_M250_CARD_INFO_FAILED]){
        //银行卡手机号码错误
        payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], outputErrorCode,KQPayShowResultWayBankCardPhoneNoError, KQPayShowAlertContentNone);
    } else if ([errorCode isEqualToString:ERROR_CODE_M250_CVV2_FAILED]){
        //银行卡CVV2错误
        payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], outputErrorCode, KQPayShowResultWayBankCardCVV2Error, KQPayShowAlertContentNone);
    } else if ([errorCode isEqualToString:ERROR_CODE_M250_SWITCH_PAY_METHOD]){
        //M250返回特殊的错误码
        payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], outputErrorCode, KQPayShowResultSwitchPayMothedError, KQPayShowAlertContentNone);
    } else if ([errorCode isEqualToString:ERROR_CODE_M250_UNIONPAY_INVALID]) {
        // 开通银联在线支付：点击问号进入开通的帮助页面，右侧按钮为更换支付方式，点击后回到支付方式列表页，左侧按钮放弃付款，点击回到交易结果页
        payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], outputErrorCode, KQPayShowResultUnionPayInvalidError, KQPayShowAlertContentNone);
    } else if ([errorCode isEqualToString:ERROR_CODE_M250_UNBINDCARD]) {
        //解绑银行卡：因为在cfs保存的银行卡信息有误，需要用户重新解绑后再绑定，点击解绑银行卡跳转到银行卡列表页
        payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], outputErrorCode, KQPayShowResultUnbindCardError, KQPayShowAlertContentNone);
    } else {
        payResBlock(NO, [KQPayDataInterface checkErrorMessage:errorMessage], outputErrorCode, KQPayShowResultWayFailedView, KQPayShowAlertContentNone);
    }
}

- (void)dealloc
{
    NSLog(@"%@：dealloc", self);
}

@end
