//
//  KQPayViewStepDelegate.h
//  KQProcess
//
//  Created by zouf on 17/1/4.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQPayVoucherType)
{
    KQPayVoucherTypeActive = 1,             //主动权益
    KQPayVoucherTypePassive = 2,            //被动权益
};

typedef NS_ENUM(NSInteger, KQPayVoucherSourceFrom)
{
    KQPayVoucherFromVAS = 1,             //VAS优惠券
    KQPayVoucherFromMSXF = 2,            //马上优惠券
    KQPayUnuseVoucher = 3,               //马上支付方式 没使用优惠券
    KQPayVoucherFromNone = 4,            //非马上支付方式
};

/*
 支付到了哪一个步骤
 */
typedef NS_ENUM(NSInteger, KQPayViewStep)
{
    KQPayViewStepDetail,            //支付首页
    KQPayViewStepMode,              //支付方式
    KQPayViewStepInstallment,       //分期方式
    KQPayViewStepNoneVoucher,       //没有优惠券
    KQPayViewStepVoucher,           //相关优惠券
    KQPayViewStepAllVoucher,        //所有优惠券
    KQPayViewStepPassword,          //支付密码
    KQPayViewStepSms,               //短信验证
    KQPayViewStepCvv2,              //信用卡cvv2错误
    KQPayViewStepResult             //支付结果页
};

/*
 现在走到哪一步了
 */
@protocol KQPayViewStepDelegate <NSObject>

@optional
- (UIView * __nullable)payViewStepShowWhich:(KQPayViewStep)viewStep;

@end


/*
 每个页面都要有的协议
 */
@protocol KQPayViewStepBaseDelegate <NSObject>

/*
 点了左上角返回或叉叉
 */
- (void)back:(KQPayViewStep)viewStep;

/*
 本次支付是否能绑卡片
 */
- (BOOL)canBindCard;

@end


/*
 支付详情页需要显示的内容
 */
typedef NS_ENUM(NSInteger, KQPayDetailInfoType)
{
    KQPayDetailInfoTypeMerchantName,        //订单信息
    KQPayDetailInfoTypeAccountName,         //账户信息
    KQPayDetailInfoTypePaymentMode,         //付款方式
    KQPayDetailInfoTypeInstallmentMode,     //分期方式
    KQPayDetailInfoTypeVoucher,             //优惠券
    KQPayDetailInfoTypeUPayVoucher,         //银联优惠
    KQPayDetailInfoTypeRemark,              //备注
    KQPayDetailInfoTypeOrderAmount,         //付款额度
    KQPayDetailInfoTypeExtendOne,           //扩展字段一
    KQPayDetailInfoTypeExtendTwo            //扩展字段二
};

/*
 确定支付需要显示的内容
 */
typedef NS_ENUM(NSInteger, KQPayDetailLoadingType)
{
    KQPayDetailLoadingTypeStart,              //支付开始
    KQPayDetailLoadingTypeSuccess,            //支付成功
    KQPayDetailLoadingTypeFailed,             //支付失败
    KQPayDetailLoadingTypeClose               //关闭loading
};

/*
 由支付详情页、密码页、验证码页实现，不同的步骤显示不同的loading类型
 */
@protocol KQPayDetailLoadingTypeDelegate <NSObject>

/**
 由界面实现loading动效

 @param loadingType loading类型
 */
- (void)payDetailLoadingType:(KQPayDetailLoadingType)loadingType;

@end

/*
 支付详情页要调用的协议
 */
@protocol KQPayViewStepDetailDelegate <KQPayViewStepBaseDelegate>

/*
 是否是内部App调用
 */
- (BOOL)isInAppCall;

/*
 获取对应栏目信息
 */
- (void)getColumnInfo:(KQPayDetailInfoType)infoType resultBlock:(void(^__nullable)(NSString * __nullable info, BOOL canSelected, NSString * __nullable activityMsg, BOOL hasActivity))resultBlock;

/*
 选择了对应栏目
 */
- (void)selectColumn:(KQPayDetailInfoType)infoType;

/*
 可用的优惠券数量
 */
- (NSUInteger)vouchersCount;

/*
 全部优惠券数量
 */
- (NSUInteger)allVouchersCount;

/*
 是否有分期数据
 */
- (BOOL)hasInstalmentInfo;

/*
 返回当前支付商品的productCode
 */
- (NSString * __nullable)getCurrentProductCode;

/*
 是否使用优惠券
 */
- (BOOL)canUseVoucher;

/*
 是否使用银联优惠权益
 */
- (BOOL)canUserUPayVoucher;

/*
 确定支付
 */
- (void)confirmPayment:(id<KQPayDetailLoadingTypeDelegate> __nullable)loadingTypeDelegate;

/*
 是否请求分期数据
 */
- (void)needRequestInstalmentInfo:(void(^__nullable)(void))resultBlock;


@end

/*
 支付选择页要调用的协议
 */
@protocol KQPayViewStepModeDelegate <KQPayViewStepBaseDelegate>

/*
 返回当前可用支付方式数目
 */
- (NSUInteger)payMethodCount;

/*
 返回当前不可用支付方式数目
 */
- (NSUInteger)payMethodDisabledCount;

/*
 返回可用支付方式信息
 */
- (void)payMethodInfo:(NSUInteger)index resultBlock:(void(^__nullable)(NSString * __nullable payType, NSString * __nullable bankId, NSString * __nullable displayName, NSString * __nullable limitInfo, NSString * __nullable icon, BOOL selected, BOOL showIcon, NSString * __nullable activityMsg))resultBlock;

