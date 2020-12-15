//
//  KQBMatrixManager.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBMatrixManager.h"
#import "KQBMatrixModel.h"
#import "KQBOmsMatrixModel.h"

@implementation KQBMatrixManager

+ (KQBMatrixManager *)sharedManager{
    static KQBMatrixManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeMatrix;
        [self resetData];
    }
    return self;
}

- (void)resetData{
    [super resetData];
    [self.resDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KQOMSNotificationName(key) object:nil];
    }];
//    [MatrixNotiDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:obj object:nil];
//    }];

    
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeMatrix;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    
    KQBMatrixModel *matrixModel = [[KQBMatrixModel alloc] init];
    matrixModel.resourceId = resId;
    matrixModel.rows = msgContent[@"rows"];
    matrixModel.cols = msgContent[@"cols"];
    matrixModel.isDefault = [msgContent[@"isDefault"] boolValue];
    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsMatrixModel * omsObj = [[KQBOmsMatrixModel alloc] initWithDic:obj[@"ext"]];
        omsObj.resId = resId;
        [self parseBasicModel:omsObj dic:obj[@"ext"]];
        omsObj.resHome = resHome;
        if (omsObj.isAvailable) {
            [tmpArray addObject:omsObj];
        }
    }];
    
    matrixModel.resArray = tmpArray;
    
    if (matrixModel && (matrixModel.resArray.count > 0)) {
        [self.resDic setObject:matrixModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
        if (!msgContent[@"isDefault"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KQOMSNotificationName(resId) object:matrixModel];
        }
    }

}

- (KQBMatrixModel *)getMatrix:(KQBMatrixType)matrixType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)matrixType);
    return (KQBMatrixModel *)[self getResById:resourceIdStr];

}

@end
