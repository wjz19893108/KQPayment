//
//  KQFunctionSwitchManager.h
//  kuaiQianbao
//
//  Created by 徐昱 on 16/2/16.
//
//
//用于管理OMS开关的管理类
#import "KQBBaseOmsResManager.h"

#define FunctionSwitchManager  [KQBFunctionSwitchManager sharedManager]

@interface KQBFunctionSwitchManager : KQBBaseOmsResManager

@property (nonatomic, strong) NSString *regProtocolIsChecked;             //注册协议是否勾选：1代表勾选
@property (nonatomic, strong) NSString *settingFloatVisible;              //我的悬浮框是否显示：1代表显示
@property (nonatomic, strong) NSString *depositBank;                      //绑卡需要添加开户行省市的银行名称
@property (nonatomic, strong) NSString *bindCardErrorCodesForAlert;       //实名接口和绑卡接口返回需要弹框提示的错误码
@property (nonatomic, strong) NSString *showIncreaseCreditTipWhenApply;   //确认授信协议页面提额Tips入口开关：1代表开启
@property (nonatomic, strong) NSString *showIncreaseCreditInMore;         //快易花更多页面提额Tips入口开关：1代表开启
@property (nonatomic, strong) NSString *partTransferVisible;              //是否显示“checkBox 允许部分转让”,1为显示
@property (nonatomic, strong) NSString *partTransferCheckedLimit;         //转让金额大于等于本参数默认勾选
@property (nonatomic, strong) NSString *upgradeRemindInterval;
@property (nonatomic, strong) NSString *upgradeRemindTimes;
@property (nonatomic, strong) NSString *professionAlertVisible;           //职业上传弹框开关
@property (nonatomic, strong) NSString *idCardAlertVisible;               //身份证上传弹框开关
@property (nonatomic, strong) NSString *promotionAfterRegister;           //注册后弹框-推广
@property (nonatomic, strong) NSString *umengStat;                        //友盟数据收集开关
@property (nonatomic, strong) NSString *kuaiqianStat;                     //自建数据收集开关
@property (nonatomic, strong) NSString *statUrl;                          //自建数据收集URL
@property (nonatomic, strong) NSString *statRCUrl;                        //自建数据收集URL,风控部分
@property (nonatomic, strong) NSString *statPolicy;                       //自建数据上传策略
@property (nonatomic, strong) NSString *statWifiOnly;
@property (nonatomic, strong) NSString *professionList;                   // 职业认证分类
@property (nonatomic, strong) NSString *professionIdList;                 //职业认证分类ID
@property (nonatomic, strong) NSString *searchVoucherDefaultAmount;       //购买定期理财首次查询权益的默认订单金额
@property (nonatomic, strong) NSString *branchInfoJsonForKLLQuick;        //开户行判断 快利来快速转出
@property (nonatomic, strong) NSString *branchInfoJsonForForCommon;       //开户行判断 快利来普通转出 提现 安全卡设置
@property (nonatomic, strong) NSString *payFinishVCJsonByOrderTypeNew;    //理财频道-保险 交易完成页不同渠道的自定义显示文案/扫一扫完成页面  3.0.0
@property (nonatomic, strong) NSString *statFirstUploadDelay;             //自建埋点启动上传时间
@property (nonatomic, strong) NSString *fingerPrintVisible;               //指纹开关
@property (nonatomic, strong) NSString *idCardAlertForceVisible;          //身份证强制上传开关
@property (nonatomic, strong) NSString *secureHostsEnabled;                //host安全功能开关
@property (nonatomic, strong) NSString *quickRolloutTime;                  //快速转出时限表

@property (nonatomic, strong) NSString *remitMinimumLimit;                  //理财-线下汇款最低限额
@property (nonatomic, strong) NSString *remitSupportBankListForIOS;         //理财-线下汇款支持银行跳转到对应AppStore下载地址
@property (nonatomic, strong) NSString *sodukoItemsPerRow;                  //九宫格列数

