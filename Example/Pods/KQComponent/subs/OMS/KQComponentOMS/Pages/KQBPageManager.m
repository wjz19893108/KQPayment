//
//  KQBPageManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBPageManager.h"
#import "KQBPageModel.h"
#import "KQBCacheManager.h"
#import "KQBOmsPageModel.h"
#import "KQBPageCard.h"
#import "KQBFunctionSwitchManager.h"
#import "KQBPageManageDelegate.h"

static dispatch_semaphore_t pagelock = nil;

//#define Lock() dispatch_semaphore_wait(pagelock, DISPATCH_TIME_FOREVER)
//#define Unlock() dispatch_semaphore_signal(pagelock)

@interface KQBPageManager()

@end

@implementation KQBPageManager

+ (KQBPageManager *)sharedManager{
    static KQBPageManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypePage;
        [self resetData];
        if (!pagelock) {
            pagelock = dispatch_semaphore_create(1);
        }
    }
    return self;
}

- (void)resetData{
    [super resetData];
    //遍历缓存区Page，如果有数据不完整的Page数据，通知PageProcessor获取数据
    self.bufferedResDic = [KQBCacheManager loadObject:KQCacheTypeUserBufferedPage];

    if (!self.bufferedResDic) {
        self.bufferedResDic = [NSMutableDictionary dictionary];
    }
    
    [self.bufferedResDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, KQBPageModel * obj, BOOL * _Nonnull stop) {
        if (obj.pageStatus != KQBPageStatusSuccess) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[PageDataNotiDic objectForKey:obj.resourceId] object:obj];
        }
    }];

    //通知页面刷新正式的Page数据
    [PageNotiDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] postNotificationName:obj object:nil];
    }];
}

- (void)updateOldData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent) {
        return;
    }
    
    KQBPageModel *pageModel = [[KQBPageModel alloc] init];
    
    pageModel.pageNo = msgContent[@"pageNo"];
    pageModel.resourceId = resId;
    
    NSArray *contentArray = msgContent[@"content"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsPageModel *omsObj = [[KQBOmsPageModel alloc] initWithDic:obj
                                                               resHome:resHome
                                                               resFrom:pageModel.pageNo];
        if (!([omsObj.isDisAfterLogin isEqualToString:@"0"] && [ComponentManager.userStatusDelegate isLogin])) {
            [tmpArray addObject:omsObj];
        }
    }];
    
    pageModel.contentArray = tmpArray;
    
    [self.resDic setObject:pageModel forKey:resId];
    [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:[PageNotiDic objectForKey:resId] object:nil];
    
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent) {
        return;
    }
    
    if (![[PageDataNotiDic allKeys] containsObject:resId]) {
        [self updateOldData:msgContent resId:resId resHome:resHome];
        return;
    }
    
    if (self.useDefaultPage) {
        return;//禁用配置数据
    }

    KQBPageModel *pageModel = [[KQBPageModel alloc] init];
    
    pageModel.resourceId = resId;
    pageModel.pageInterface = msgContent[@"pageInterface"];
    NSArray *contentArray = msgContent[@"cards"];
    NSMutableArray *tmpArray = [NSMutableArray array];

    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBPageCard *tmpCard = [[KQBPageCard alloc] initWithDic:obj
                                                         resHome:resHome];
        [tmpArray addObject:tmpCard];
    }];
    pageModel.contentArray = tmpArray;
    [self saveBufferdPageModel:pageModel isUpdate:YES];
}

- (KQBPageStatus)savePageModel:(KQBPageModel *)pageModel {
    KQBPageModel * savedPage = pageModel;
    if (savedPage) {
        // 检查Page中的各Card数据是否完整
        NSPredicate *configPredicate = [NSPredicate predicateWithFormat:@"itemsStatus != %ld", KQBCardResStatusSuccess];
        NSArray *configArray = [savedPage.contentArray filteredArrayUsingPredicate:configPredicate];
        savedPage.pageStatus = (configArray.count > 0)? KQBPageStatusFailed:KQBPageStatusSuccess;
        
        // 存储Page数据
        [self.resDic setObject:savedPage forKey:savedPage.resourceId];
//        Lock();
        [KQBCacheManager saveObject:self.resDic  cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
//        Unlock();
        return savedPage.pageStatus;
    }
    return KQBPageStatusFailed;
}

- (KQBPageStatus)saveBufferdPageModel:(KQBPageModel *)pageModel isUpdate:(BOOL)isUpdate{
    @synchronized (self) {
        KQBPageModel * bufferedPage = pageModel;
        if (bufferedPage) {
            if (!self.bufferedResDic) {
                self.bufferedResDic = [[NSMutableDictionary alloc] init];
            }
            // 检查Page中的各Card数据是否完整
            NSPredicate *configPredicate = [NSPredicate predicateWithFormat:@"itemsStatus != %ld", KQBCardResStatusSuccess];
            NSArray *configArray = [bufferedPage.contentArray filteredArrayUsingPredicate:configPredicate];
            bufferedPage.pageStatus = (configArray.count > 0) ? KQBPageStatusFailed : KQBPageStatusSuccess;
            
            // 存储Page数据
            [self.bufferedResDic setObject:bufferedPage forKey:pageModel.resourceId];
            if (isUpdate) {
                [[NSNotificationCenter defaultCenter] postNotificationName:[PageDataNotiDic objectForKey:bufferedPage.resourceId] object:bufferedPage];
                [self updateBufferedRes:bufferedPage resourceId:pageModel.resourceId]; // 把所有数据保存到本地
            }else{
    //            Lock();
                [KQBCacheManager saveObject:self.bufferedResDic cacheType:KQCacheTypeUserBufferedPage];
    //            Unlock();
            }
            return bufferedPage.pageStatus;
        }
        return KQBPageStatusFailed;
    }
}

- (void)updateBufferedRes:(KQBPageModel *)pageModel resourceId:(NSString *)resourceId {
    if ([NSString kqc_isBlank:resourceId]) {
        return;
    }
    
    if (!pageModel) {
        return;
    }
    
    NSMutableDictionary *bufferedPageDic = [KQBCacheManager loadObject:KQCacheTypeUserBufferedPage];
    if (!bufferedPageDic) {
        bufferedPageDic = [NSMutableDictionary dictionary];
    }
    [bufferedPageDic setObject:pageModel forKey:resourceId];
    [KQBCacheManager saveObject:bufferedPageDic cacheType:KQCacheTypeUserBufferedPage];
}

- (void)updateCardRes:(KQBPageCard *)cardObj pageId:(KQBPageType)pageType{
    if (!cardObj.resObj) {
        return;
    }
    
    NSString *resId = cardObj.resObj.resourceId;
    KQBPageModel *pageModel = [self.resDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)pageType)];
    NSPredicate *configPredicate = [NSPredicate predicateWithFormat:@"resObj.resourceId == %@", resId];
    NSArray *configArray = [pageModel.contentArray filteredArrayUsingPredicate:configPredicate];
    
    if (configArray.count <= 0) {
        return;
    }
    
    KQBPageCard *obj = configArray[0];
    obj = cardObj;
    [self savePageModel:pageModel];
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypePage;
}

- (KQBPageModel *)getPageBy:(KQBPageType)pageType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)pageType);
    return [self.resDic objectForKey:resourceIdStr];;
}

- (KQBPageModel *)getBufferedPageBy:(KQBPageType)pageType{
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)pageType);
    return [self.bufferedResDic objectForKey:resourceIdStr];
}

- (BOOL)useDefaultPage{
   return [FunctionSwitchManager.dynamicAllocationUseDefault isEqualToString:@"1"];
}
@end
