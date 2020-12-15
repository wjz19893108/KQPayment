//
//  KQBSodukoManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBSodukoManager.h"
#import "KQBSodukoModel.h"
#import "KQBOmsSodukoModel.h"
#import "KQBFunctionSwitchManager.h"

@implementation KQBSodukoManager

+ (KQBSodukoManager *)sharedManager{
    static KQBSodukoManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeSoduko;
        [self resetData];
    }
    return self;
}

- (void)resetData{
    [super resetData];
    [SodukoNotiDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:obj object:nil];
    }];

}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeSoduko;
}

-(void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    KQBSodukoModel *sodukoModel = [[KQBSodukoModel alloc] init];
    sodukoModel.resourceId = resId;
    sodukoModel.columnsPerRow = msgContent[@"columnsPerRow"];
    sodukoModel.optionType = msgContent[@"optionType"];
    sodukoModel.isDefault = [msgContent[@"isDefault"] boolValue];
    
    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsSodukoModel *omsObj = [[KQBOmsSodukoModel alloc] initWithDic:obj[@"ext"]];
        omsObj.resId = resId;
        [self parseBasicModel:omsObj dic:obj[@"ext"]];
        omsObj.position = obj[@"position"];
        omsObj.resHome = resHome;
        if (omsObj.isAvailable) {
            [tmpArray addObject:omsObj];
        }
    }];
    sodukoModel.resArray = tmpArray;
    
    if (sodukoModel.columnsPerRow.integerValue  < 1) {
        sodukoModel.columnsPerRow = FunctionSwitchManager.sodukoItemsPerRow;
    }
    
    if (sodukoModel && (sodukoModel.resArray.count > 0)) {
        [self.resDic setObject:sodukoModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
        if (!msgContent[@"isDefault"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[SodukoNotiDic objectForKey:resId] object:sodukoModel];
        }
    }
}

- (KQBSodukoModel *)getSoduko:(KQBSodukoType)sodukoType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)sodukoType);
    return [self getResById:resourceIdStr];
}
@end
