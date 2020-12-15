//
//  KQBBaseResModel.m
//  KQBusiness
//
//  Created by pengkang on 2017/3/13.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBBaseResModel.h"

@implementation KQBBaseResModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.resArray forKey:@"resArray"];
    [aCoder encodeObject:self.resourceId forKey:@"resourceId"];
    [aCoder encodeBool:self.isDefault forKey:@"isDefault"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.resArray = [aDecoder decodeObjectForKey:@"resArray"];
        self.resourceId = [aDecoder decodeObjectForKey:@"resourceId"];
        self.isDefault = [aDecoder decodeBoolForKey:@"isDefault"];
    }
    return self;
}

@end
