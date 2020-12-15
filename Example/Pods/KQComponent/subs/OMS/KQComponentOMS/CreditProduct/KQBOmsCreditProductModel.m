//
//  KQBOmsCreditProductModel.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBOmsCreditProductModel.h"

@implementation KQBOmsCreditProductModel

- (instancetype)initWithDic:(NSDictionary *)configDic {
    self = [super init];
    if (self) {
        self.labelColor =  [UIColor colorWithHexString:configDic[@"labelColor"]];
        self.labelInfo = configDic[@"labelInfo"];
        self.itemUrl = configDic[@"itemUrl"];
        self.logoImage = configDic[@"logoImage"];
        self.productCode = configDic[@"productCode"];
        self.status = configDic[@"status"];
        self.subTitle = configDic[@"subTitle"];
        self.title = configDic[@"title"];
        self.amountDesc = configDic[@"amountDesc"];
    }
    return self;
}

- (instancetype)initWithResponse:(ContentProductItem *)product{
    self = [super init];
    if (self) {
        self.labelColor = [UIColor colorWithHexString:product.labelColor];
        self.labelInfo = product.labelInfo;
        self.itemUrl = product.itemUrl;
        self.logoImage = product.logoImage;
        self.productCode = product.productCode;
        self.status = product.status;
        self.subTitle = product.subTitle;
        self.title = product.title;
        self.amountDesc = product.amountDesc;
    }
    return self;
    
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.labelColor forKey:@"labelColor"];
    [aCoder encodeObject:self.labelInfo forKey:@"labelInfo"];
    [aCoder encodeObject:self.itemUrl forKey:@"itemUrl"];
    [aCoder encodeObject:self.logoImage forKey:@"logoImage"];
    [aCoder encodeObject:self.productCode forKey:@"productCode"];
    [aCoder encodeObject:self.status forKey:@"status"];
    [aCoder encodeObject:self.subTitle forKey:@"subTitle"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.headerName forKey:@"headerName"];
    [aCoder encodeObject:self.amountDesc forKey:@"amountDesc"];
    [aCoder encodeObject:self.subtitleIcon forKey:@"subtitleIcon"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.labelColor = [aDecoder decodeObjectForKey:@"labelColor"];
        self.labelInfo = [aDecoder decodeObjectForKey:@"labelInfo"];
        self.itemUrl = [aDecoder decodeObjectForKey:@"itemUrl"];
        self.logoImage = [aDecoder decodeObjectForKey:@"logoImage"];
        self.productCode = [aDecoder decodeObjectForKey:@"productCode"];
        self.status = [aDecoder decodeObjectForKey:@"status"];
        self.subTitle = [aDecoder decodeObjectForKey:@"subTitle"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.headerName = [aDecoder decodeObjectForKey:@"headerName"];
        self.amountDesc = [aDecoder decodeObjectForKey:@"amountDesc"];
        self.subtitleIcon = [aDecoder decodeObjectForKey:@"subtitleIcon"];
    }
    return self;
}

@end
