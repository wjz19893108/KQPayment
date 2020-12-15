//
//  KQPayDetailNavigateView.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/27.
//  Copyright © 2015年 program. All rights reserved.
//


#import "KQBasePayHalfView.h"

@interface KQPayDetailInfoTypeWapper : NSObject

@property (nonatomic, assign) KQPayDetailInfoType infoType;

@end

@interface KQPayDetailNavigateView : KQBasePayHalfView

- (instancetype __nullable)init;
- (void)reloadData;

@end