@property (nonatomic, strong) NSString *attractionTicketVisible;            //我的”－“景点门票“是否显示
@property (nonatomic, strong) NSString *lifeConvenienceVisible;             //“我的”－“生活便利“是否显示
@property (nonatomic, strong) NSString *digitalSignEnabled;                 //数字证书开关
@property (nonatomic, strong) NSString *apisNeedTWSign;                     //数字证书加签接口列表
@property (nonatomic, strong) NSString *inviteFriendVisible;                //邀请好友 0为关闭 1为打开    默认为0
@property (nonatomic, strong) NSString *packageFinancingVisble;             //个人中心-我的拼团入口开关 0为关闭 1为打开    默认为0
@property (nonatomic, strong) NSString *myExperienceMoneyVisible;     //我的体验金开关  0为关闭 1为打开  默认为0
@property (nonatomic, strong) NSString *anYiHuaVisible;                   //马上金服 0为关闭 1为打开 默认1
@property (nonatomic, strong) NSString *errCodesCVV2InPay;                  //统一支付返回卡片CVV2错误码
@property (nonatomic, strong) NSString *errCodesChangeCardInfoInPay;        //统一支付返回卡片手机号码错误码
@property (nonatomic, strong) NSString *errCodesSwitchPayMothedInPay;       //统一支付返回特殊的错误码
@property (nonatomic, strong) NSString *cScanBMaximumLimit;                 //C扫B静态码最大输入金额
@property (nonatomic, strong) NSString *kuaililaiPlusVisble;                //飞凡宝
//3.1.0
@property (nonatomic, strong) NSString *pEVisible;                          //私募开关 0为关闭 1为打开 默认为0
@property (nonatomic, strong) NSString *insuranceFinancingEnabled;          //保险理财开关
@property (nonatomic, strong) NSString *fundNeedWhiteList;                  //基金理财开关
@property (nonatomic, strong) NSString *defaultLoginMode;                   //登录页默认显示界面（0为密码登录 1为快捷登录 默认为0）
@property (nonatomic, strong) NSString *phoneNoJsonForBanks;                //银行电话
@property (nonatomic, strong) NSString *scanTrustList;                      //扫一扫功能可打开网页的信任列表
@property (nonatomic, strong) NSString *quickLoginVisible;                  //控制登录界面中的快捷登录是否显示，为0时，登录界面不显示快捷登录
//2.9.1
@property (nonatomic, strong) NSString *kljVisible;                                //快易花额度首页快立借入口开关

//2.9.2
@property (nonatomic, strong) NSString *transferVisible;                     //“我的”界面转账入口开关
@property (nonatomic, strong) NSString *transferToSelfEnabled;               //当开关为0时，不支持自己转账给自己。0为关闭，表示不支持，1位打开，表示支持
@property (nonatomic, strong) NSString *transferNeedWhiteList;               //转账入口是否需要白名单控制。0为关闭 1为打开    默认为1。开关关时：转账入口不需要白名单控制
@property (nonatomic, strong) NSString *associatedCardEnabeld;               // 是否显示关联卡开关
@property (nonatomic, copy) NSString *giftTextInRegisterVisible;           // 新用户进入是否显示新手礼包

// 3.0.1
@property (nonatomic, copy) NSString *iOS_Latest_Version;                   // Appstore 当前的版本号

// 3.0.2
@property (nonatomic, copy) NSString *m271ChangePayModeErrorCode;           //风控预校验接口的返回中需要弹切换支付弹窗的errorCode列表

// 3.0.2
@property (nonatomic, strong) NSString *bankCardInsuranceNeedWhiteList;       //银行卡列表下方的盗刷险入口，8月31版本只增加了白名单控制，3.0.2增加是否使用白名单控制的开关。
@property (nonatomic, strong) NSString *kyhProductShowVisible;               //快易花首页商品展示位显示开关

// 3.0.4
@property (nonatomic, strong) NSString *bannerIDForOrderTypesInPay;          //统一支付结果页增加广告banner
@property (nonatomic, strong) NSString *freeSingleSumList;                   //小额免密金额列表
@property (nonatomic, copy) NSString *mineVerionCheckVisible;                //我的-版本检测功能开关

// 框架2.0加入
@property (nonatomic, assign) BOOL keyBoardOutOfOrder;                   //键盘乱序开关

//3.1.1
@property (nonatomic, strong) NSString *showNativePaySuccessPageList;       //统一支付是否显示支付成功页

//3.1.3
@property (nonatomic, strong) NSString *hotSearchList;                  //特惠频道，热门搜索列表

// 3.1.4
@property (nonatomic, strong) NSString *withdrawVisible;                // 控制新版本中，走统一支付的新支付账户提现入口是否展示

//3.1.4
@property (nonatomic, strong) NSString *addressSearchLimit;             //转账通讯录查询是否快钱用户的每次查询条数

//3.1.5
@property (nonatomic, strong) NSString *bankStatementNumLimit;          //更换安全卡资料上传条数

//3.1.6
@property (nonatomic, strong) NSString *educationCertificationVisible;      //学历认证入口是否显示开关
@property (nonatomic, strong) NSString *driverLicenseCertificationVisible;  //驾照认证入口是否显示开关
@property (nonatomic, strong) NSString *dynamicAllocationUseDefault;       //动态配置开关

@property (nonatomic, strong) NSString *pollingNumLImit;                //B扫C轮训最大轮训次数
@property (nonatomic, strong) NSString *pollingInterval;                //B扫C轮训间隔
@property (nonatomic, strong) NSString *QRcodePayModeIncludingBalance;  //付款码页面的支付方式浮层是否展示账户余额 0为关闭 1为打开 默认为0

//3.1.7
@property (nonatomic, strong) NSString *uploadPhotoMaxSize;             //更换理财安全卡图片上传大小限制