/*
 返回当前的支付方式是否隐藏
 */
- (BOOL)payMethodShouldHide:(NSUInteger)index;

/*
 选择支付方式
 */
- (void)selectPayMethod:(NSUInteger)index;

/*
 添加新卡
 */
- (void)addNewCard;

@end

/*
 分期方式选择页要调用的协议
 */
@protocol KQPayViewStepInstallmentDelegate <KQPayViewStepBaseDelegate>

/*
 返回当前分期方式
 */
- (NSUInteger)installmentCount;

/*
 返回分期方式信息
 */
- (void)installmentInfo:(NSUInteger)index resultBlock:(void(^__nullable)(NSString * __nullable rate, NSString * __nullable cost, NSString * __nullable total, BOOL selected))resultBlock;

/*
 选择分期方式
 */
- (void)selectInstallment:(NSUInteger)index;

@optional
/*
 查询单期试算金额
 */
- (void)trialAmt:(void(^__nullable)(void))finish;

/*
 获取原订单金额
 */
- (NSString *__nullable)orderAmt;

/*
 是否是安逸花订单
 */
- (NSString * __nullable)anYiHuaPayStatus;
/*
 安逸花 优惠券类型
 */
- (KQPayVoucherSourceFrom)maShangVoucherFrom;

/*
 试算总金额 划线
 */
- (NSString * __nullable)orderTrialTotalAmt;

/*
 试算总金额
 */
- (NSString * __nullable)orderTrialAmt;

/*
 试算优惠
 */
- (NSString * __nullable)orderTrialRipAmt;
 
/*
 返回分期方式信息
 */
- (void)installmentInfos:(NSString * __nullable)index resultBlock:(void(^__nullable)(NSArray * __nullable installments, NSString * __nullable defaultInstallment, BOOL selectedMaShang))resultBlock;

/*
 选择分期方式
 */
- (void)selectInstallment:(NSUInteger)index popFlag:(BOOL)popFlag;

/**
 马上金服
 */
- (void)maShangCell:(NSUInteger)index resultBlock:(void(^__nullable)(BOOL maShang))resultBlock;

@end

/*
 优惠券选择页和所有优惠券要调用的协议
 */
@protocol KQPayViewStepVoucherDelegate <KQPayViewStepBaseDelegate>

/*
 返回可用优惠券数量
 */
- (NSUInteger)voucherEnableCount;

/*
 返回不可用优惠券数量
 */
- (NSUInteger)voucherDisableCount;

/*
 返回优惠券信息，可用与不可用的
 */
- (void)voucherInfo:(NSUInteger)index resultBlock:(void(^__nullable)(NSString * __nullable voucherInfo, NSString * __nullable name, NSString * __nullable expDate, KQPayVoucherType payVoucherType, BOOL enable, BOOL selected, KQPayVoucherSourceFrom sourceFrom))resultBlock;

/*
 选择优惠券
 */
- (void)selectVoucher:(NSUInteger)index;

@end

/*
 所有优惠券页要调用的协议
 */
@protocol KQPayViewStepAllVoucherDelegate <KQPayViewStepBaseDelegate>

/*
 返回所有优惠券数量
 */
- (NSUInteger)voucherAllCount;

/*
 返回优惠券信息，所有的
 */
- (void)allVoucherInfo:(NSUInteger)index resultBlock:(void(^__nullable)(NSString * __nullable voucherInfo, NSString * __nullable name, NSString * __nullable expDate, KQPayVoucherType payVoucherType, BOOL enable, BOOL selected, KQPayVoucherSourceFrom sourceFrom))resultBlock;

@end

/*
 没有对应优惠券页要调用的协议
 */
@protocol KQPayViewStepNoneVoucherDelegate <KQPayViewStepBaseDelegate>

/*
 显示所有优惠券页
 */
- (void)otherVouchers;

@end

/*
 支付密码输入页要调用的协议
 */
@protocol KQPayViewStepPasswordDelegate <KQPayViewStepBaseDelegate>

/*
 输入支付密码
 */
- (void)inputPayPassword:(NSString * __nullable)password loadingTypeDelegate:(id<KQPayDetailLoadingTypeDelegate> __nullable)loadingTypeDelegate;

/*
 忘记支付密码
 */
- (void)forgetPayPassword;

@end

/*
 验证码输入页要调用的协议
 */
@protocol KQPayViewStepSmsDelegate <KQPayViewStepBaseDelegate>

/*
 获取验证码
 */
- (void)getPaySms:(void(^__nullable)(void))finish;

/*
 输入验证码
 */
- (void)inputSms:(NSString * __nullable)sms loadingTypeDelegate:(id<KQPayDetailLoadingTypeDelegate> __nullable)loadingTypeDelegate;

@end

/*
 cvv2修改页要调用的协议
 */
@protocol KQPayViewStepCvv2Delegate <KQPayViewStepBaseDelegate>

/*
 输入cvv2
 */
- (void)inputCvv2:(NSString * __nullable)cvv2;

@end

/*
 完成页要调用的协议
 */
@protocol KQPayViewStepResultDelegate <KQPayViewStepBaseDelegate>

/*
 自定义描述
 */
- (NSString * __nullable)customDescription;

/*
 bannerView
 */
- (UIView * __nullable)bannerView;

/*
 显示时要做的事
 */
- (void)resultViewDidAppear:(UIView * __nullable)resultView isSuccess:(BOOL)isSuccess;

/*
 修改卡信息
 */
- (void)modifyCardInfo;

/*
 重新支付
 */
- (void)rePay;

/// 订单信息展示
- (BOOL)orderInformationShow;
@end
