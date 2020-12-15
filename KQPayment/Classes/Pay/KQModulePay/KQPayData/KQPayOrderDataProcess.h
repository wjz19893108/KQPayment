//
//  KQPayOrderDataProcess.h
//  KQProcess
//
//  Created by zouf on 17/1/4.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQPayOrderData.h"
#import "KQPayViewStepDelegate.h"
#import <KQComponent/Msg.pb.h>
/*
 支付结果
 */

/*
 请求后的订单信息
 */
@interface KQPayOrderResultData : NSObject

@property (nonatomic, strong, nullable) NSString *appId;              //第三方应用编号,YQYR
@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQYR
@property (nonatomic, strong, nullable) NSString *channelType;        //渠道类型,NQYR
@property (nonatomic, strong, nullable) NSString *orderType;          //订单类型,NQYR
@property (nonatomic, strong, nullable) NSString *outTradeNo;         //外部订单号,YQYR
@property (nonatomic, strong, nullable) NSString *billOrderNo;        //内部订单号,NQNR
@property (nonatomic, strong, nullable) NSString *payMode;            //支付方式,YR,这个字段暂时不管
//@property (nonatomic, strong, nullable) NSString *resultCode;             //结果码,YR
//@property (nonatomic, strong, nullable) NSString *errorCode;              //错误码,NR
//@property (nonatomic, strong, nullable) NSString *errorInfo;              //错误信息,NR
@property (nonatomic, strong, nullable) NSString *orderStatus;            //订单状态,NR
@property (nonatomic, strong, nullable) NSString *orderAmount;            //支付金额,YR
@property (nonatomic, strong, nullable) NSString *outOrderType;           //外部订单类型,NR
@property (nonatomic, strong, nullable) NSString *outEquityCode;        //外部权益卷号,NQ
@property (nonatomic, strong, nullable) NSString *outEquityAmount;      //外部权益金额，单位分,NQ
@property (nonatomic, strong, nullable) NSString *txnTimeStart;           //订单生效日期,NR
@property (nonatomic, strong, nullable) NSString *txnTimeExpire;          //订单失效日期,NR
@property (nonatomic, strong, nullable) NSMutableArray *productInfo;      //订单中商品信息,NR
@property (nonatomic, strong, nullable) NSMutableArray *payMethod;        //支付方式列表,NR
@property (nonatomic, strong, nullable) NSString *payStatus;              //支付状态,NR
@property (nonatomic, strong, nullable) NSMutableArray *instalment;       //商城定义的分期信息列表,NR
@property (nonatomic, strong, nullable) NSMutableArray *voucher;          //权益列表,NR
@property (nonatomic, strong, nullable) NSMutableArray *activityList;     //活动列表,NR

@property (nonatomic, strong, nullable) NSString *status;                 //指纹状态,0关闭,1开通,2开通但指纹校验值变了,同M300,NR
@property (nonatomic, strong, nullable) NSString *memo;                   //备注信息
@property (nonatomic, strong, nullable) NSString *productDesc;            //商品描述,NR
@property (nonatomic, strong, nullable) NSString *subMerchantName;        //商户名称,YR
@property (nonatomic, strong, nullable) NSString *type;                   //支持的支付方式,YR,银行卡1，账户余额2，理财账户3，信用账户4，信用卡5
@property (nonatomic, strong, nullable) NSString *defaultStage;                 //默认分期
@property (nonatomic, strong, nullable) NSString *stlMerchantCode;              //结算商户号

@end

/*
 分期方式
 */
@interface KQPayInstalment : NSObject

