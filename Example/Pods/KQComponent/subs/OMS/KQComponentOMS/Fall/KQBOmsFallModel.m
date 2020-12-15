//
//  KQBOmsFallModel.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/28.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBOmsFallModel.h"

@implementation KQBOmsFallModel

- (instancetype)initWithResponse:(ContentResult *)product{
    self = [super init];
    if (self) {
        self.itemId = product.itemId.integerValue;
        self.itemName = product.name;
        self.imageDefaultId = product.imageDefaultId;
        self.price = product.price;
        self.sort = product.sort;
        self.creditSort = product.creditSort;
        self.productTag = product.tag;
        self.isStages = product.isStages;
        self.stagesApp = product.stagesApp;
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)configDic {
    self = [super init];
    if (self) {
        self.itemId = [configDic[@"itemId"] integerValue];
        self.itemName = configDic[@"name"];
        self.imageDefaultId = configDic[@"imageDefaultId"];
        self.price = configDic[@"price"];
        self.sort = configDic[@"sort"];
        self.creditSort = configDic[@"creditSort"];
        self.productTag = configDic[@"tag"];
        self.isStages = configDic[@"isStages"];
        self.stagesApp = configDic[@"stagesApp"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.itemId forKey:@"itemId"];
    [aCoder encodeObject:self.itemName forKey:@"itemName"];
    [aCoder encodeObject:self.imageDefaultId forKey:@"imageDefaultId"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.sort forKey:@"sort"];
    [aCoder encodeObject:self.creditSort forKey:@"creditSort"];
    [aCoder encodeObject:self.productTag forKey:@"productTag"];
    [aCoder encodeObject:self.isStages forKey:@"isStages"];
    [aCoder encodeObject:self.stagesApp forKey:@"stagesApp"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.itemId = [aDecoder decodeIntegerForKey:@"itemId"];
        self.itemName = [aDecoder decodeObjectForKey:@"itemName"];
        self.imageDefaultId = [aDecoder decodeObjectForKey:@"imageDefaultId"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        self.sort = [aDecoder decodeObjectForKey:@"sort"];
        self.creditSort = [aDecoder decodeObjectForKey:@"creditSort"];
        self.productTag = [aDecoder decodeObjectForKey:@"productTag"];
        self.isStages = [aDecoder decodeObjectForKey:@"isStages"];
        self.stagesApp = [aDecoder decodeObjectForKey:@"stagesApp"];
    }
    return self;
}

@end
