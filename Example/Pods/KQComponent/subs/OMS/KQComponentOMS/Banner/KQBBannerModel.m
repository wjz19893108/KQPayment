//
//  KQBBannerModel.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBannerModel.h"

@implementation KQBBannerModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.bannerDuration forKey:@"bannerDuration"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.bannerDuration = [aDecoder decodeObjectForKey:@"bannerDuration"];
    }
    return self;
}

@end