@property (nonatomic, copy, nullable) NSString *id;               //mbp返回的分期序号
@property (nonatomic, copy, nullable) NSString *stageNumber;      //分3期...
@property (nonatomic, copy, nullable) NSString *rate;             //0.005
@property (nonatomic, copy, nullable) NSString *cost;             //300.00
@property (nonatomic, copy, nullable) NSString *repay;            //2300
@property (nonatomic, copy, nullable) NSString *total;            //6900
@property (nonatomic, copy, nullable) NSString *desc;             //描述
@property (nonatomic, copy, nullable) NSString *instalmentType;   //分期类型：4快易花、5商城信用卡
@property (nonatomic, copy, nullable) NSString *stageInfo;        //分期期数信息
@property (nonatomic, copy, nullable) NSString *feeInfo;          //分期每期应还
@property (nonatomic, copy, nullable) NSString *totalfeeInfo;     //分期总费用

@end

/*
 分期试算接口
 */
@interface KQPayStageData : NSObject

@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQ
@property (nonatomic, strong, nullable) NSString *pwid;               //pwid,YQ
@property (nonatomic, strong, nullable) NSString *orderAmount;        //订单金额,YQ
@property (nonatomic, strong, nullable) NSString *orderType;          //订单类型,YQ
@property (nonatomic, strong, nullable) NSString *payMethodId;        //支付方式ID,YQ

@end

/*
 权益信息
 */
@interface KQPayVoucher : NSObject

@property (nonatomic, copy, nullable) NSString *voucherInfo;            //YR,优惠信息,20元/8折
@property (nonatomic, copy, nullable) NSString *name;                   //YR,优惠名称,内容描述,直接展示
@property (nonatomic, copy, nullable) NSString *expDate;                //YR,失效日期,直接展示
@property (nonatomic, copy, nullable) NSString *status;                 //YR,是否可用,1可用,0不可用
@property (nonatomic, copy, nullable) NSString *voucherNo;              //YR,优惠券号码
@property (nonatomic, copy, nullable) NSString *voucherAmount;          //YR,优惠金额(加密)
@property (nonatomic, copy, nullable) NSString *payAmount;              //YR,剩余支付金额(加密)
@property (nonatomic, copy, nullable) NSArray *supportedMethodIdList;   //NR,支持的支付方式id
@property (nonatomic, assign) KQPayVoucherType voucherType;             //主动还是被动
@property (nonatomic, copy, nullable) NSString *mediaType;              //YR,优惠券类型
@property (nonatomic, copy, nullable) NSString *instruction;            //YR,优惠券说明
@property (nonatomic, assign) KQPayVoucherSourceFrom sourceFrom;       //1: 快钱权益 2:马上消费

@end

/*
 被动权益信息
 */
@interface KQPayInterested : NSObject

@property (nonatomic, copy, nullable) NSString *oid;                    //YR,业务主键
@property (nonatomic, copy, nullable) NSString *name;                   //YR,权益名称
@property (nonatomic, copy, nullable) NSString *instruction;            //NR,用户须知
@property (nonatomic, copy, nullable) NSString *supportedMethodIdList;  //NR,支付方式
@property (nonatomic, copy, nullable) NSString *discountAmount;         //NR,优惠金额
@property (nonatomic, copy, nullable) NSString *status;                 //YR,是否可用
@property (nonatomic, copy, nullable) NSString *interestInfo;           //显示信息

@end

/*
 活动信息
 */
@interface KQPayActivity : NSObject

@property (nonatomic, copy, nullable) NSString *activeId;           //活动Id
@property (nonatomic, copy, nullable) NSString *shortMsg;           //付款详情页的文案
@property (nonatomic, copy, nullable) NSString *message;            //付款列表的文案
@property (nonatomic, copy, nullable) NSArray *payType;            //活动的支付方式

@end

/*
 飞凡通支付轮询参数
 */
@interface KQQueryRequestData : NSObject
@property (nonatomic, strong, nullable) NSString *billOrderNo;        //快钱内部订单号,NQYR
@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQYR
@property (nonatomic, strong, nullable) NSString *outTradeNo;         //外部订单号,YQYR
@property (nonatomic, strong, nullable) NSString *payMethodId;        //支付方式ID,YQ
@property (nonatomic, strong, nullable) NSString *tradeId;            //当businessType=1时，必填，代表支付订单号，对应idBizCtrl
@property (nonatomic, strong, nullable) NSString *businessType;       //businessType=1时，代表Applepay的结果轮询；businessType=2时，代表其他订单结果轮询
@end

