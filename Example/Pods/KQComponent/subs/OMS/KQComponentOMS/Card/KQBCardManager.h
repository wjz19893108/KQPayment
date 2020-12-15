//
//  KQBCardManager.h
//  KQBusiness
//
//  Created by pengkang on 2017/6/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

typedef NS_ENUM(NSInteger, KQBCardMType){
    KQBCardMTypeCredit = 800,
    // 我的->理财
    KQBCardMTypeFinanceFirst = 802,
    KQBCardMTypeFinanceSecond = 803,
    KQBCardMTypeFinanceThird = 804,
    // 我的->信用
    KQBCardMTypeMineCreditFirst = 810,
    KQBCardMTypeMineCreditSecond = 811,
    KQBCardMTypeMineCreditThird = 812,
    KQBCardMTypeMineCreditFourth = 813,
    // 我的->综合
    KQBCardMTypeMineCompositeFirst = 820,
    KQBCardMTypeMineCompositeSecond = 821,
    // 我的->商户
    KQBCardMTypeMineMerchantFirst = 801,
    KQBCardMTypeMineMerchantSecond = 830,
    KQBCardMTypeMineMerchantThird = 831,
};

@class KQBCardModel;

#define MultiCardNotiDic   @{ KQC_FORMAT(@"%ld",(unsigned long)KQBCardMTypeCredit):@"updateCreditCardCell",\
                         KQC_FORMAT(@"%ld",(unsigned long)KQBCardMTypeMineMerchantFirst):@"updateMyCardCell"}

#define MultiCardManager [KQBCardManager sharedManager]

@interface KQBCardManager : KQBBaseOmsResManager

+ (KQBCardManager *)sharedManager;

- (KQBCardModel *)getCard:(KQBCardMType)cardType;

@end