//5.0.0
@property (nonatomic, strong) NSString *regExValidMobile;               //手机号码是否合法正则
@property (nonatomic, strong) NSString *billNameForTypes;
@property (nonatomic, strong) NSString *orderTypesForH5BillDetail;

//5.0.3
@property (nonatomic, strong) NSString *seedUpdateThreshold;            //脱机码种子更新有效期下限
@property (nonatomic, strong) NSString *syncTimeCycle;                  //同步时钟周期
@property (nonatomic, strong) NSString *faceCertificationVisible;       //驾照认证入口是否显示开关
@property (nonatomic, strong) NSString *offlineQRCodeAvailable;         //脱机码功能开关
//5.0.8
@property (nonatomic, strong) NSString *wimiUrl;                       //微米url链接

// 5.2.2
@property (nonatomic, copy) NSString *feePackageVisible;               // 0 关  1 开  默认为0

// 5.2.5
@property (nonatomic, copy) NSString *changePhoneEnter;               // 手机号码变更 0：关闭 1：打开  默认关闭

// 5.2.6
@property (nonatomic, copy) NSString *inviteShareVisible;             // 我的邀请入口 0：关闭 1：打开  默认关闭
@property (nonatomic, copy) NSString *inviteShareUrl;                 // 我的邀请入口链接地址 默认为空
@property (nonatomic, copy) NSString *dataPointDepth;                 // 埋点 默认2

// 5.2.7
@property (nonatomic, copy) NSString *riskAssessEntry;                // 风险测评入口开关 （riskAssessEntry 0 关 1 开  默认为0）
@property (nonatomic, copy) NSString *inviteShareTimes;                // 邀请好友弹窗总次数
@property (nonatomic, copy) NSString *snInputFlag;

@property (nonatomic, copy) NSString *sqBannerList;                    // 商户池银行专区

// 5.3.0
@property (nonatomic, copy) NSString *s0time;                          // S0时间段
@property (nonatomic, copy) NSString *s0Flag;                          // S0延迟险开关

// 5.3.2
@property (nonatomic, copy) NSString *businessLicenseCertificationVisible; // 营业认证开关
@property (nonatomic, copy) NSString *tradeModeVisible;                    // 交易模式切换入口开关

// 5.4.2
@property (nonatomic, copy) NSString *rateDisplayMode;                 // 费率页面展示渠道 0：native 1：H5
@property (nonatomic, copy) NSString *merchantNameVisible;             // 银二交易APP是否显示商户名称(0:不显示  1：显示)

// 5.4.3
@property (nonatomic, copy) NSString *errorCodeList;                   // 正规商户进件错误码
@property (nonatomic, copy) NSString *tradeReachUrl;                   // 多店铺管理达标返现URL
@property (nonatomic, copy) NSString *multiStoreVisible;               // 首页磁条卡鉴权入口开关 0：支持多店铺选择 1：不支持多店铺选择，一期默认为0
@property (nonatomic, copy) NSString *minAmountForDelayInsurance;      // 延迟险最低金额
@property (nonatomic, copy) NSString *delayInsuranceCacheTime;         // 延迟投保缓存时间

// 5.5.0
@property (nonatomic, copy) NSString *promotionTabVisible;             // 特惠tab开关
@property (nonatomic, copy) NSString *creditCardTabVisible;            // 办卡tab开关
@property (nonatomic, copy) NSString *certificateAmount;               // CsB 超过限额安装证书
@property (nonatomic, copy) NSString *freeLoginEnter;                  // 免密登录开关
@property (nonatomic, copy) NSString *unionPayCloudEnter;              // 银联云闪付入口
@property (nonatomic, copy) NSString *unionPayCloudUrl;                // 银联云闪付链接
@property (nonatomic, copy) NSString *agreementList;                    // 注册/验证码登录界面协议列表
// 5.5.2
@property (nonatomic, copy) NSString *imageMinLimit;          // 最小图片限制开关（单位 kb）
@property (nonatomic, copy) NSString *kqsAliWtPayEntranceConfig; // 快益刷接入微信支付宝入口(0：不展示 1：展示 默认0)


// 5.5.3
@property (nonatomic, copy) NSString *imageMaxLimit;            // 图片最大压缩比例 kb
// 5.5.4
@property (nonatomic, copy) NSString *adviertisementSwitch;     //快益刷开屏广告开关
@property (nonatomic, copy) NSString *sgjBannerVisible;         // 快钱刷商管家下载banner入口 (0 不显示  1  显示  默认不显示)控制是否显示banner入口
// 5.5.5
@property (nonatomic, copy) NSString *delayInsuranceVisible; //到账延时险控制入口

//- (void)functionSwitchStatusSetup:(NSDictionary *)response fromCache:(BOOL) isFromCache; //获取开关配置

+ (KQBFunctionSwitchManager *)sharedManager;

@end
