//
//  KQBBaseOmsResManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/25.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseOmsResManager.h"
#import "KQBOmsConfigData.h"
#import "KQBCacheManager.h"
#import "KQBOmsBaseModel.h"
#import "KQBBaseResModel.h"

@implementation KQBBaseOmsResManager

- (void)resetData{
    [self loadCache];
    if (!self.resDic) {
        self.resDic = [NSMutableDictionary dictionary];
    }
}

- (void)loadCache{
    _resDic = [KQBCacheManager loadObject:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    
}

- (id)getResById:(NSString *)resourceId{
    if (_resDic.count == 0) {
        return nil;
    }
    if(![_resDic objectForKey:resourceId]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OmsResNotFound" object:resourceId];
    }
    
    if ((self.omsResType == KQBResManagerTypeBanner) || (self.omsResType == KQBResManagerTypeStartup)) {
        KQBBaseResModel * baseModel = [_resDic objectForKey:resourceId];
        NSMutableArray *validResArr = [NSMutableArray array];
        [[baseModel.resArray copy] enumerateObjectsUsingBlock:^(KQBOmsBaseModel* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self checkExpire:obj];
            if (obj.isAvailable) {
                [validResArr addObject:obj];
            }
        }];
        baseModel.resArray = validResArr;
        return baseModel;
    }
    return [_resDic objectForKey:resourceId];
}

- (void)removeResById:(NSString *)resourceId {
    if([_resDic objectForKey:resourceId]){
        [_resDic removeObjectForKey:resourceId];
        [KQBCacheManager saveObject:_resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
    }
}

- (KQBOmsBaseModel *)parseBasicModel:(KQBOmsBaseModel *) model dic:(NSDictionary *)dic {
    model.startTime = [dic objectForKey:@"startTime"];
    model.endTime = [dic objectForKey:@"endTime"];
    model.jumpModel = [dic objectForKey:@"jumpModel"];
    model.jumpTarget = [dic objectForKey:@"jumpTarget"];
    model.resUrl = [dic objectForKey:@"resUrl"];
    model.resType = [dic objectForKey:@"resType"];
    model.resNeedRealName = [dic objectForKey:@"resNeedRealName"];
    model.resName = [dic objectForKey:@"resName"];
    model.resDiretory = [dic objectForKey:@"resDiretory"];
    model.isNeedLogin = [dic objectForKey:@"isNeedLogin"];
    //    [self checkExpire:model];
    model.isAvailable = YES;
    return model;
}

- (void)checkExpire:(KQBOmsBaseModel *)model{
    if (![model respondsToSelector:@selector(startTime)] || ![model respondsToSelector:@selector(endTime)]) {
        model.isAvailable = YES;
        return;
    }
    NSDate *startDate = [KQCDate dateFormat:KQDateFormatAccurateMicroSecond srcDate:model.startTime];
    NSDate *endDate = [KQCDate dateFormat:KQDateFormatAccurateMicroSecond srcDate:model.endTime];
    
    if(([startDate compare:[NSDate date]] == NSOrderedDescending) || ([endDate compare:[NSDate date]] == NSOrderedAscending)){
        model.isAvailable = NO;
        return;
    }
    model.isAvailable = YES;
}

@end

