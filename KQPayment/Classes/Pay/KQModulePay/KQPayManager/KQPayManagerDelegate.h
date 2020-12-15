//
//  KQPayManagerDelegate.h
//  kuaiQianbao
//
//  Created by xy on 2016/10/9.
//
//

#import <Foundation/Foundation.h>
#import "KQPayOrderData.h"

/**
 支付过程中，实名的结果枚举

 - KQPayActionResultTypeSuccess: 动作成功
 - KQPayActionResultTypeCancel:  动作取消
 - KQPayActionResultTypeFailed:  动作失败
 */
typedef NS_ENUM(NSInteger, KQPayActionResultType) {
    KQPayActionResultTypeSuccess = 0,
    KQPayActionResultTypeCancel,
    KQPayActionResultTypeFailed
};

@protocol KQPayManagerDelegate <NSObject>

/**
 检查用户实名状态，如果用户未实名，需要调用实名流程进行实名

 @param payOrderData 待支付的订单数据
 @param resultBlock  通过此方法，将实名结果callback到支付流程
 */
- (void)payOrderData:(KQPayOrderData *)payOrderData realName:(void(^)(KQPayActionResultType resultType))resultBlock;

/**
 检查用户支付密码状态，如果用户未设置支付密码，需要调用设置支付密码流程

 @param payOrderData 待支付的订单数据
 @param resultBlock  通过此方法，将设置结果callback到支付流程
 */
- (void)payOrderData:(KQPayOrderData *)payOrderData payPassword:(void(^)(KQPayActionResultType resultType))resultBlock;

/**
 开始绑卡流程

 @param payOrderData 待支付的订单数据
 @param resultBlock  通过此方法，将设置结果callback到支付流程
 */
- (void)payOrderData:(KQPayOrderData *)payOrderData bindCard:(NSString *)cardType resultBlock:(void(^)(KQPayActionResultType resultType))resultBlock;

/**
 人脸识别

 @param payOrderData 待支付的订单数据
 @param resultBlock  通过此方法，将设置结果callback到支付流程
 */
- (void)payOrderData:(KQPayOrderData *)payOrderData faceAuthorization:(void(^)(KQPayActionResultType resultType))resultBlock;

/**
 找回支付密码
 
 @param payOrderData 待支付的订单数据
 @param resultBlock  通过此方法，将设置结果callback到支付流程
 */
- (void)payOrderData:(KQPayOrderData *)payOrderData findPayPassword:(void(^)(KQPayActionResultType resultType))resultBlock;

/**
 修改银行卡信息

 @param payOrderData 待支付的订单数据
 @param resultBlock  通过此方法，将设置结果callback到支付流程
 */
- (void)payOrderData:(KQPayOrderData *)payOrderData modifyBankCard:(NSString *)pan bankName:(NSString *)bankName resultBlock:(void(^)(KQPayActionResultType resultType))resultBlock;

/**
 支付结果
 
 @param result    支付错误、取消、成功
 @param errorCode 错误码
 @param desc      当前支付方式描述
 */
- (void)payResult:(KQPayResultType)result errorCode:(NSString*)errorCode payMethodDesc:(NSString*)desc resultDic:(NSDictionary *)resultDic;

@optional

/**
 为此订单指定支付方式

 @param payOrderData 待支付的订单数据

 @return 返回指定的支付方式
 */
- (KQPayMethodInfoBeforePay *)specialPayMethodForOrder:(KQPayOrderData *)payOrderData;

/**
 充值提现所需额外信息

 @return 额外信息
 */
- (KQPayAdditionalInfo *)forAdditionalInformation;

/**
 即将请求支付订单信息、支持的支付方式、优惠信息

 @param payOrderData 待支付的订单数据
 */
- (void)willQueryPayOrderInfo:(KQPayOrderData *)payOrderData;

/**
 已完成支付订单信息请求、解析动作

 @param payOrderData 待支付的订单数据
 */
- (void)didQueryPayOrderInfo:(KQPayOrderData *)payOrderData;

/**
 获取支付完成页banner

 @param payOrderData 支付数据
 */
- (UIView *)bannerView:(KQPayOrderData *)payOrderData;

/**
 获取支付完成页自定义的描述

 @param payOrderData 支付数据
 @return 描述
 */
- (NSString *)customDescription:(KQPayOrderData *)payOrderData;

/**
 支付结果页展示，可以定制增加一些自己的ui

 @param payOrderData 支付完成的订单数据
 @param resultView 结果页面
 @param isOpen 指纹支付是否打开
 @param isSuccess 支付是否成功
 */
- (void)payOrderData:(KQPayOrderData *)payOrderData resultViewDidAppear:(UIView *)resultView fingerPay:(BOOL)isOpen isSuccess:(BOOL)isSuccess;


/**
 支付成功，是否展示支付结果页

 @param payOrderData 支付数据
 @return 是否展示支付结果页
 */
- (BOOL)shouldShowPaySuccessView:(KQPayOrderData *)payOrderData;

@end
