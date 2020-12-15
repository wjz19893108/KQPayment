//
//  KQBSodukoManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

typedef NS_ENUM(NSInteger, KQBSodukoType){
    KQBSodukoTypeLife = 101,            //特惠上方九宫格
    KQBSodukoTypePayment = 114,         //支付首页九宫格
    KQBSodukoTypeCredit = 123,          //快易花首页九宫格
    KQBSodukoTypeCreditBigger = 130,    //快易花我要花钱九宫格
    KQBSodukoTypeCreditMenu = 132,      //快易花功能九宫格
    KQBSodukoTypeHomeMenu = 136,        //首页九宫格
    KQBSodukoTypeMyInfo = 145,          //我的页面九宫格
    KQBSodukoTypeHomeLifeInfo = 146,    //首页智慧生活九宫格
    KQBSodukoTypeSwipeCardTop = 150,    //商户收款头部九宫格
    KQBSodukoTypeSwipeCardMid = 151,     //商户收款中部九宫格
    KQBSodukoTypeSwipeCardBPosHD = 158,     // 大pos 优惠活动
    KQBSodukoTypeSwipeCardBPosMenu = 159,      // 大pos 九宫格
    KQBSodukoTypeSwipeCardPriorityVIPTop = 169,      // mpos 九宫格(带vip入口  ABCD vip、刷卡收款、银联二维码、二维码收款)
    KQBSodukoTypeSwipeCardVIPTop = 170,      // mpos 九宫格（带vip入口 BACD 刷卡收款、vip、银联二维码、二维码收款）
};

typedef NS_ENUM(NSInteger, KQBSodukoOptionType){
    KQBSodukoOptionTypeSingle = 1,            //单行
    KQBSodukoOptionTypeSingleWithDot = 2,     //多行多列
    KQBSodukoOptionTypeMultiWithSpace = 3,     //单行带pageControl
    KQBSodukoOptionTypeDoubleWithDot = KQBSodukoOptionTypeMultiWithSpace,//双行带pageControl
    KQBSodukoOptionTypeSingleWithSpace = 4,   //单行上方留白
    KQBSodukoOptionTypeSingleWithDesc = 5     //单行带信息描述
};

#define SodukoNotiDic @{KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeLife):@"updateLifeSoduko",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypePayment):@"updatePaymentSoduko",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeCredit):@"updateCreditSoduko",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeCreditBigger):@"updateCreditSodukoBigger",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeCreditMenu):@"updateCreditSodukoMenu",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeHomeMenu):@"updateHomeMenu",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeMyInfo):@"updateMyInfo",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeHomeLifeInfo):@"updateHomeLifeInfo",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeSwipeCardTop):@"updateSwipeCardTop",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeSwipeCardPriorityVIPTop):@"updateSwipeCardPriorityVIPTop",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeSwipeCardVIPTop):@"updateSwipeCardVIPTop",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeSwipeCardBPosHD):@"updateSwipeCardBPosHD",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeSwipeCardBPosMenu):@"updateSwipeCardBPosMenu",\
                        KQC_FORMAT(@"%ld",(unsigned long)KQBSodukoTypeSwipeCardMid):@"updateSwipeCardMid"}

#define SodukoManager  [KQBSodukoManager sharedManager]

@class KQBSodukoModel;

@interface KQBSodukoManager : KQBBaseOmsResManager

/**
 *  获取Soduko数据
 *
 *  @param sodukoType : soduko类型
 */
- (KQBSodukoModel *)getSoduko:(KQBSodukoType)sodukoType;

+ (KQBSodukoManager *)sharedManager;

@end

