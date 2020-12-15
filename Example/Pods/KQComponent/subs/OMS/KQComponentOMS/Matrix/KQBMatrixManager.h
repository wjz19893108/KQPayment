//
//  KQBMatrixManager.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

#define MatrixManager [KQBMatrixManager sharedManager]

typedef NS_ENUM(NSInteger, KQBMatrixType){
    KQBMatrixTypeCredit = 131,
    KQBMatrixTypeCreditHelp = 133,
    KQBMatrixTypeCreditLogo = 134,
    KQBMatrixTypeNetworkBroken = 135,
    KQBMatrixTypeHomeCredit = 137,
    KQBMatrixTypeHomeFinance = 138,
    KQBMatrixTypeHomePayment = 139,
    KQBMatrixTypeHomeTehui = 140,
    KQBMatrixTypeHomeInsurance = 141,
    KQBMatrixTypeHomeDecade = 142,
    KQBMatrixTypeHomeBottom = 143,
    KQBMatrixTypeCreditMedical = 144,
    KQBMatrixTypeHomeAdvertise = 190, // 开通快易花用户首页弹框
    KQBMatrixTypeSwipeCardTop = 153,
    KQBMatrixTypeSwipeCardBot = 156,
    KQBMatrixTypeSwipeCardAgentsCashBack = 157,  // X业务套餐返现给服务商展示Card
    KQBMatrixTypeSwipeCardNotice = 174,
};

//#define MatrixNotiDic   @{  KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeCredit):@"updateCreditMatrix",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeCreditHelp):@"updateCreditHelp",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeCreditLogo):@"updateCreditLogo",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeNetworkBroken):@"updateNetworkBroken",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeHomeCredit):@"updateHomeCredit",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeHomeFinance):@"updateHomeFinance",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeHomePayment):@"updateHomePayment",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeHomeTehui):@"updateHomeTehui",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeHomeInsurance):@"updateHomeInsurance",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeHomeDecade):@"updateHomeDecade",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeHomeDecade):@"updateCreditMedical",\
//                            KQC_FORMAT(@"%ld",(unsigned long)KQBMatrixTypeHomeBottom):@"updateHomeBottom"\
//}

@class KQBMatrixModel;

@interface KQBMatrixManager : KQBBaseOmsResManager

- (KQBMatrixModel *)getMatrix:(KQBMatrixType)matrixType;

+ (KQBMatrixManager *)sharedManager;

@end
