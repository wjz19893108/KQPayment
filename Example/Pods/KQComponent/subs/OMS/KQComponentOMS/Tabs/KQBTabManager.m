//
//  KQBTabManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBTabManager.h"
#import "KQBOmsTabModel.h"
#import "KQBTabsModel.h"

#define TabResId @"400"

@implementation KQBTabManager

+ (KQBTabManager *)sharedManager{
    static KQBTabManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeTab;
        [self resetData];
    }
    return self;
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeTab;
}

- (KQBTabsModel *)getTabRes{
    KQBTabsModel *tabModel = [self getResById:TabResId];
    if(![self verifyTabRes:tabModel.resArray]){
        return nil;
    }
    return tabModel;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    KQBTabsModel *tabModel = [[KQBTabsModel alloc] init];
    tabModel.resourceId = resId;
    tabModel.tabBarSelectedIndex = [msgContent[@"selectIndex"] integerValue];
    
    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsTabModel *omsObj = [[KQBOmsTabModel alloc] initWithDic:obj];
        [self parseBasicModel:omsObj dic:obj];
        omsObj.resHome = resHome;
        if (omsObj.isAvailable) {
            [tmpArray addObject:omsObj];
        }
    }];
    tabModel.resArray = tmpArray;
    
    if (tabModel) {
        [self.resDic setObject:tabModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
    }
}

- (BOOL)verifyTabRes:(NSArray *)resArr{
    __block BOOL result = YES;
    [resArr enumerateObjectsUsingBlock:^(KQBOmsTabModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.selectedItem.image || !obj.unselectedItem.image ) {
            //去下载资源
            [self downloadTabImage:obj];
            result = NO;
            return;
        }
    }];
    if (resArr.count <= 0) {
        result = NO;
    }
    return result;
}

- (void)downloadTabImage:(KQBOmsTabModel *)tabModel{
    if (!tabModel.selectedItem.image) {
        NSString *imagePath =  KQC_FORMAT(@"%@/%@%@", [KQBCacheManager directoryPath:KQCahceTypeUserOms], tabModel.selectedItem.iconHome, tabModel.selectedItem.iconDiretory);
        [KQHttpService downloadFileFrom:tabModel.selectedItem.iconUrl toFile:imagePath successBlock:^(NSString *responseStr, NSData *responseData) {
        } failBlock:^(NSError *error) {
        }];
    }
    
    
    if (!tabModel.unselectedItem.image){
        NSString *imagePath =  KQC_FORMAT(@"%@/%@%@", [KQBCacheManager directoryPath:KQCahceTypeUserOms], tabModel.unselectedItem.iconHome, tabModel.unselectedItem.iconDiretory);
        
        [KQHttpService downloadFileFrom:tabModel.selectedItem.iconUrl toFile:imagePath successBlock:^(NSString *responseStr, NSData *responseData) {
        } failBlock:^(NSError *error) {
        }];
    }
    return;
}

@end
