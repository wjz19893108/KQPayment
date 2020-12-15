//
//  KQBCardManager.m
//  KQBusiness
//
//  Created by pengkang on 2017/6/14.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBCardManager.h"
#import "KQBCardModel.h"
#import "KQBOmsCardModel.h"

@implementation KQBCardManager

+ (KQBCardManager *)sharedManager{
    static KQBCardManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeMultiCard;
        [self resetData];
    }
    return self;
}

- (void)resetData{
    [super resetData];
    [MultiCardNotiDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:obj object:nil];
    }];
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeMultiCard;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    KQBCardModel *cardModel = [[KQBCardModel alloc] init];
    cardModel.resourceId = resId;
    cardModel.isDefault = [msgContent[@"isDefault"] boolValue];
    
    NSArray *contentArray = msgContent[@"columnList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsCardModel * omsObj = [[KQBOmsCardModel alloc] initWithDic:obj];
        [tmpArray addObject:omsObj];
    }];
    cardModel.resArray = tmpArray;
    
    if (cardModel && (cardModel.resArray.count > 0)) {
        [self.resDic setObject:cardModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
        if (!msgContent[@"isDefault"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[MultiCardNotiDic objectForKey:resId] object:cardModel];
        }
    }
}

- (KQBCardModel *)getCard:(KQBCardMType)cardType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)cardType);
    return (KQBCardModel *)[self getResById:resourceIdStr];
}

@end
