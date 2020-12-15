//
//  KQPayViewData.h
//  kuaiQianbao
//
//  Created by zouf on 16/11/29.
//
//

#import <Foundation/Foundation.h>


/*
 绑卡支持的卡片类型
 */
typedef NS_ENUM(NSInteger, KQPayBindCardType)
{
    KQPayBindCardTypeCreditCard = 0,         //信用卡@"1"
    KQPayBindCardTypeDebitCard,              //借记卡@"2"
    KQPayBindCardTypeAllCard,                //所有卡@"3"
    KQPayBindCardTypeNoneCard                //所有卡片都不支持，此时不显示支付方式中的“添加其他银行卡”
};

@class KQPayOrderData;
@class KQPayOrderResultData;
@class KQPayVoucher;
@class KQPaymentResultData;
@class KQPayUnNeedOrderData;
@class KQPayInstalment;

/*
 支付详情页数据
 */
@interface KQPayViewDataDetail : NSObject

- (instancetype __nullable)initWithPayOrderData:(KQPayOrderData * __nonnull)payOrderData;
- (instancetype __nullable)initWithPayUnNeedOrderData:(KQPayUnNeedOrderData * __nonnull)payOrderData;
//商户名称，显示顺序merchantName subMerchantName productDesc，有就显示，没有就选下一个
@property (nonatomic, strong, nullable) KQPayOrderData *payOrderData;                   //订单数据，包含merchantName
@property (nonatomic, strong, nullable) KQPayOrderResultData *payOrderResultData;       //M251返回数据，包含subMerchantName productDesc
//账户名称
@property (nonatomic, strong, nullable) NSString *accountDisplayName;       //账户名称
//支付方式列表
//支付方式列表在payOrderResultData.payMethod中
@property (nonatomic, strong, nonnull) NSMutableArray *payModeArray;                    //可用支付方式
@property (nonatomic, strong, nonnull) NSMutableArray *payModeDisabledArray;            //不可用支付方式
@property (nonatomic, assign) BOOL lockPayMethod;                           //支付方式是否可更换
@property (nonatomic, assign) KQPayBindCardType bindCardType;               //可以绑定卡的类型
//分期方式列表
//分期信息列表在payOrderResultData.instalment中
//@property (nonatomic, strong, nonnull) NSMutableDictionary *installmentDic;             //分期,key:4快易花 5信用卡,value:分期对象array
@property (nonatomic, strong, nonnull) NSMutableDictionary *installmentDic;             //分期,key:支付方式+优惠券号,value:分期对象array

@property (nonatomic, strong, nonnull) NSMutableDictionary *defaultStageDic;             //分期,key:支付方式+优惠券号,value:默认分期

@property (nonatomic, strong, nonnull) NSMutableDictionary *activityDic;             //分期,key:支付方式号,value:活动对象array


@property (nonatomic, assign) BOOL lockPayInstalment;                                   //分期是否可更换
//优惠券，M251请求完成，计算支付方式对应的可用与不可用优惠券
//权益列表在payOrderResultData.voucher中
@property (nonatomic, strong, nullable) NSMutableDictionary *enableVoucherDic;          //key:支付方式index,value:可用voucher对象array
@property (nonatomic, strong, nullable) NSMutableDictionary *disableVoucherDic;         //key:支付方式index,value:不可用voucher对象array
@property (nonatomic, assign) BOOL lockPayVoucher;                          //优惠券是否可更换
//备注信息在payOrderResultData.memo中
//M354 返回带划线金额
@property (nonatomic, strong, nullable) NSString *trialTotalAmt;//带划线金额
//M354 返回不带划线金额
@property (nonatomic, strong, nullable) NSString *trialAmt;//不带划线金额
//M354 返回不带划线金额
@property (nonatomic, strong, nullable) NSString *trialRipAmt;//优惠劵抵扣金额

@end

@class KQPayMethod;
/*
 支付过程中需要收集支付方式、分期方式、优惠券、支付密码、验证短信等信息
 */
@interface KQPayViewDataPayment : NSObject

- (instancetype __nullable)initWithPayViewDataDetail:(KQPayViewDataDetail * __nonnull)payViewDataDetail;
@property (nonatomic, strong, nullable) KQPayViewDataDetail *payViewDataDetail; //指向支付过程中的KQPayViewDataDetail对象
@property (nonatomic, strong, nullable) NSString *selectedPayMode;          //当前支付方式index
@property (nonatomic, strong, nullable) NSString *selectedPayType;          //当前支付方式类型
@property (nonatomic, strong, nullable) KQPayInstalment *selectedInstallment;  //当前的分期方式
@property (nonatomic, strong, nullable) KQPayVoucher *selectedPayVoucher;   //当前选择的优惠券对象
//需付款
@property (nonatomic, strong, nullable) NSString *payAmount;                //由于有了优惠券，需付款产生变化

@property (nonatomic, strong, nullable) NSString *payPassword;              //当前的支付密码
@property (nonatomic, assign) BOOL payNeedSms;                              //需要短信验证码
@property (nonatomic, strong, nullable) NSString *paySms;                   //短信验证码
@property (nonatomic, strong, nullable) NSString *token;                    //指纹支付时M302返回成功的token
@property (nonatomic, strong, nullable) KQPayMethod *payMethod;       //选中的支付方式

- (void)resetParam;

@end

/*
 支付结果数据
 */
@interface KQPayViewDataResult : NSObject

@property (nonatomic, strong, nullable) KQPaymentResultData *paymentResultData;     //支付结果数据
@property (nonatomic, assign) BOOL payResult;                                       //支付结果

@end
