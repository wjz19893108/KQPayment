//
//  KQBPageManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"
#import "KQBPageModel.h"

typedef NS_ENUM(NSInteger, KQBPageType) {
    KQBPageTypeOldHome = 200,           //主页老配置
    KQBPageTypeHome = 501,           //主页配置
    KQBPageTypeSwipeCardHome = 502,  //商户收款主页（用户且显示邀请好友功能）
    KQBPageTypePayment = 201,        //支付页配置
    KQBPageTypeCreditPage = 500,     //信用页面配置
    KQBPageTypeBusiness = 203,       //我的页面商户配置
    KQBPageTypeCreditRepayment = 204,//快易花还款结构配置
    KQBPageTypeCreditFailed = 205,   //快易花失败情况豆腐块配置
    KQBPageTypeSwipeCardAgentHome = 503, //商户收款主页(代理商且显示邀请好友功能)
    KQBPageTypeSwipeCardBPosHome = 504, // 大Pos主页
    KQBPageTypeSwipeCardBPosAgentHome = 505, // 大Pos主页-agent
    KQBPageTypeSwipeCardSlimmingUserHome = 506,      // 商户收款主页（用户且不显示邀请好友功能）
    KQBPageTypeSwipeCardSlimmingAgentHome = 507,     // 商户收款主页(代理商且不显示邀请好友功能)
    KQBPageTypeSwipeCardBPosStoresHome = 508,        // 大Pos多店铺主页
    KQBPageTypeSwipeCardBPosStores509 = 509,
    KQBPageTypeSwipeCardBPosHomeWithBusinessSteward = 510,             // 大Pos主页(带推广快钱刷商管家)
    KQBPageTypeSwipeCardBPosAgentHomeWithBusinessSteward = 511,        // 大Pos主页-agent(带推广快钱刷商管家)
    KQBPageTypeSwipeCardBPosStoresHomeWithBusinessSteward = 512,       // 大Pos多店铺主页(带推广快钱刷商管家)
};

#define PageDataNotiDic   @{ KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeCreditPage):@"updateCreditPageData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardHome):@"updateSwipeCardHomeData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardAgentHome):@"updateSwipeCardHomeData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardSlimmingUserHome):@"updateSwipeCardHomeData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardSlimmingAgentHome):@"updateSwipeCardHomeData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosHome):@"updateSwipeCardBPosData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosAgentHome):@"updateSwipeCardBPosAgentData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeHome):@"updateHomePage",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosStores509):@"updateSwipeCardBPosStores",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosStoresHome):@"updateSwipeCardBPosStoresData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosHomeWithBusinessSteward):@"updateSwipeCardBPosWithBusinessStewardData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosAgentHomeWithBusinessSteward):@"updateSwipeCardBPosAgentWithBusinessStewardData",\
KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosStoresHomeWithBusinessSteward):@"updateSwipeCardBPosStoresWithBusinessStewardData",\
}// 新版配置

#define PageNotiDic   @{ KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypePayment):@"updatePaymentPage",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeBusiness):@"updateBussinessPage",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeCreditRepayment):@"updateCreditRepaymentPage",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeCreditFailed):@"updateCreditFailedPage",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeCreditPage):@"updateCreditPage",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardHome):@"updateSwipeCardHome",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosHome):@"updateSwipeCardBPosHome",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosAgentHome):@"updateSwipeCardBPosAgentHome",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardAgentHome):@"updateSwipeCardHome",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardSlimmingUserHome):@"updateSwipeCardHome",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardSlimmingAgentHome):@"updateSwipeCardHome",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeOldHome):@"updateOldHomePage",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosStoresHome):@"updateSwipeCardBPosStoresHome",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosHomeWithBusinessSteward):@"updateSwipeCardBPosHomeWithBusinessSteward",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosAgentHomeWithBusinessSteward):@"updateSwipeCardBPosAgentHomeWithBusinessSteward",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBPageTypeSwipeCardBPosStoresHomeWithBusinessSteward):@"updateSwipeCardBPosStoresWithBusinessSteward"\
}

#define PageManager   [KQBPageManager sharedManager]

@class KQBBaseResModel;
@class KQBPageCard;
@protocol KQBPageManageDelegate;

@interface KQBPageManager : KQBBaseOmsResManager

@property (nonatomic, strong) NSMutableDictionary * bufferedResDic;
@property (nonatomic, assign) BOOL useDefaultPage;

/**
 *  获取Tabs数据
 *
 *  @param pageType : page类型
 */
- (KQBPageModel *)getPageBy:(KQBPageType)pageType;

+ (KQBPageManager *)sharedManager;


/**
 获取缓存区Page数据
 
 @param pageType Page类型
 @return Page数据
 */
- (KQBPageModel *)getBufferedPageBy:(KQBPageType)pageType;


/**
 存储Page数据到缓存区
 
 @param pageModel Page数据
 @param isUpdate 是否需要刷新正式数据
 @return Page数据完整状态
 */
- (KQBPageStatus)saveBufferdPageModel:(KQBPageModel *)pageModel isUpdate:(BOOL)isUpdate;


/**
 存储Page数据到正式数据区
 
 @param pageModel Page数据
 @return Page数据完整状态
 */
- (KQBPageStatus)savePageModel:(KQBPageModel *)pageModel;


/**
 部分更新Page中的Card数据
 
 @param cardObj Card对象
 @param pageType Page类型
 */
- (void)updateCardRes:(KQBPageCard *)cardObj pageId:(KQBPageType)pageType;

@end
