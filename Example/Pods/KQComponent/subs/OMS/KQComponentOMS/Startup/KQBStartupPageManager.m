//
//  KQBStartupPageManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBStartupPageManager.h"
#import "KQBStartupPageModel.h"
#import "KQBOmsAdvPageModel.h"

@implementation KQBStartupPageManager

+ (KQBStartupPageManager *)sharedManager{
    static KQBStartupPageManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeStartup;
        [self resetData];
    }
    return self;
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeStartup;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome {
    if(!msgContent){
        return;
    }
    KQBStartupPageModel *startupModel = [[KQBStartupPageModel alloc] init];
    startupModel.resourceId = resId;
    
    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsAdvPageModel *omsObj = [[KQBOmsAdvPageModel alloc] initWithDic:obj[@"ext"]];
        omsObj.resId = resId;
        [self parseBasicModel:omsObj dic:obj[@"ext"]];
        omsObj.resHome = resHome;
        if (omsObj.isAvailable) {
            [tmpArray addObject:omsObj];
        }
    }];
    startupModel.resArray = tmpArray;
    
    if (startupModel) {
        [self.resDic setObject:startupModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
    }
}

- (KQBStartupPageModel *)getStartup:(KQBStartupType)startupType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)startupType);
    return [self getResById:resourceIdStr];
}

@end
