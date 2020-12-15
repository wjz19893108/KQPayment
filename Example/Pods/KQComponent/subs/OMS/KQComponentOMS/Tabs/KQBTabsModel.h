//
//  KQBTabsModel.h
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseResModel.h"

@interface KQBTabsModel : KQBBaseResModel <NSCoding>

@property (nonatomic, assign)NSInteger tabBarSelectedIndex;    //Tab 默认选中index

@end
