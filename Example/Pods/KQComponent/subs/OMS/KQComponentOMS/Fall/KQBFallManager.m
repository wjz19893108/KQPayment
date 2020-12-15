//
//  KQBFallManager.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/28.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBFallManager.h"
#import "KQBFallModel.h"
#import "KQBOmsFallModel.h"

@implementation KQBFallManager

+ (KQBFallManager *)sharedManager{
    static KQBFallManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeFall;
        [self resetData];
    }
    return self;
}

- (void)resetData{
    [super resetData];
    // 目前瀑布流数据来自接口，固无需发送通知
//    [FallNotiDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:obj object:nil];
//    }];
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeFall;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    KQBFallModel *fallModel = [[KQBFallModel alloc] init];
    fallModel.resourceId = resId;
    fallModel.isDefault = [msgContent[@"isDefault"] boolValue];

    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsFallModel * omsObj = [[KQBOmsFallModel alloc] initWithDic:obj];
        [tmpArray addObject:omsObj];
    }];
    fallModel.resArray = tmpArray;
    
    if (fallModel && (fallModel.resArray.count > 0)) {
        [self.resDic setObject:fallModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
        if (!msgContent[@"isDefault"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[FallNotiDic objectForKey:resId] object:fallModel];
        }
    }
}

- (void)saveFallModel:(KQBFallModel *)fallModel {
    if (fallModel) {
        if (!self.resDic) {
            self.resDic = [NSMutableDictionary dictionary];
        }
        [self.resDic setObject:fallModel forKey:fallModel.resourceId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
    }

}
-(KQBFallModel *)getFall:(KQBFallType)fallType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)fallType);
    return (KQBFallModel *)[self getResById:resourceIdStr];

}
@end
