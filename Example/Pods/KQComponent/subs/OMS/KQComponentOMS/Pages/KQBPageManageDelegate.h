//
//  KQBPageManageDelegate.h
//  KQBusiness
//
//  Created by pengkang on 2017/3/6.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBPageModel.h"

@protocol KQBPageManageDelegate <NSObject>

- (void)checkCardsRes:(KQBPageModel *)page;

@end
