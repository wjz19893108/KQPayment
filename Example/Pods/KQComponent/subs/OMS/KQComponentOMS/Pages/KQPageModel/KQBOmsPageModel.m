//
//  KQOmsPageModel.m
//  kuaiQianbao
//
//  Created by pengkang on 16/3/8.
//
//

#import "KQBOmsPageModel.h"
#import "KQBOmsImageModel.h"
@implementation KQBOmsPageModel

- (instancetype)initWithDic:(NSDictionary *)configDic
                    resHome:(NSString *)resHome
                    resFrom:(NSString *)resFrom
{
    self = [super init];
    if (self) {
        _resHome = resHome;
        _resFrom = resFrom;
        if (configDic[@"contentType"]) {
            _contentType = configDic[@"contentType"];
        }
        
        if (configDic[@"position"]) {
            _position = configDic[@"position"];
        }
        
        if (configDic[@"header"]) {
            _itemHeader = [[KQBOmsPageItemHeaderModel alloc] initWithDic:configDic[@"header"]
                                                                resHome:_resHome
                                                                resFrom:_resFrom];
        }
        if (configDic[@"isDisAfterLogin"]) {
            _isDisAfterLogin = configDic[@"isDisAfterLogin"];
        }
        
        if (configDic[@"items"]) {
            [self parseItems:configDic[@"items"]];
        }
    }
    return self;
}

- (void)parseItems:(NSArray *)items{
    NSMutableArray *tmpArray = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsImageModel *omsObj = [[KQBOmsImageModel alloc] initWithDic:obj];
        [self parseBasicModel:omsObj dic:obj];
        omsObj.resHome = _resHome;
        omsObj.resFrom = _resFrom;
        if (omsObj.isAvailable) {
            [tmpArray addObject:omsObj];
        }
    }];
    _items = tmpArray;
}

- (void)parseBasicModel:(KQBOmsBaseModel *) model dic:(NSDictionary *)dic{
    model.startTime = [dic objectForKey:@"startTime"];
    model.endTime = [dic objectForKey:@"endTime"];
    model.jumpModel = [dic objectForKey:@"jumpModel"];
    model.jumpTarget = [dic objectForKey:@"jumpTarget"];
    model.resUrl = [dic objectForKey:@"resUrl"];
    model.resType = [dic objectForKey:@"resType"];
    model.resNeedRealName = [dic objectForKey:@"resNeedRealName"];
    model.resName = [dic objectForKey:@"resName"];
    model.resDiretory = [dic objectForKey:@"resDiretory"];
    [self checkExpire:model];
}

- (void)checkExpire:(KQBOmsBaseModel *)model{
    NSDate *startDate = [KQCDate dateFormat:KQDateFormatAccurateMicroSecond srcDate:model.startTime];
    NSDate *endDate = [KQCDate dateFormat:KQDateFormatAccurateMicroSecond srcDate:model.endTime];
    
    if(([startDate compare:[NSDate date]] == NSOrderedDescending) || ([endDate compare:[NSDate date]] == NSOrderedAscending)){
        model.isAvailable = NO;
        return;
    }
    model.isAvailable = YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.contentType forKey:@"contentType"];
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:self.itemHeader forKey:@"itemHeader"];
    [aCoder encodeObject:self.items forKey:@"items"];
    [aCoder encodeObject:self.resHome forKey:@"resHome"];
    [aCoder encodeObject:self.resFrom forKey:@"resFrom"];
    [aCoder encodeObject:self.isDisAfterLogin forKey:@"isDisAfterLogin"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.contentType = [aDecoder decodeObjectForKey:@"contentType"];
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.itemHeader = [aDecoder decodeObjectForKey:@"itemHeader"];
        self.items = [aDecoder decodeObjectForKey:@"items"];
        self.resHome = [aDecoder decodeObjectForKey:@"resHome"];
        self.resFrom = [aDecoder decodeObjectForKey:@"resFrom"];
        self.isDisAfterLogin = [aDecoder decodeObjectForKey:@"isDisAfterLogin"];
    }
    return self;
}

@end
