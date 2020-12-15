//
//  KQBBannerManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/25.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBannerManager.h"
#import "KQBBannerModel.h"
#import "KQBOmsBannerModel.h"

@implementation KQBBannerManager

+ (KQBBannerManager *)sharedManager{
    static KQBBannerManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeBanner;
        [self resetData];
    }
    return self;
}

- (void)resetData{
    [super resetData];
    [BannerNotiDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:obj object:nil];
    }];
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeBanner;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    
    KQBBannerModel *bannerModel = [[KQBBannerModel alloc] init];
    bannerModel.resourceId = resId;
    bannerModel.bannerDuration = msgContent[@"timeInterval"];
    bannerModel.isDefault = [msgContent[@"isDefault"] boolValue];
    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsBannerModel * omsObj = [[KQBOmsBannerModel alloc] initWithDic:obj[@"ext"]];
        omsObj.resId = resId;
        [self parseBasicModel:omsObj dic:obj[@"ext"]];
        omsObj.resHome = resHome;
        if (omsObj.isAvailable) {
            [tmpArray addObject:omsObj];
        }
    }];
    
    bannerModel.resArray = tmpArray;
    
    if (bannerModel && (bannerModel.resArray.count > 0)) {
        [self.resDic setObject:bannerModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
        
        if (!msgContent[@"isDefault"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[BannerNotiDic objectForKey:resId] object:bannerModel];
        }
    }
}

- (KQBBannerModel *)getBanner:(KQBBannerType)bannerType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)bannerType);
    return (KQBBannerModel *)[self getResById:resourceIdStr];
}
@end
