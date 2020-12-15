//
//  KQBOmsCardModel.m
//  KQBusiness
//
//  Created by pengkang on 2017/6/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBOmsCardModel.h"

@implementation KQBOmsCardModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.iconUrl forKey:@"iconUrl"];
    [aCoder encodeObject:self.iconDiretory forKey:@"iconDiretory"];
    [aCoder encodeObject:self.isShowIcon forKey:@"isShowIcon"];
    [aCoder encodeObject:self.jumpMode forKey:@"jumpMode"];
    [aCoder encodeObject:self.jumpTarget forKey:@"jumpTarget"];
    [aCoder encodeObject:self.textColor forKey:@"textColor"];
    [aCoder encodeObject:self.bgColor forKey:@"bgColor"];
    [aCoder encodeObject:self.textContent forKey:@"textContent"];
    [aCoder encodeObject:self.subTextContent forKey:@"subTextContent"];
    [aCoder encodeObject:self.subTextContentValue forKey:@"subTextContentValue"];
    [aCoder encodeObject:self.subTextColor forKey:@"subTextColor"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.iconUrl = [aDecoder decodeObjectForKey:@"iconUrl"];
        self.iconDiretory = [aDecoder decodeObjectForKey:@"iconDiretory"];
        self.isShowIcon = [aDecoder decodeObjectForKey:@"isShowIcon"];
        self.jumpMode = [aDecoder decodeObjectForKey:@"jumpMode"];
        self.jumpTarget = [aDecoder decodeObjectForKey:@"jumpTarget"];
        self.textColor = [aDecoder decodeObjectForKey:@"textColor"];
        self.bgColor = [aDecoder decodeObjectForKey:@"bgColor"];
        self.textContent = [aDecoder decodeObjectForKey:@"textContent"];
        self.subTextContent = [aDecoder decodeObjectForKey:@"subTextContent"];
        self.subTextContentValue = [aDecoder decodeObjectForKey:@"subTextContentValue"];
        self.subTextColor = [aDecoder decodeObjectForKey:@"subTextColor"];

    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        self.iconUrl = configDic[@"iconUrl"];
        self.iconDiretory = configDic[@"iconDiretory"];
        self.isShowIcon = configDic[@"isShowIcon"];
        self.jumpMode = configDic[@"jumpMode"];
        self.jumpTarget = configDic[@"jumpTarget"];
        self.textContent = configDic[@"textContent"];
        self.bgColor = [UIColor colorWithHexString:configDic[@"bgColor"]];
        self.textColor = [UIColor colorWithHexString:configDic[@"textColor"]];
        self.subTextColor = [UIColor colorWithHexString:configDic[@"subTextColor"]];
        self.subTextContent = configDic[@"subTextContent"];
        self.subTextContentValue = configDic[@"subTextContentValue"];
    }
    return self;

}
@end
