//
//  KQBHttpMacro.h
//  KQBusiness
//
//  Created by xy on 2016/11/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#ifndef KQHttpMacro_h
#define KQHttpMacro_h

// 等待框显示模式
typedef NS_ENUM(NSInteger, KQHttpServiceWaitingViewMode) {
    KQHttpServiceWaitingViewModeNotShow = 0, // 不显示
    KQHttpServiceWaitingViewModeShow = 1,      // 显示, default
    KQHttpServiceWaitingViewModeShowShort = 2,     // 显示短loading，露出tabbar
    KQHttpServiceWaitingViewModeShowTop = 3,    // 显示出只露出返回按钮的全屏loading
};

// 网络请求取消的模式
typedef NS_ENUM(NSInteger, KQHttpServiceCancelMode) {
    KQHttpServiceCancelRequsetWithBizeTypeMode = 0,     //!< 根据bizeType取消对应的网络请求
    KQHttpServiceCancelRequsetMode = 1,                 //!< 取消掉canCancel=YES的网络请求
    KQHttpServiceCancelAllRequsetWithOutUpLoadMode = 2, //!< 取消掉除了上传文件以外的所有的网络请求
    KQHttpServiceCancelAllRequsetMode = 3,              //!< 取消掉所有的网络请求
};

typedef NS_ENUM(NSInteger, KQHttpServiceType) {
    KQHttpServiceTypeGateway = 0, // 网关服务
    KQHttpServiceTypeUpload,       // 文件上传
};

#pragma mark - 刷卡相关
typedef NS_ENUM(NSInteger, KQSwipeCardHttpServiceType) {
    KQSwipeCardHttpServiceTypeMainService = 0, // 刷卡相关的主服务
    KQHttpCardHttpServiceTypeUpload,       // 文件上传
};


#define kNetWorkErrorLoginTokenOutDateKey   @"R56"
#define kNetWorkErrorLoginTokenInvaildKey   @"R57"
#define kNetWorkErrorNeedUpdateUserInfoKey  @"R59"
#define kNetWorkErrorLoginTokenErrorKey     @"R60"
#define kNetWorkErrorNeedLoginKey           @"R63"
#define kNetWorkErrorTimeOutOfRangeKey      @"R64"
#define kNetWorkErrorAccountRiskKey         @"R65"


//// APP版本
//#define KQBAppVersion KQC_FORMAT(@"MP_IOS_APP_KQB_99bill_%@_1605071415_01", [KQCApplication version])
//
//#define KQBServerVersion  @"4.6"

//需要用户行为节点上送设备信息
#define kExtMapInfoBizTypeArray     @[@"M269",@"M071",@"M103",@"M008",@"M233",@"M321",@"M320",@"M143",@"M341",@"M271",@"M250"]
// 需要用户行为节点上送X项目C扫B交易标识
#define kSwipeCardExtMapInfoBizTypeArray @[@"M271", @"M340", @"M341"]

// 需要加密的字段
#define kSensitiveWordsArray @[@"mebCode",@"userName",@"password",@"payPassword",@"pan",@"id",@"cvv2",@"phoneNo",@"amt",@"orderId",@"productName",@"email",@"balance",@"creditCardPan",@"securityAnswer",@"totalAmt",@"totalFee",@"tradeId",@"txnAcctNo",@"interest",@"idCardNo",@"ripAmount",@"orderAmount",@"payAmount",@"idCardNo",@"contactInfo",@"equityAmount",@"expireDate",@"repayId",@"loginPin",@"newLoginPin",@"payPwd",@"newPayPwd",@"payType",@"pin"];

#endif /* KQBHttpMacro_h */
