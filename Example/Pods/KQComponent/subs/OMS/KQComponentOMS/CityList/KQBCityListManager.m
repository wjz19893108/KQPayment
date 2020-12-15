//
//  KQBCityListManager.m
//  KQBusiness
//
//  Created by building wang on 2017/12/6.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBCityListManager.h"
#import "KQBCityListModel.h"

@implementation KQBCityListManager

+ (KQBCityListManager *)sharedManager{
    static KQBCityListManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self == [super init]) {
        self.omsResType = KQBResManagerTypeCardList;
        [self resetData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCityId) name:KQCLocationCurrentCityChangedNotification object:nil];
        [self updateCityId];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome {
    if(!msgContent){
        return;
    }
    NSArray *contentArray = msgContent[@"data"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBCityListModel * omsObj = [[KQBCityListModel alloc] initWithDic:obj];
        [tmpArray addObject:omsObj];
    }];
   self.resDic[resId] = tmpArray;
    
    if ((tmpArray.count > 0)) {
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
    }
    
    [self updateCityId];
}

- (void)updateCityId {
    NSArray *dataArry = self.resDic[@"304"];
    if (dataArry.count <= 0) {
        return;
    }
    
    NSString *cityNameString = KQC_Engine_Location.address.city ? : @"上海市";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cityName == %@", cityNameString];
    NSArray *filteredArray = [dataArry filteredArrayUsingPredicate:predicate];
    
    NSString *cityId = @"";
    if (filteredArray.count > 0) {
        KQBCityListModel * omsObj = filteredArray[0];
        cityId = omsObj.cityId;
    }
    KQC_Engine_Location.address.cityId = cityId;
}
@end
