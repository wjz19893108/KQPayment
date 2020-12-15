//
//  KQPaymentController.h
//  kuaiQianbao
//
//  Created by zouf on 16/1/15.
//
//
#import "KQPayManagerDelegate.h"
#import "KQPayViewStepDelegate.h"
#import "KQPayViewData.h"


#define PaymentController [KQPaymentController sharedKQPaymentController]

@class KQPayOrderData;
@class KQPayMethod;
@class KQPayMethodInfoBeforePay;
@class KQPayBankAccountInfo;
@interface KQPaymentController : NSObject

@property (nonatomic, assign) BOOL internalCall;                      //调用支付是第三方app还是app内部
@property (nonatomic, weak, nullable) id<KQPayManagerDelegate> delegate;     //流程代理
@property (nonatomic, weak, nullable) id<KQPayViewStepDelegate> viewStepDelegate;  //步骤代理
@property (nonatomic, strong, nullable) KQPayMethodInfoBeforePay *payMethodInfo;    //支付前如果确定了支付方式和优惠券，那么这些信息是不可选的
@property (nonatomic, strong, nullable) KQPayAdditionalInfo *payAdditionalInfo;     //充值提现所需额外信息
@property (nonatomic, strong, nullable) KQPayOrderData *payOrderData;               //请求订单信息
@property (nonatomic, strong, nullable) KQPayViewDataDetail *payViewDataDetail;     //详情页数据
@property (nonatomic, strong, nullable) KQPayViewDataPayment *payViewDataPayment;   //支付过程中收集的数据
@property (nonatomic, strong, nullable) KQPayViewDataResult *payViewDataResult;     //支付结果数据
@property (nonatomic, strong, nullable) KQPayUnNeedOrderData *unNeedOrderData;      //无需下单 请求订单信息
@property (nonatomic, strong, nullable) KQPayOrderResultData *oldPayOrderResultData;//上一次请求的订单数据，用于绑定新卡时过滤出新卡
@property (nonatomic, strong, nullable) NSDictionary *resultDic;

@property (nonatomic, assign) NSInteger pullMaxTry;//最大轮询次数
@property (nonatomic, assign) NSInteger leftPullMaxTry;//最大轮询次数

@property (nonatomic, assign) double pollingInterval;//轮询次数剩余

+ (instancetype __nullable)sharedKQPaymentController;

/*
 初始化后，请调用此接口准备开始支付流程第一步，即弹出支付详情页
 */
- (void)pay:(KQPayOrderData * __nonnull)payOrderData delegate:(id<KQPayManagerDelegate> __nonnull)delegate;

/*
 初始化后，请调用此接口准备开始支付流程第一步，即弹出支付详情页 无需下单情况
 */
- (void)payUnNeedOrder:(KQPayUnNeedOrderData * __nonnull)payOrderData delegate:(id<KQPayManagerDelegate> __nonnull)delegate;

/*
 快易花状态检查
 */
- (void)checkFaceAuthorizationStatus:(void(^ __nullable)(KQPayActionResultType resultType))resultBlock;

@end
