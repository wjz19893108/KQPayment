//
//  KQBCreditProductManager.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

typedef NS_ENUM(NSInteger, KQBCreditProduct){
    KQBCreditProductLoan = 701
};
#define CreditProductManager [KQBCreditProductManager sharedManager]

@class KQBCreditProductModel;

#define ProductNotiDic   @{KQC_FORMAT(@"%ld",(unsigned long)KQBCreditProductLoan):@"updateLoanProduct"}

@interface KQBCreditProductManager : KQBBaseOmsResManager

- (KQBCreditProductModel *)getCreditProduct:(NSInteger)productId;

+ (KQBCreditProductManager *)sharedManager;


- (void)saveCreditProduct:(KQBCreditProductModel *)productModel;
@end
