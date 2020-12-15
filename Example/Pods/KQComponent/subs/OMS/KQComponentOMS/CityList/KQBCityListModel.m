//
//  KQBCityListModel.m
//  KQBusiness
//
//  Created by building wang on 2017/12/7.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBCityListModel.h"

@implementation KQBCityListModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cityId forKey:@"cityId"];
    [aCoder encodeObject:self.cityName forKey:@"cityName"];
    [aCoder encodeObject:self.cityPinYin forKey:@"cityPinYin"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.cityId = [aDecoder decodeObjectForKey:@"cityId"];
        self.cityName = [aDecoder decodeObjectForKey:@"cityName"];
        self.cityPinYin = [aDecoder decodeObjectForKey:@"cityPinYin"];
    }
    return self;
}

- (instancetype _Nullable )initWithDic:(NSDictionary *_Nullable)configDic{
    self = [super init];
    if (self) {
        self.cityId = configDic[@"cityId"];
        self.cityName = configDic[@"cityName"];
        self.cityPinYin = configDic[@"cityPinYin"];
    }
    return self;
    
}
@end