/*
 请求支付后的信息
 */
@interface KQPaymentResultData : NSObject

@property (nonatomic, strong, nullable) NSString *appId;              //第三方应用编号,YQYR
@property (nonatomic, strong, nullable) NSString *billOrderNo;        //快钱内部订单号,NQYR
@property (nonatomic, strong, nullable) NSString *orderAmount;        //订单总金额,YQR
@property (nonatomic, strong, nullable) NSString *payAmount;          //支付总金额,YQR
@property (nonatomic, strong, nullable) NSString *resultCode;         //结果码,YR
@property (nonatomic, strong, nullable) NSString *errorCode;          //错误码,NR
@property (nonatomic, strong, nullable) NSString *errorInfo;          //错误信息,NR
@property (nonatomic, strong, nullable) NSString *orderStatus;        //订单状态,NR
@property (nonatomic, strong, nullable) NSString *tradeId;            //快钱流水号,NR
@property (nonatomic, strong, nullable) NSString *txnEndTime;         //支付完成时间,YR
@property (nonatomic, strong, nullable) NSString *equityAmount;       //内部权益金额,NQR

//2018-01-10 版本，轮询支付结果，新增参数——PK
@property (nonatomic, strong, nullable) NSString *amt;                //交易金额，当businessType=1时，返回
@property (nonatomic, strong, nullable) NSString *bankAcctName;       //银行名称
@property (nonatomic, strong, nullable) NSString *channelType;        //渠道类型
@property (nonatomic, strong, nullable) NSString *currencyCode;       //币种
@property (nonatomic, strong, nullable) NSString *equityDesc;         //内部权益描述
@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号
@property (nonatomic, strong, nullable) NSString *orderType;          //订单类型

@property (nonatomic, strong, nullable) NSString *outEquityAmount;    //外部权益金额
@property (nonatomic, strong, nullable) NSString *outOrderType;       //外部订单类型
@property (nonatomic, strong, nullable) NSString *payInfo;            //支付信息
@property (nonatomic, strong, nullable) NSString *payMode;            //支付方式
@property (nonatomic, strong, nullable) NSString *payStatus;          //支付状态
@property (nonatomic, strong, nullable) NSString *queryInterval;      //查询间隔
@property (nonatomic, strong, nullable) NSString *queryTimes;         //查询次数
@property (nonatomic, strong, nullable) NSString *subMerchantName;    //子商户名称
@property (nonatomic, strong, nullable) NSString *tradeStatus;        //交易状态
@property (nonatomic, strong, nullable) NSString *txnTimeStart;       //交易开始时间

@end

/*
 风控合规限额预判请求
 */
@interface KQPayRiskData : NSObject

@property (nonatomic, strong, nullable) NSString *outTradeNo;       //外部订单号,YQ
@property (nonatomic, strong, nullable) NSString *channelType;      //渠道类型,YQ
@property (nonatomic, strong, nullable) NSString *payAmount;          //支付总金额,YQ
@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQ
@property (nonatomic, strong, nullable) NSString *validateElement;    //验证要素,NQ
@property (nonatomic, strong, nullable) NSString *sysVersion;         //新老版本标记,YQ
@property (nonatomic, strong, nullable) NSString *payMethodId;        //与mbp保持一致的支付方式索引号,YQ
@property (nonatomic, strong, nullable) NSString *orderType;

@end

/*
 统一收单的短信验证接口请求
 */
@interface KQPaySmsData : NSObject

@property (nonatomic, strong, nullable) NSString *appId;              //第三方应用编号,YQ
@property (nonatomic, strong, nullable) NSString *phone;              //短信手机号,YQ
@property (nonatomic, strong, nullable) NSString *outTradeNo;         //外部订单号,YQ
@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQ

@end

/*
 请求支付信息
 */
@interface KQPaymentData : NSObject

