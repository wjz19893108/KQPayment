//
//  KQPayOrderData.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/24.
//
//
/*
 KQPaymentDataManager对外接口使用的数据结构
 */

#import <Foundation/Foundation.h>

/*
 支付结果
 */
typedef NS_ENUM(NSInteger, KQPayResultType)
{
    KQPayCanceled = -1,             //支付取消，取消本次支付
    KQPaySuccessful = 0,            //支付成功
    KQPayFailed = 1                 //支付失败，订单过期等
};

/*
 支付渠道
 */
typedef NS_ENUM(NSInteger, KQPayOrigin)
{
    KQPayFromJs = -1,             //js
    KQPayFromOthers = 0,            //第三方
    KQPayFromNative = 1                 //native
};

/*
 账户冻结状态
 */
typedef NS_ENUM(NSInteger, KQPayAccountFreezeState)
{
    KQPayAccountUnFreeze = 0,              //未冻结
    KQPayAccountFreezeLock = 1,            //冻结可解冻
    KQPayAccountFreezeUnLock = 2           //冻结不可解冻
};

/*
 支付前可以先确定支付方式和优惠券信息
 */
@interface KQPayMethodInfoBeforePay : NSObject

@property (nonatomic, copy, nullable) NSString *payType;              //银行卡1，账户余额2，理财账户3，信用账户4，信用卡5，mpos6，马上金服7
@property (nonatomic, copy, nullable) NSString *bankCard;             //银行卡号后4位
@property (nonatomic, copy, nullable) NSString *bankId;               //银行缩写
@property (nonatomic, copy, nullable) NSString *voucherNo;            //优惠券号码

@end

/*
 提现、充值所需额外信息
 */
@interface KQPayAdditionalInfo : NSObject

@property (nonatomic, copy, nullable) NSString *branchBank;            //开户行名称
@property (nonatomic, copy, nullable) NSString *city;                  //城市代码
@property (nonatomic, copy, nullable) NSString *province;              //省份代码
@property (nonatomic, copy, nullable) NSString *businessType;          //业务类型

@end

/*
 请求订单信息
 */
@interface KQPayOrderData : NSObject

@property (nonatomic, strong, nullable) NSString *appId;              //第三方应用编号,YQYR
@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQYR
@property (nonatomic, strong, nullable) NSString *channelType;        //渠道类型,NQYR
@property (nonatomic, strong, nullable) NSString *orderType;          //订单类型,NQYR
@property (nonatomic, strong, nullable) NSString *outTradeNo;         //外部订单号,YQYR
@property (nonatomic, strong, nullable) NSString *billOrderNo;        //内部订单号,NQNR
@property (nonatomic, strong, nullable) NSString *productCode;        //产品编号,YQ
@property (nonatomic, strong, nullable) NSString *merchantName;       //商户名称,第三方app传过来
@property (nonatomic, strong, nullable) NSString *supportFinger;      //是否支持FIDO,true/false,硬件上有,同时系统要iOS9以上,NQ
@property (nonatomic, strong, nullable) NSString *txnFlag;            //TouchID指纹校验值,NQ
@property (nonatomic, strong, nullable) NSString *orderSource;        //订单来源
@property (nonatomic, strong, nullable) NSString *siedc;              //设备指纹信息
@property (nonatomic, assign) BOOL useVoucher;                        //是否使用的优惠券，如果不使用，会提前过滤掉优惠券，0不使用，1使用
@property (nonatomic, assign) KQPayOrigin payOrigin;                  //支付来源
@property (nonatomic, assign) BOOL isShowDefaultResPage;              //是否展示默认支付结果页
@property (nonatomic, strong, nullable) NSString *pixCtrlNumber;
@property (nonatomic, assign) BOOL isUnFreeze;              //账户是否冻结
@property (nonatomic, assign) KQPayAccountFreezeState freezeState;          //账户冻结状态

@end

@interface KQPaymentDeskData : NSObject

@property (nonatomic, strong, nullable) NSString *billOrderNo;        //下单到PIX订单号（本次为支付网关协议号）
@property (nonatomic, strong, nullable) NSString *orderType;          //订单类型
@property (nonatomic, strong, nullable) NSString *orderAmt;           //订单金额
@property (nonatomic, strong, nullable) NSString *tradeOrderNo;       //显示交易单号
@property (nonatomic, strong, nullable) NSString *merchantCode;       //812商户号
@property (nonatomic, assign) BOOL hideResultPage;          //是否隐藏结果页

@end

/*
 请求订单信息
 */
@class KQPayMethod;
@interface KQPayUnNeedOrderData : NSObject
@property (nonatomic, strong, nullable) NSString *appId;              //第三方应用编号,YQYR
@property (nonatomic, strong, nullable) NSString *merchantCode;       //商户号,YQYR
@property (nonatomic, strong, nullable) NSString *channelType;        //渠道类型,NQYR
@property (nonatomic, strong, nullable) NSString *orderType;          //订单类型,NQYR
@property (nonatomic, strong, nullable) NSString *outTradeNo;         //外部订单号,YQYR
@property (nonatomic, strong, nullable) NSString *billOrderNo;        //内部订单号,NQNR
@property (nonatomic, strong, nullable) NSString *productCode;        //产品编号,YQ
@property (nonatomic, strong, nullable) NSString *merchantName;       //商户名称,第三方app传过来
@property (nonatomic, strong, nullable) NSString *supportFinger;      //是否支持FIDO,true/false,硬件上有,同时系统要iOS9以上,NQ
@property (nonatomic, strong, nullable) NSString *txnFlag;            //TouchID指纹校验值,NQ
@property (nonatomic, strong, nullable) NSString *orderSource;        //订单来源
@property (nonatomic, strong, nullable) NSString *siedc;              //设备指纹信息

