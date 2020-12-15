//
//  KQBPageCard.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/21.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBPageCard.h"
#import "KQBFallManager.h"
#import "KQBCreditProductManager.h"

@implementation KQBPageCardResInfo

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _itemsFrom = [dic[@"itemsFrom"] integerValue];
        _itemsResId = [dic[@"itemsResId"] integerValue];
        _itemsInterface = dic[@"itemsInterface"];
        _linkedInterface = dic[@"linkedInterface"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.itemsFrom forKey:@"itemsFrom"];
    [aCoder encodeInteger:self.itemsResId forKey:@"itemsResId"];
    [aCoder encodeObject:self.itemsMd5 forKey:@"itemsMd5"];
    [aCoder encodeObject:self.itemsInterface forKey:@"itemsInterface"];
    [aCoder encodeObject:self.linkedInterface forKey:@"linkedInterface"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.itemsFrom = [aDecoder decodeIntegerForKey:@"itemsFrom"];
        self.itemsResId = [aDecoder decodeIntegerForKey:@"itemsResId"];
        self.itemsMd5 = [aDecoder decodeObjectForKey:@"itemsMd5"];
        self.itemsInterface = [aDecoder decodeObjectForKey:@"itemsInterface"];
        self.linkedInterface = [aDecoder decodeObjectForKey:@"linkedInterface"];
    }
    return self;
}
@end

@implementation KQBPageCard

-(instancetype)init{
    return [super init];
}

- (instancetype)initWithDic:(NSDictionary *)configDic
                    resHome:(NSString *)resHome
{
    self = [super init];
    if (self) {
        _resHome = resHome;        
        _cardType = [configDic[@"cardType"] integerValue];
        _cardStyle = configDic[@"cardStyle"];
        _backgroundColor = [UIColor colorWithHexString:configDic[@"backgroundColor"]];
        _backgroundImageUrl = configDic[@"backgroundImageUrl"];
        
        _parameters = configDic[@"params"];
        
        _resInfo = [[KQBPageCardResInfo alloc] initWithDic:configDic[@"resInfo"]];
        
        _itemHeader = [[KQBOmsPageItemHeaderModel alloc] initWithDic:configDic[@"header"]
                                                             resHome:_resHome
                                                             resFrom:_resFrom];
        
        _businessStatus = [self hexStrToInt:_parameters[@"isApplyCredit"]];
        
        if (_resInfo.itemsFrom == KQBCardResFromInterface) {
            _resInfo.itemsResId = [self getResId];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.cardType forKey:@"cardType"];
    [aCoder encodeObject:self.cardStyle forKey:@"cardStyle"];
    [aCoder encodeObject:self.backgroundColor forKey:@"backgroundColor"];
    [aCoder encodeObject:self.backgroundImageUrl forKey:@"backgroundImageUrl"];
    [aCoder encodeObject:self.parameters forKey:@"parameters"];
    [aCoder encodeObject:self.resInfo forKey:@"resInfo"];
    [aCoder encodeObject:self.itemHeader forKey:@"itemHeader"];
    [aCoder encodeObject:self.resFrom forKey:@"resFrom"];
    [aCoder encodeObject:self.resHome forKey:@"resHome"];
    [aCoder encodeObject:self.resObj forKey:@"resObj"];
    [aCoder encodeInteger:self.itemsStatus forKey:@"itemsStatus"];
    [aCoder encodeInteger:self.businessStatus forKey:@"businessStatus"];


}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.cardType = [aDecoder decodeIntegerForKey:@"cardType"];
        self.cardStyle = [aDecoder decodeObjectForKey:@"cardStyle"];
        self.backgroundColor = [aDecoder decodeObjectForKey:@"backgroundColor"];
        self.backgroundImageUrl = [aDecoder decodeObjectForKey:@"backgroundImageUrl"];
        self.parameters = [aDecoder decodeObjectForKey:@"parameters"];
        self.resInfo = [aDecoder decodeObjectForKey:@"resInfo"];
        self.itemHeader = [aDecoder decodeObjectForKey:@"itemHeader"];
        self.resHome = [aDecoder decodeObjectForKey:@"resHome"];
        self.resFrom = [aDecoder decodeObjectForKey:@"resFrom"];
        self.resObj = [aDecoder decodeObjectForKey:@"resObj"];
        self.itemsStatus = [aDecoder decodeIntegerForKey:@"itemsStatus"];
        self.businessStatus = [aDecoder decodeIntegerForKey:@"businessStatus"];
    }
    return self;
}

- (NSUInteger)hexStrToInt:(NSString *)str {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

- (NSUInteger)getResId{
    if (self.cardType == KQBCardTypeCreditFall) {
        return [self.cardStyle isEqualToString:@"1"]?KQBFallTypeFree:KQBFallTypeTop;
    } else if (self.cardType == KQBCardTypeCreditProduct){
        return KQBCreditProductLoan;
    }
    return 0;
}

@end
