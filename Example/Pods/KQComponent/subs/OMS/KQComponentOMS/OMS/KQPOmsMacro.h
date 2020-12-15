//
//  KQBOmsMacro.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/8.
//  Copyright © 2016年 xy. All rights reserved.
//

#ifndef KQBOmsMacro_h
#define KQBOmsMacro_h

typedef NS_ENUM(int, KQOmsResType) {
    KQOmsResTypeLifeSoduko = 101,        //特惠上方九宫格
    KQOmsResTypeCreditBanner = 104,      //快易花上方banner
    KQOmsResTypeHomeBanner = 105,        //首页上方banner
    KQOmsResTypeFinancialBanner = 106,   //理财banner
    KQOmsResTypeLifeBanner = 107,        //特惠banner
    KQOmsResTypeLoanBanner = 108,        //信用banner
    KQOmsResTypeAdvPage = 109,           //开机广告页
    KQOmsResTypeCreditProduct = 110,     //快易花中部商品
    KQOmsResTypePaymentBanner = 111,     //支付首页banner
    KQOmsResTypeBindCreditCard = 112,    //实名绑卡成功(信用卡)
    KQOmsResTypeBindDebitCard = 113,     //实名绑卡成功(借记卡)
    KQOmsResTypePaymentSoduko = 114,     //支付首页九宫格
    KQOmsResTypeCreditBanner2 = 115,     //快易花上方banner3.0.2版本
    KQOmsResTypeCreditScene = 116,       //快易花我要花钱
    KQOmsResTypePaymentFinancal = 117,   //理财支付结果页
    KQOmsResTypePaymentCoupon = 118,     //特惠支付结果页
    KQOmsResTypePaymentCredit = 119,     //信用支付结果页
    KQOmsResTypePaymentChannel = 120,    //支付频道结果页
    KQOmsResTypeCreditSoduko = 123,      //快易花九宫格
    KQOmsResTypeHomeAdvertise = 190,     //开通快易花用户弹首页广告
    KQOmsResTypeHomePage = 200,          //APP首页
    KQOmsResTypePaymentPage = 201,       //APP支付首页
    KQOmsResTypeCreditPage = 202,        //APP信用首页
    KQOmsResTypeDescription = 301,       //文案配置
    KQOmsResTypeFunctionSwitch = 302,    //功能开关
    KQOmsResTypeH5PublicRes = 303,       //公共资源配置
    KQOmsResTypeCityList = 304,          //城市信息
    KQOmsResTypeTabbarRes = 400,         //Tab Bar 配置
    KQOmsResTypeOthers = 999             //其他图片
};

typedef NS_ENUM(int, KQOmsResStatus) {
    KQOmsResStatusDownloadFailed = 0,        //下载失败
    KQOmsResStatusUnzipeFailed,              //解压失败
    KQOmsResStatusComplete,                  //下载解压成功
    KQOmsResStatusDownloading,               //下载中
    KQOmsResStatusNoStart                    //未开始
};

typedef NS_ENUM(int, KQOmsType) {
    KQOmsTypeBanner = 1,
    KQOmsTypeStartupPage = 2,
    KQOmsTypeSoduko = 3,
    KQOmsTypeOldPage = 4,
    KQOmsTypeTab = 5,
    KQOmsTypeImage = 6,
    KQOmsTypeDescription = 7,
    KQOmsTypeFunctionSwitch = 8,
    KQOmsTypeH5Resource = 9,
    KQOmsTypeMatrix = 11,
    KQOmsTypePageHeader = 13,
    KQOmsTypeCreditProduct = 14,
    KQOmsTypeDynamicPage = 16,
    KQOmsTypeDynamicCard = 17,
    KQOmsTypeCityList = 18
};

typedef void(^DownloadSuccessBlock)(void);
typedef void(^DownloadFailedBlock)(NSInteger resStatus);

#define kBannerDuration 3   //banner切换间隔时间
#define Oms264Res @"M264"
#define Oms255Res @"M255"

#endif /* KQBOmsMacro_h */
