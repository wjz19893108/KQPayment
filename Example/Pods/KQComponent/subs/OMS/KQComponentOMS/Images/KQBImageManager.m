//
//  KQBImageManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBImageManager.h"
#import "KQBImageModel.h"
#import "KQBOmsImageModel.h"

#define CommonImage     @"999"

@implementation KQBImageManager

+ (KQBImageManager *)sharedManager{
    static KQBImageManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.omsResType = KQBResManagerTypeImages;
        [self resetData];
    }
    return self;
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeImages;
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    if(!msgContent){
        return;
    }
    KQBImageModel *imageModel = [[KQBImageModel alloc] init];
    imageModel.resourceId = resId;
    
    NSArray *contentArray = msgContent[@"contentFileList"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    [contentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsImageModel *omsObj = [[KQBOmsImageModel alloc] initWithDic:obj[@"ext"]];
        omsObj.imgPosition = [obj objectForKey:@"position"];
        [self parseBasicModel:omsObj dic:obj[@"ext"]];
        omsObj.resHome = resHome;
        if (omsObj.isAvailable) {
            [tmpArray addObject:omsObj];
        }
    }];
    
    imageModel.resArray = tmpArray;
    
    if (imageModel) {
        [self.resDic setObject:imageModel forKey:resId];
        [KQBCacheManager saveObject:self.resDic cacheType:[[OmsCacheDic objectForKey:KQC_FORMAT(@"%ld",(unsigned long)self.omsResType)] integerValue]];
    }
}

- (KQBOmsImageModel *)getImageByPosition:(NSString *)imagePosition{
    KQBImageModel *imageModel = [self getResById:CommonImage];
    NSArray *othersArray = imageModel.resArray;
    NSPredicate *imagePredicate = [NSPredicate predicateWithFormat:@"imgPosition = %@", imagePosition];
    NSArray *resultArray = [othersArray filteredArrayUsingPredicate:imagePredicate];
    if (resultArray.count > 0) {
        return resultArray[0];
    }
    return nil;
}
@end
