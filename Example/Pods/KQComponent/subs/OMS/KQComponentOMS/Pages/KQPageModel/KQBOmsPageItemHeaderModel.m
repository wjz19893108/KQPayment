//
//  KQOmsPageItemHeaderModel.m
//  kuaiQianbao
//
//  Created by pengkang on 16/3/8.
//
//

#import "KQBOmsPageItemHeaderModel.h"
#import "KQBOmsImageModel.h"

@implementation KQBOmsPageItemHeaderModel

- (instancetype)initWithDic:(NSDictionary *)configDic
                    resHome:(NSString *)resHome
                    resFrom:(NSString *)resFrom
{
    self = [super init];
    if (self) {
        if (configDic[@"title"]) {
            _title = configDic[@"title"];
        }
        
        if (configDic[@"sectionHeader"]) {
            _sectionHeader = configDic[@"sectionHeader"];
        }
        
        if (configDic[@"description"]) {
            _resDescription = configDic[@"description"];
        }
        
        if (configDic[@"item"]) {
            _item = [[KQBOmsImageModel alloc] initWithDic: configDic[@"item"]];
            [self parseBasicModel:_item dic:configDic[@"item"]];
            _item.resHome = resHome;
            _item.resFrom = resFrom;
        }
        
    }
    return self;
}

- (void)parseBasicModel:(KQBOmsBaseModel *) model dic:(NSDictionary *)dic {
    model.startTime = [dic objectForKey:@"startTime"];
    model.endTime = [dic objectForKey:@"endTime"];
    model.jumpModel = [dic objectForKey:@"jumpModel"];
    model.jumpTarget = [dic objectForKey:@"jumpTarget"];
    model.resUrl = [dic objectForKey:@"resUrl"];
    model.resType = [dic objectForKey:@"resType"];
    model.resNeedRealName = [dic objectForKey:@"resNeedRealName"];
    model.resName = [dic objectForKey:@"resName"];
    model.resDiretory = [dic objectForKey:@"resDiretory"];
    //    [self checkExpire:model];
}

- (void)checkExpire:(KQBOmsBaseModel *) model {
    NSDate *startDate = [KQCDate dateFormat:KQDateFormatAccurateMicroSecond srcDate:model.startTime];
    NSDate *endDate = [KQCDate dateFormat:KQDateFormatAccurateMicroSecond srcDate:model.endTime];
    
    if(([startDate compare:[NSDate date]] == NSOrderedDescending) || ([endDate compare:[NSDate date]] == NSOrderedAscending)){
        model.isAvailable = NO;
        return;
    }
    model.isAvailable = YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.sectionHeader forKey:@"sectionHeader"];
    [aCoder encodeObject:self.resDescription forKey:@"resDescription"];
    [aCoder encodeObject:self.item forKey:@"item"];
    [aCoder encodeObject:self.resFrom forKey:@"resFrom"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.sectionHeader = [aDecoder decodeObjectForKey:@"sectionHeader"];
        self.resDescription = [aDecoder decodeObjectForKey:@"resDescription"];
        self.item = [aDecoder decodeObjectForKey:@"item"];
        self.resFrom = [aDecoder decodeObjectForKey:@"resFrom"];
    }
    return self;
}

@end

