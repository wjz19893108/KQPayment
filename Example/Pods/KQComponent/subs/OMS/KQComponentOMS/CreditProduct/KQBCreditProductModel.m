//
//  KQBCreditProductModel.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBCreditProductModel.h"

@implementation KQBCreditProductModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.productName forKey:@"productName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.productName = [aDecoder decodeObjectForKey:@"productName"];
    }
    return self;
}

@end
