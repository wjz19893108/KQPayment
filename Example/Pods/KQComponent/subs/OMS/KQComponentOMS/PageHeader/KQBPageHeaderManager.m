//
//  KQBPageHeaderManager.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBPageHeaderManager.h"
#import "KQBPageHeaderModel.h"
#import "KQBOmsPageHeaderModel.h"

@implementation KQBPageHeaderManager

+ (KQBPageHeaderManager *)sharedManager{
    static KQBPageHeaderManager *instance = nil;
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
    [PageHeaderNotiDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:obj object:nil];
    }];
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeFall;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    KQBPageHeaderModel *headerModel = [[KQBPageHeaderModel alloc] init];
    headerModel.resourceId = resId;
    headerModel.isDefault = [msgContent[@"isDefault"] boolValue];

    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsPageHeaderModel * omsObj = [[KQBOmsPageHeaderModel alloc] initWithDic:obj];
        [tmpArray addObject:omsObj];
        
    }];
    
    headerModel.resArray = tmpArray;
    
    if (headerModel && (headerModel.resArray.count > 0)) {
        [self.resDic setObject:headerModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
        if (!msgContent[@"isDefault"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[PageHeaderNotiDic objectForKey:resId] object:headerModel];
        }
    }
}

-(KQBPageHeaderModel *)getHeader:(KQBPageHeaderType)headerType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)headerType);
    return (KQBPageHeaderModel *)[self getResById:resourceIdStr];
    
}

@end
