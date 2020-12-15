//
//  KQBBannerManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/25.
//  Copyright © 2016年 xy. All rights reserved.
//
#import "KQBBaseOmsResManager.h"

typedef NS_ENUM(NSInteger, KQBBannerType) {
    KQBBannerTypeCredit = 104,          //飞凡贷上方banner
    KQBBannerTypeHome = 105,            //首页上方banner
    KQBBannerTypeFinancial = 106,       //理财banner
    KQBBannerTypeLife = 107,            //特惠banner
    KQBBannerTypeLoan = 108,            //信用banner
    KQBBannerTypeCreditProduct = 110,   //飞凡贷中部商品banner
    KQBBannerTypePayment = 111,         //支付首页banner
    KQBBannerTypeBindCreditCard = 112,  //实名绑卡成功(信用卡)banner
    KQBBannerTypeBindDebitCard = 113,   //实名绑卡成功(借记卡)banner
    KQBBannerTypeCreditBanner2 = 115,     //飞凡贷上方banner3.0.2版本
    KQBBannerTypeCreditScene = 116,     //飞凡贷我要花钱banner
    KQBBannerTypePaymentFinancal = 117, //理财支付结果页banner
    KQBBannerTypePaymentCoupon = 118,   //特惠支付结果页banner
    KQBBannerTypePaymentCredit = 119,   //信用支付结果页banner
    KQBBannerTypePaymentChannel = 120,  //支付频道结果页banner
    KQBBannerTypeCreditBanner = 184,  //新信贷频道首页banner
    KQBBannerTypeSwipeCardHome = 154,    //商户收款首页banner
    KQBBannerTypeSwipeCardLaXin = 173,    //拉新banner
    KQBBannerTypeKposHomeBusinessSteward = 175,    //快钱刷商管家banner
    KQBBannerTypeKposBusinessCertificationResultWithBusinessSteward = 176,    //快钱刷商管家banner
};

#define BannerNotiDic   @{ KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeCredit):@"updateCreditBanner",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeHome):@"updateHomeBanner",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeFinancial):@"updateFinancialBanner",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeLife):@"updateLifeBanner",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeLoan):@"updateLoanBanner",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeCreditProduct):@"updateKuaiyihuaProduct",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypePayment):@"updatePaymentBanner",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeBindCreditCard):@"updateBindCreditCard",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeBindDebitCard):@"updateBindDebitCard",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeCreditBanner2):@"updateCreditBanner2",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypePaymentFinancal):@"updatePaymentFinancal",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypePaymentCoupon):@"updatePaymentCoupon",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypePaymentCredit):@"updatePaymentCredit",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypePaymentChannel):@"updatePaymentChannel",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeCreditBanner):@"updateCreditBanner",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeSwipeCardLaXin):@"updateSwipeCardBPosStoresBanner",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeSwipeCardHome):@"updateSwipeCardHome",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeKposHomeBusinessSteward):@"updateSwipeCardBPosHome",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBBannerTypeKposBusinessCertificationResultWithBusinessSteward):@"updateSwipeCardBPosResultBusinessSteward",\
}


#define BannerManager  [KQBBannerManager sharedManager]

@class KQBBannerModel;

@interface KQBBannerManager : KQBBaseOmsResManager

/**
 *  获取Banner数据
 *
 *  @param bannerType : banner类型
 */
- (KQBBannerModel *)getBanner:(KQBBannerType)bannerType;

+ (KQBBannerManager *)sharedManager;
@end
