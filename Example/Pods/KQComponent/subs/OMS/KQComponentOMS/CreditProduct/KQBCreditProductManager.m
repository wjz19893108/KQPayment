//
//  KQBCreditProductManager.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBCreditProductManager.h"

#import "KQBCreditProductModel.h"
#import "KQBOmsCreditProductModel.h"

@implementation KQBCreditProductManager

+ (KQBCreditProductManager *)sharedManager{
    static KQBCreditProductManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeCreditProduct;
        [self resetData];
    }
    return self;
}

- (void)resetData{
    [super resetData];
    [ProductNotiDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:obj object:nil];
    }];
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeCreditProduct;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    KQBCreditProductModel *productModel = [[KQBCreditProductModel alloc] init];
    productModel.resourceId = resId;
    productModel.isDefault = [msgContent[@"isDefault"] boolValue];

    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsCreditProductModel * omsObj = [[KQBOmsCreditProductModel alloc] initWithDic:obj];
        [tmpArray addObject:omsObj];
        
    }];
    
    productModel.resArray = tmpArray;
    
    if (productModel && (productModel.resArray.count > 0)) {
        if (!self.resDic) {
            self.resDic = [NSMutableDictionary dictionary];
        }
        [self.resDic setObject:productModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
        if (!msgContent[@"isDefault"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[ProductNotiDic objectForKey:resId] object:productModel];
        }
    }
}

- (void)saveCreditProduct:(KQBCreditProductModel *)productModel {
    if (productModel) {
        [self.resDic setObject:productModel forKey:productModel.resourceId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
    }
    
}

- (KQBCreditProductModel *)getCreditProduct:(NSInteger)productId{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)productId);
    return (KQBCreditProductModel *)[self getResById:resourceIdStr];
}

@end