@property (nonatomic, strong, nullable) NSString *appId;              //第三方应用编号,YQYR
@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQ
@property (nonatomic, strong, nullable) NSString *billOrderNo;        //快钱内部订单号,NQYR
@property (nonatomic, strong, nullable) NSString *outTradeNo;         //外部订单号,YQ
@property (nonatomic, strong, nullable) NSString *channelType;        //渠道类型,YQ
@property (nonatomic, strong, nullable) NSString *orderAmount;        //订单总金额,YQ
@property (nonatomic, strong, nullable) NSString *payAmount;          //支付总金额,YQ
@property (nonatomic, strong, nullable) NSString *payPassword;        //加密后的支付密码,YQ
@property (nonatomic, strong, nullable) NSString *authCode;           //二维码支付时的二维码编码,NQ
@property (nonatomic, strong, nullable) NSString *outEquityCode;      //外部权益卷号,NQ
@property (nonatomic, strong, nullable) NSString *outEquityAmount;    //外部权益金额,NQ
@property (nonatomic, strong, nullable) NSString *payMethodId;        //与mbp保持一致的支付方式索引号,YQ
@property (nonatomic, strong, nullable) NSString *instalmentId;       //商城定义分期选项，id为MBP分配，在订单查询流程中返回,NQ
@property (nonatomic, strong, nullable) NSString *sMsCode;            //短信验证码,NQ
@property (nonatomic, strong, nullable) NSString *equityCode;         //内部部权益卷号,NQ
@property (nonatomic, strong, nullable) NSString *equityAmount;       //内部权益金额,NQ
@property (nonatomic, strong, nullable) NSString *token;              //指纹支付令牌,NQ
@property (nonatomic, strong, nullable) NSString *txnFlag;            //指纹校验值,NQ
@property (nonatomic, strong, nullable) NSString *notifyMode;         //通知模式,NQ 飞凡SDK：4
@property (nonatomic, strong, nullable) NSString *orderType;          //订单类型,NQ
@property (nonatomic, strong, nullable) NSString *branchBank;         //开户行名称,NQ
@property (nonatomic, strong, nullable) NSString *province;           //省份代码,NQ
@property (nonatomic, strong, nullable) NSString *city;               //城市代码,NQ
@property (nonatomic, strong, nullable) NSString *businessType;       //业务类型,NQ
@property (nonatomic, strong, nullable) NSString *stageCount;          //分期数,NQ
@property (nonatomic, strong, nullable) NSString *feeRate;             //费率,NQ
@property (nonatomic, strong, nullable) NSMutableArray *equityInfo;                 //!< 银联权益 用于解析数据用
@property (nonatomic, strong, nullable) NSString *stlMerchantCode;              //结算商户号

@end

/*
 轮询支付结果信息
 */
@interface KQQueryPayResultData : NSObject

@property (nonatomic, strong, nullable) NSString *queryTimes;              //轮询次数,YQYR
@property (nonatomic, strong, nullable) NSString *queryInterval;              //轮询间隔,YQYR

@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQYR
@property (nonatomic, strong, nullable) NSString *billOrderNo;        //快钱内部订单号,NQYR
@property (nonatomic, strong, nullable) NSString *outTradeNo;         //快钱外部订单号,NQYR ADD
@property (nonatomic, strong, nullable) NSString *channelType;         //快钱外部订单号,NQYR ADD
@property (nonatomic, strong, nullable) NSString *orderType;        //订单类型,YQR
@property (nonatomic, strong, nullable) NSString *currencyCode;        //币种,YQR
@property (nonatomic, strong, nullable) NSString *payMode;        //支付方式,YQR

@property (nonatomic, strong, nullable) NSString *orderAmount;        //订单总金额,YQR
@property (nonatomic, strong, nullable) NSString *payAmount;          //支付总金额,YQR

