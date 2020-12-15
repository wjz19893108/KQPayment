//
//  KQBTabManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"

#define TabManager [KQBTabManager sharedManager]

@class KQBTabsModel;

@interface KQBTabManager : KQBBaseOmsResManager

/**
 *  获取Tabs数据
 *
 */
- (KQBTabsModel *)getTabRes;

+ (KQBTabManager *)sharedManager;

@end