@property (nonatomic, assign) BOOL unShowOrderDetail;                   //不显示订单详情 默认为No
@property (nonatomic, strong, nullable) KQPayMethod *payMethod;       //选中的支付方式
@property (nonatomic, strong, nullable) NSString *supportPayType;     //支持支付方式
@property (nonatomic, strong, nullable) NSString *orderAmount;        //订单金额
@property (nonatomic, strong, nullable) NSString *fingerStatus;       //指纹标识
@end

/*
 支付方式
 */
@interface KQPayMethod : NSObject

@property (nonatomic, strong, nullable) NSString* methodId;               //mbp返回的支付方式序号
@property (nonatomic, strong, nullable) NSString* bankCard;               //*********1234
@property (nonatomic, strong, nullable) NSString* bankName;               //建设银行什么什么卡
@property (nonatomic, strong, nullable) NSString* bankId;                 //CBC什么什么
@property (nonatomic, strong, nullable) NSString* payType;                //银行卡1，账户余额2，理财账户3，信用账户4，信用卡5，mpos6
@property (nonatomic, strong, nullable) NSString* memberBankAcctId;       //银行卡绑定ID
@property (nonatomic, strong, nullable) NSString* bindStatus;             //
@property (nonatomic, strong, nullable) NSString* phoneNo;                //电话号码
@property (nonatomic, strong, nullable) NSString* desc;                   //显示描述：什么什么卡(1234)
@property (nonatomic, strong, nullable) NSString* remainingSum;           //账户余额,cardType:1000时有效(加密)
@property (nonatomic, strong, nullable) NSString* limitInfo;              //限额(加密)
@property (nonatomic, strong, nullable) NSString* available;              //是否可用true/false
@property (nonatomic, strong, nullable) NSString* displayName;            //主要的显示名称，代替desc(加密)
@property (nonatomic, strong, nullable) NSString* limit;                  //单笔限额
@property (nonatomic, strong, nullable) NSString* icon;                   //账户理财信用所用的icon
@property (nonatomic, strong, nullable) NSString* amtLimit;               //提现银行卡限额（仅限提现）
@property (nonatomic, strong, nullable) NSString* status;                 //1:已逾期 2:已过授信有效期 (目前只针对安逸花)
@property (nonatomic, assign) BOOL isStagable;                            //支付方式是否可分期

@end

//支付出错的情况下，右边的按钮会根据情况改变
typedef NS_ENUM(NSInteger, KQPayResultErrorBtnType)
{
    KQPayResultErrorBtnTypeNormal,              //正常情况，“重新支付”
    KQPayResultErrorBtnTypeModifyPayCard,       //支付银行卡的电话错误，“修改卡信息”
    KQPayResultErrorBtnTypeUnionPayCScanB       //银联C扫B错误类型，“放弃付款”“重新付款”
};

/*
 支付结果页数据
 */
@class KQPayResultVoucherArr;
@interface KQPayResultInfo : NSObject

@property (nonatomic, copy, nonnull) NSString *merchantName;            //商户名称
@property (nonatomic, copy, nonnull) NSString *payMethod;               //付款方式
@property (nonatomic, copy, nonnull) NSString *orderType;               //订单类型
@property (nonatomic, copy, nonnull) NSString *payAmount;               //支付金额
@property (nonatomic, copy, nonnull) NSString *orderAmount;             //订单金额
@property (nonatomic, copy, nullable) NSString *payVoucherData;         //优惠信息
@property (nonatomic, copy, nullable) NSArray  *equityInfo;
@property (nonatomic, copy, nonnull) NSString *txnTimeStart;            //订单时间
@property (nonatomic, copy, nonnull) NSString *orderId;                 //内部订单号
@property (nonatomic, copy, nonnull) NSString *origOrderId;             //外部订单号
@property (nonatomic, assign) BOOL result;                              //支付成功还是失败,YES/NO
@property (nonatomic, copy, nonnull) NSString *errorInfo;               //错误信息
@property (nonatomic, assign) KQPayResultErrorBtnType errorBtnType;     //错误按钮的类型
- (NSArray *_Nullable)analyzeEquityInfoArr:(NSArray *_Nullable)arr;

@end

@interface KQPayResultVoucherArr : NSObject
@property (nonatomic, copy, nullable) NSString *payVoucherSource;             //优惠名目
@property (nonatomic, copy, nullable) NSArray  *payVoucherArr;               //优惠信息数组
- (id _Nonnull)initWithVoucherInfoArr:(NSArray *_Nonnull)arr Source:(NSString *_Nonnull)sourece;
@end

@interface KQPayResultVoucherInfo : NSObject
@property (nonatomic, copy, nullable) NSString *payVoucherTitle;             //优惠标注
@property (nonatomic, copy, nullable) NSString *payVoucherData;              //优惠数值
- (id _Nonnull)initWithVoucherInfoTitle:(NSString *_Nonnull)title Data:(NSString *_Nonnull)data;
@end
