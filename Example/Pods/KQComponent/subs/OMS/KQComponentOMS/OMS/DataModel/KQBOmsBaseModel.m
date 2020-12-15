//
//  KQOmsBaseModel.m
//  kuaiQianbao
//
//  Created by pengkang on 16/1/4.
//
//

#import "KQBOmsBaseModel.h"

@implementation KQBOmsBaseModel

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.resHome forKey:@"resHome"];
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:self.placeHolder forKey:@"placeHolder"];
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.jumpModel forKey:@"jumpModel"];
    [aCoder encodeObject:self.jumpTarget forKey:@"jumpTarget"];
    [aCoder encodeObject:self.resUrl forKey:@"resUrl"];
    [aCoder encodeObject:self.resType forKey:@"resType"];
    [aCoder encodeObject:self.resName forKey:@"resName"];
    [aCoder encodeObject:self.resNeedRealName forKey:@"resNeedRealName"];
    [aCoder encodeObject:self.resDiretory forKey:@"resDiretory"];
    [aCoder encodeObject:self.isNeedLogin forKey:@"isNeedLogin"];
    [aCoder encodeObject:self.resId forKey:@"resId"];
    [aCoder encodeBool:self.isAvailable forKey:@"isAvailable"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.resHome = [aDecoder decodeObjectForKey:@"resHome"];
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.placeHolder = [aDecoder decodeObjectForKey:@"placeHolder"];
        self.startTime = [aDecoder decodeObjectForKey:@"startTime"];
        self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
        self.jumpModel = [aDecoder decodeObjectForKey:@"jumpModel"];
        self.jumpTarget = [aDecoder decodeObjectForKey:@"jumpTarget"];
        self.resUrl = [aDecoder decodeObjectForKey:@"resUrl"];
        self.resType = [aDecoder decodeObjectForKey:@"resType"];
        self.resName = [aDecoder decodeObjectForKey:@"resName"];
        self.resNeedRealName = [aDecoder decodeObjectForKey:@"resNeedRealName"];
        self.resDiretory = [aDecoder decodeObjectForKey:@"resDiretory"];
        self.isNeedLogin = [aDecoder decodeObjectForKey:@"isNeedLogin"];
        self.resId = [aDecoder decodeObjectForKey:@"resId"];
        self.isAvailable = [aDecoder decodeBoolForKey:@"isAvailable"];
    }
    return self;
}

@end
