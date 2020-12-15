//
//  KQBTabsModel.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBTabsModel.h"

@implementation KQBTabsModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.tabBarSelectedIndex forKey:@"tabBarSelectedIndex"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabBarSelectedIndex = [aDecoder decodeIntegerForKey:@"tabBarSelectedIndex"];
    }
    return self;
}
@end
