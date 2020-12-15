//
//  KQPayCardLimitManager.h
//  kuaiQianbao
//
//  Created by zouf on 16/3/7.
//
//

#import <Foundation/Foundation.h>
#import "KQPayCardLimitData.h"

typedef void(^FindCardLimit)(KQPayCardLimitData* __nullable data);

#define PayCardLimitManager [KQPayCardLimitManager sharedKQPayCardLimitManager]


#define KQPAY_CARD_LIMIT_KQQB_KLL       @"Kqqb_KLL"
#define KQPAY_CARD_LIMIT_KQQB_KDY       @"Kqqb_KDY"


@interface KQPayCardLimitManager : NSObject

@property (nonatomic, strong, readonly, nullable) NSMutableDictionary *cardLimitDic;    //[bankId][cardType][productCode]

+ (instancetype __nullable)sharedKQPayCardLimitManager;

- (void)findCardLimitObj:(NSString* __nullable)bankId cardType:(NSString* __nullable)cardType productCode:(NSString* __nullable)productCode completion:(FindCardLimit __nullable)findCardLimitBlock;

@end