@property (nonatomic, strong, nullable) NSString *outOrderType;          //外部订单类型,NR
@property (nonatomic, strong, nullable) NSString *subMerchantName;          //子商户名称,NR
@property (nonatomic, strong, nullable) NSString *equityCode;          //内部权益券号,NR
@property (nonatomic, strong, nullable) NSString *equityAmount;          //内部权益金额,NR
@property (nonatomic, strong, nullable) NSString *equityDesc;          //内部权描述益,NR
@property (nonatomic, strong, nullable) NSString *outEquityAmount;          //外部权益金额,NR
@property (nonatomic, strong, nullable) NSString *orderStatus;          //订单状态,NR

@property (nonatomic, strong, nullable) NSString *errorCode;          //错误码,NR
@property (nonatomic, strong, nullable) NSString *errorInfo;          //错误信息,NR
@property (nonatomic, strong, nullable) NSString *payStatus;          //支付状态,NR ADD

@property (nonatomic, strong, nullable) NSString *txnStartTime;         //支付开始时间,YR ADD
@property (nonatomic, strong, nullable) NSString *txnEndTime;         //支付完成时间,YR

@end

/*
 对数据结构的所有业务操作
 */
@interface KQPayOrderDataProcess : NSObject

/*
 返回订单查询结果数据结果，包括支付方式、优惠券、分期方式、金额等
 */
+ (KQPayOrderResultData * __nullable)getPayOrderResultDataFromObj:(Content* __nonnull)response;

/*
 查风控所需的数据结构
 */
+ (KQPayRiskData * __nullable)getPayRiskDataFromObj:(KQPayOrderResultData* __nonnull)obj;

/*
 获取验证短信所需的数据结构
 */
+ (KQPaySmsData * __nullable)getPaySmsDataFromObj:(KQPayOrderResultData* __nonnull)obj;

/*
 获取验证短信所需的数据结构 无下单情况
 */
+ (KQPaySmsData * __nullable)getUnNeedPaySmsDataFromObj:(KQPayUnNeedOrderData* __nonnull)obj;


/*
 支付所需的数据结构
 */
+ (KQPaymentData * __nullable)getPaymentDataFromObj:(KQPayOrderResultData* __nonnull)obj;

/*
 无下单 支付所需的数据结构
 */
+ (KQPaymentData * __nullable)getUnNeedOrderPaymentDataFromObj:(KQPayUnNeedOrderData* __nonnull)obj;

/*
 返回支付结果数据结构
 */
+ (KQPaymentResultData * __nullable)getPaymentResultDataFromObj:(Content* __nonnull)obj;
+ (KQPaymentResultData * __nullable)getUnNeedOrderPaymentResultDataFromObj:(Content* __nonnull)obj;
+ (KQPayRiskData * __nullable)getPayRiskDataFromUnNeedOrder:(KQPayUnNeedOrderData* __nonnull)obj;
+ (NSArray * __nullable)getPayStageDataFromObj:(Content* __nonnull)response;
+ (NSString * __nullable)getPayDefaultStageFromObj:(Content* __nonnull)response;

/*
 根据返回的订单结果信息填充订单数据结构，支付完成后会用
 */
+ (void)fillPayOrderDataByPayOrderResultData:(KQPayOrderData * __nonnull)payOrderData payOrderResultData:(KQPayOrderResultData * __nonnull)payOrderResultData;

+ (NSDictionary * __nullable)getM251Dic:(KQPayOrderData * __nonnull)payOrderData;

+ (NSDictionary* __nullable)getM271Dic:(KQPayRiskData * __nonnull)payRiskData;

+ (NSDictionary* __nullable)getM270Dic:(KQPaySmsData * __nonnull)paySmsData;

+ (NSDictionary* __nullable)getUnNeedOrderM270Dic:(KQPaySmsData * __nonnull)paySmsData;

+ (NSDictionary* __nullable)getM250Dic:(KQPaymentData * __nonnull)paymentData;

+ (NSDictionary* __nullable)getM341Dic:(KQPaymentData * __nonnull)paymentData;

+ (NSString * __nonnull)stringNilIfTxnFlagIsEmpty:(NSString * __nullable)txnFlag;

@end
