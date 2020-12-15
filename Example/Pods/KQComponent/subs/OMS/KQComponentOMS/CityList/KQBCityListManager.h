//
//  KQBCityListManager.h
//  KQBusiness
//
//  Created by building wang on 2017/12/6.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

#define CityListManager [KQBCityListManager sharedManager]

@interface KQBCityListManager : KQBBaseOmsResManager

+ (KQBCityListManager *)sharedManager;

@end
