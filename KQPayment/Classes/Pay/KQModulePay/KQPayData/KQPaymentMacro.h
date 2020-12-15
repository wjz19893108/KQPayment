//
//  KQPaymentMacro.h
//  kuaiQianbao
//
//  Created by zouf on 16/2/17.
//
//

#ifndef KQPaymentMacro_h
#define KQPaymentMacro_h

/*
 M251接口判断订单状态和支付状态时使用
 */
#define KQPAYMENT_ORDER_INVALID     @"您的订单已失效，请重新购买"
#define KQPAYMENT_ORDER_PAID        @"您的订单已支付，无需重复支付"
#define KQPAYMENT_ORDER_PAYING      @"您的订单正在付款中，请稍后再试"

/*
 M251接口支付状态
 */
#define KQPAY_STATUS_INIT           @"0"
#define KQPAY_STATUS_SUCCESS        @"1"
#define KQPAY_STATUS_FAIL           @"2"
#define KQPAY_STATUS_PAYING         @"3"

/*
 M251接口订单状态
 */
#define KQPAY_ORDER_STATUS_PREPARE_FOR_PAY  @"0"

/*
 M071和M250密码验证结果
 */
#define KQPAYMENT_PASSWORD_ERROR    @"04"
#define KQPAYMENT_PASSWORD_LOCKED   @"05"

/*
 M271接口判断是否能继续支付
 */
#define KQPAYMENT_RASK_CHECK_NONE   @"00"
#define KQPAYMENT_RASK_CHECK_TOAST  @"10"
#define KQPAYMENT_RASK_CHECK_SMS    @"34"
#define KQPAYMENT_RASK_CHECK_FREEZEUNBREAK    @"2"
#define KQPAYMENT_RASK_CHECK_FREEZE           @"1"

/*
 productCode定义
 */
#define KQPaymentProductCodeTransfer            @"180002"       //转账

/*
 支付方式KQPayMethod.payType定义
 */
#define KQPayMethodPayTypeDebitCard        @"1"         //借记卡
#define KQPayMethodPayTypeAccount          @"2"         //账户余额
#define KQPayMethodPayTypeFinancial        @"3"         //理财账户/快利来/飞凡宝
#define KQPayMethodPayTypeInstallment      @"4"         //快易花
#define KQPayMethodPayTypeCreditCard       @"5"         //信用卡
#define KQPayMethodPayTypeMedical          @"6"         //信用诊疗
#define KQPayMethodPayTypeMaShang          @"7"         //马上金服

#endif /* KQPaymentMacro_h */
