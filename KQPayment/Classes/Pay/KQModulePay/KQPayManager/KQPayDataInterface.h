//
//  KQPayDataInterface.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/24.
//
//

#import <Foundation/Foundation.h>

/*
 支付订单获取结果block
 */
typedef void(^PrepareForPayBlock)(BOOL result, NSString* __nullable error, NSString* __nullable errorNo);

typedef NS_ENUM(NSInteger, KQPayRiskShowResult)
{
    KQPayRiskShowResultNone = 1,        //可继续正常支付,00
    KQPayRiskShowResultSms,             //需要短信验证,34
    KQPayRiskShowResultAlert,           //alert提示，需要切换支付方式,other
    KQPayRiskShowResultToast,           //Tip提示,10
    KQPayRiskShowResultFreezeUnbreak,   //冻结不可解冻
    KQPayRiskShowResultFreeze           //冻结可解冻
};
/*
 支付风险合规结果block
 */
typedef void(^PayRiskBlock)(KQPayRiskShowResult result, NSString * __nullable validateElement, NSString * __nullable error);

/*
 获取统一收单短信验证接口
 */
typedef void(^PaySmsBlock)(BOOL result, NSString* __nullable error);

/*
 修改cvv2的结果block
 */
typedef void(^PayCVV2Block)(BOOL result);

typedef void(^PayStageBlock)(BOOL result, NSArray * __nullable stages, NSString * __nullable defaultStage);

typedef NS_ENUM(NSInteger, KQPayShowResultWay)
{
    KQPayShowResultWayNone = 1,
    KQPayShowResultWayAlert,                    //以alert的方式显示支付错误
    KQPayShowResultWayFailedView,               //以支付错误结果页的方式显示支付错误
    KQPayShowResultWayTips,                     //以toast的方式显示支付错误
    KQPayShowResultWayBankCardPhoneNoError,     //支付错误，可以跳转到修改银行卡绑定电话
    KQPayShowResultWayBankCardCVV2Error,        //支付错误，可以跳转到CVV2修改页
    KQPayShowResultSwitchPayMothedError,        //支付错误，可以切换支付方式
    KQPayShowResultUnionPayInvalidError,        //未开通银联支付
    KQPayShowResultUnbindCardError,             //解除绑定银行卡，跳转到银行卡页面
};

typedef NS_ENUM(NSInteger, KQPayShowAlertContent)
{
    KQPayShowAlertContentNone = 1,
    KQPayShowAlertContentReinputForgetpwd,      //alert包含"重新输入" "忘记密码"
    KQPayShowAlertContentOkFindpwd,             //alert包含"确定" "忘记密码"
    KQPayShowAlertContentOkOnly                 //alert只包含"确定"
};

/*
 支付结果
 参数：
 showResult，错误的显示方式
 alertContent，当错误显示方式为KQPayShowResultWayAlert时，才有效
 */
typedef void(^PayResultBlock)(BOOL result, NSString* __nullable error, NSString * __nullable _NullableoutputErrorCode, KQPayShowResultWay showResult, KQPayShowAlertContent alertContent);

@interface KQPayDataInterface : NSObject

/*
 查询订单
 */
+ (void)getPayOrderResultData:(PrepareForPayBlock __nullable)payBlock;

/*
 根据订单数据，来获取支付风险
 参数
 status表示M251返回的指纹开启状态
 */
+ (void)payRiskCheck:(PayRiskBlock __nullable)payRiskBlock;

+ (void)payUnNeedOrderRiskCheck:(PayRiskBlock __nullable)payRiskBlock;

/*
 验证支付密码
 */
+ (void)verifyPayPassword:(PayResultBlock __nullable)payResBlock;

/**
 查询试算金额
 **/
+ (void)queryTrialAmt:(PayResultBlock __nullable)payResBlock;

/*
 获取统一收单的短信验证码
 */
+ (void)getPaySms:(PaySmsBlock __nullable)paySmsBlock;

/*
 统一支付过程中，修改卡片cvv2
 */
+ (void)modifyBankCardCVV2:(NSString *  __nullable)cvv2 completion:(PayCVV2Block __nullable)payCVV2Block;

/*
 支付订单
 */
+ (void)payOrder:(PayResultBlock __nullable)payResBlock showWait:(BOOL)showWait;

/*
 无下单的订单支付
 */
+ (void)payUnNeedOrderPay:(PayResultBlock __nullable)payResBlock showWait:(BOOL)showWait;

/**
 分期试算接口
 
 @param payStageBlock 试算结果
 */
+ (void)calculateStageInfo:(PayStageBlock __nullable)payStageBlock payMethodId:(NSString * __nullable)payMethodId;

@end
