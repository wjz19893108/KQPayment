//
//  KQBOmsManage.m
//  KQBusiness
//
//  Created by pengkang on 2016/10/21.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQPOmsManager.h"
#import "KQPOmsMacro.h"
#import "KQPOmsTool.h"
#import "KQBOmsConfigData.h"
#import "KQBFunctionSwitchManager.h"
#import "KQBBannerManager.h"
#import "KQBSodukoManager.h"
#import "KQBPageManager.h"
#import "KQBImageManager.h"
#import "KQBStartupPageManager.h"
#import "KQBTabManager.h"
#import "KQBCardManager.h"
#import "KQBCityListManager.h"

@implementation KQPOmsManager
{
    NSString *directoryPath;
    NSMutableArray *downloadingArray; // 当前正在下载的资源列表
}

SYNTHESIZE_SINGLETON_FOR_CLASS(KQPOmsManager);
- (instancetype)init{
    self = [super init];
    if (self) {
        downloadingArray = [NSMutableArray array];
        [self resetData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redispatchRes:) name:@"OmsResNotFound" object:nil];
    }
    return self;
}
#pragma mark - 基础操作

/// 初始化文件
- (void)resetData{
    self.plistDic = [[KQBCacheManager loadObject:KQCahceTypeUserOms] mutableCopy];
    if (!self.plistDic) {
        self.plistDic = [NSMutableDictionary dictionary];
    }
    directoryPath = [KQBCacheManager directoryPath:KQCahceTypeUserOms];
}

/// 更新缓存的配置
- (void)updateConfigData:(KQBOmsConfigData *)configModel{
    if (!configModel) {
        return;
    }
    [self.plistDic setObject:configModel forKey:configModel.resourceId];
    [KQBCacheManager saveObject:self.plistDic cacheType:KQCahceTypeUserOms];
}

#pragma mark - 下载在线资源
- (void)downloadOmsResByDic:(NSDictionary *)downloadDic{
    if (downloadDic.count < 1) {
        return;
    }
    
    [downloadDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, KQBOmsConfigData *obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[KQBOmsConfigData class]]) {
            if ( obj.resStatus &&([obj.resStatus integerValue] != KQOmsResStatusComplete)) {
                [self handleAllUpdate:obj];
            } else {
                NSString *fileName = [KQPOmsTool resName:obj.resourceUrl];
                NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
                
                if (![KQBFileEngine fileExist:filePath]){
                    [self handleAllUpdate:obj];
                }
            }
        }
    }];
}


- (void)downloadOmsRes:(KQBOmsConfigData *)obj{
    if (!obj) {
        return;
    }
    
    if ([obj isKindOfClass:[KQBOmsConfigData class]]) {
        if ( obj.resStatus &&([obj.resStatus integerValue] != KQOmsResStatusComplete)) {
            [self handleAllUpdate:obj];
        } else {
            NSString *fileName = [KQPOmsTool resName:obj.resourceUrl];
            NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
            
            if (![KQBFileEngine fileExist:filePath]){
                [self handleAllUpdate:obj];
            }
        }
    }
}

- (void)downloadPromotionRes{
    NSString *url = FunctionSwitchManager.promotionAfterRegister;
    NSString *path = [KQBCacheManager filePath:KQCacheTypePromotionResource];
    if ([NSString kqc_isBlank:url] || !path) {
        return;
    }
    NSString *oldUrl = [KQBCacheManager loadValueForKey:@"AfterRegisterPromotionUrl" cacheType:KQCacheTypeMain];
    if ([url isEqualToString:oldUrl]) {
        return;
    }
    [KQPOmsTool downloadResZipFrom:FunctionSwitchManager.promotionAfterRegister toFile:path successBlock:^{
        [KQBCacheManager saveValue:url forKey:@"AfterRegisterPromotionUrl" cacheType:KQCacheTypeMain];
    } failedBlock:^(NSInteger resStatus) {
        
    }];
}
#pragma mark - 向OMS请求资源
- (void)requestOmsUserRes{
    NSString *resolution = KQC_FORMAT(@"%@x%@",@(KQC_SCREEN_WIDTH),@(KQC_SCREEN_HEIGHT));
    if (KQC_SCREEN_HEIGHT > 812) {
        resolution = @"414x736";
    }
    NSDictionary *dic = @{@"resolution":resolution,
                          @"resourceId":@"0"};
    
    [KQHttpService request:dic bizType:@"M264" successBlock:^(id response) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endRefreshingForHomePage" object:nil];
        [self setOmsConfigData:response];
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endRefreshingForHomePage" object:nil];
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
    
    [self downloadOmsResByDic:self.plistDic];
}

- (void)requestOmsPublicRes{
    
    NSDictionary *requestDic = @{@"publishNo":@"0"};
    [KQHttpService request:requestDic bizType:@"M255" successBlock:^(Content *response) {
        [self setM255ConfigData:response];
    } failedBlock:^(NSString *errorCode, NSString *errorMessage, id response) {
        
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
    [self downloadOmsResByDic:self.plistDic];
}

#pragma mark - 解析OMS数据
///解析M264数据
- (void)setOmsConfigData:(Content *)response{
    if (!response) {
        return;
    }
    NSMutableDictionary *origDic = [self.plistDic mutableCopy];
    NSMutableDictionary *deleteDic = [self.plistDic mutableCopy];
    
    [response.resourceInfo enumerateObjectsUsingBlock:^(ContentResourceInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsConfigData *origModel = [origDic objectForKey:obj.resourceId];
        
        if (origModel) {
            [deleteDic removeObjectForKey:obj.resourceId];
        }
        
        if ([origModel.md5 isEqualToString:obj.md5]) {
            ///资源未更新
            return;
        }
        ///本地缓存没有对应资源，或者资源更新
        KQBOmsConfigData *configModel = [[KQBOmsConfigData alloc] initWithObj:obj];
        if(!configModel){
            return;
        }
        configModel.resFrom = Oms264Res;
        configModel.resStatus = KQC_FORMAT(@"%ld", (unsigned long)KQOmsResStatusNoStart);
        [origDic setObject:configModel forKey:configModel.resourceId];
    }];
    
    self.plistDic = origDic;

    [self removeUnusedRes:Oms264Res deleteDic:deleteDic originDic:self.plistDic];
    
    [self downloadOmsResByDic:self.plistDic];
}

///解析M255数据
- (void)setM255ConfigData:(Content *)response{
    if (!response) {
        return;
    }
    NSMutableDictionary *origDic = [self.plistDic mutableCopy];
    NSMutableDictionary *deleteDic = [self.plistDic mutableCopy];
    
    [response.commonZipInfo enumerateObjectsUsingBlock:^(ContentCommonZipInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBOmsConfigData *origModel = [origDic objectForKey:obj.commonZipId];
        
        if (origModel) {
            [deleteDic removeObjectForKey:obj.commonZipId];
        }
        
        if ([origModel.md5 isEqualToString:obj.md5]) {
            ///资源未更新
            
            return;
        }
        ///本地缓存没有对应资源，或者资源更新
        KQBOmsConfigData *configModel = [[KQBOmsConfigData alloc] initWithZip:obj];
        configModel.resFrom = Oms255Res;
        if(!configModel){
            return;
        }
        
        configModel.resStatus = KQC_FORMAT(@"%ld", (unsigned long)KQOmsResStatusNoStart);
        
        [origDic setObject:configModel forKey:configModel.resourceId];
    }];
    
    self.plistDic = origDic;
    
    [self removeUnusedRes:Oms255Res deleteDic:deleteDic originDic:self.plistDic];
    
    [self downloadOmsResByDic:self.plistDic];
    
    [self downloadPromotionRes];
}

///处理数据
- (void)handleAllUpdate:(KQBOmsConfigData *)configModel{
    if ([downloadingArray containsObject:configModel.resourceUrl]) {
        return;
    }
    
    [downloadingArray addObject:configModel.resourceUrl];
    
    NSString *fileName = [KQPOmsTool resName:configModel.resourceUrl];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    configModel.resStatus = KQC_FORMAT(@"%ld", (unsigned long)KQOmsResStatusDownloading);
    [KQPOmsTool downloadResZipFrom:configModel.resourceUrl toFile:filePath successBlock:^{
        [downloadingArray removeObject:configModel.resourceUrl];
        if (![KQBFileEngine compareMD5WithFile:filePath MD5:configModel.md5]) {
            [KQBCacheManager removeCacheFile:fileName cacheType:KQCahceTypeUserOms];
            return;
        }
        configModel.resStatus = KQC_FORMAT(@"%ld", (unsigned long)KQOmsResStatusComplete);
        configModel.resourceDirectory = [KQPOmsTool resDirectory:configModel.resourceUrl];
        
        KQBOmsConfigData *localConfigModel = [self.plistDic objectForKey:configModel.resourceId];
        
        if (localConfigModel) {
            //删除老的资源包
            if (![[KQPOmsTool resName:localConfigModel.resourceUrl] isEqualToString:fileName]) {
                [KQBCacheManager removeCacheFile:[KQPOmsTool resName:localConfigModel.resourceUrl] cacheType:KQCahceTypeUserOms];
                [KQBCacheManager removeDirectory:localConfigModel.resourceDirectory cacheType:KQCahceTypeUserOms];
            }
        }
        
        //更新本地存储
        [self updateConfigData:configModel];
        NSString *MD5Value = [KQPOmsTool calcStrMD5:[self jsonConfigPath:configModel]];
        [KQBCacheManager saveValue:MD5Value forKey:configModel.resourceId cacheType:KQCacheTypeMain];
        
        //资源分发
        [self addOMSRes:configModel];
    } failedBlock:^(NSInteger resStatus) {
        [downloadingArray removeObject:configModel.resourceUrl];
        configModel.resStatus = KQC_FORMAT(@"%ld", (unsigned long)resStatus);
        [self updateConfigData:configModel];
    }];
}

#pragma mark - OMS Tools
- (nullable KQBOmsConfigData *)getConfigData:(nonnull NSString *)resIdStr {
    return [self.plistDic objectForKey:resIdStr];
}

- (NSString *)jsonConfigPath:(KQBOmsConfigData *)configModel{
    return [[directoryPath stringByAppendingPathComponent:configModel.resourceDirectory] stringByAppendingPathComponent:@"config.json"];
}

- (NSDictionary *)getOmsResourceById:(NSInteger)resourceId {
    
    NSString *resourceIdStr = KQC_FORMAT(@"%ld", (unsigned long)resourceId);
    KQBOmsConfigData *configModel = [self getConfigData:resourceIdStr];
    
    if (!configModel.resourceDirectory) {
        return nil;
    }
    NSDictionary *dic = [KQBFileEngine parseConfigFile:[self jsonConfigPath:configModel]];
    
    NSString *MD5Value = [KQPOmsTool calcStrMD5:[self jsonConfigPath:configModel]];
    NSString *cacheMD5 = [KQBCacheManager loadValueForKey:resourceIdStr cacheType:KQCacheTypeMain];
    
    if (![cacheMD5 isEqualToString:MD5Value]) { //校验config文件是否被篡改
        NSString *fileName = [KQPOmsTool resName:configModel.resourceUrl];
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        
        if ([KQBFileEngine compareMD5WithFile:filePath MD5:configModel.md5]) { //校验zip文件是否被篡改
            //解压本地zip，无需重复下载
            
            BOOL unzipResult = [KQBFileEngine unZipFile:filePath to:[[filePath componentsSeparatedByString:@"."] firstObject]];
            
            if(unzipResult) {
                NSString *MD5Value = [KQPOmsTool calcStrMD5:[self jsonConfigPath:configModel]];
                [KQBCacheManager saveValue:MD5Value forKey:configModel.resourceId cacheType:KQCacheTypeMain];
                return [self getOmsResourceById:resourceId];
            }
        }
        // zip文件以及config文件均被篡改，重新下载
        configModel.resStatus = KQC_FORMAT(@"%ld", (unsigned long)KQOmsResStatusNoStart);
        [self updateConfigData:configModel];
        
        [KQBCacheManager removeCacheFile:fileName cacheType:KQCahceTypeUserOms];
        [self downloadOmsRes:configModel];
        
        return nil;
    }
    
    return dic;
}

- (void)removeUnusedItems:(NSString *)resFrom
                deleteDic:(NSDictionary *)dict{
    NSMutableDictionary *deleteDic = [dict mutableCopy];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, KQBOmsConfigData *_Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj.resFrom isEqualToString:resFrom]) {
            [deleteDic removeObjectForKey:key];
        }
    }];
    
    if (deleteDic.count > 0) {
        [self.plistDic removeObjectsForKeys:[deleteDic allKeys]];
        
        [KQBCacheManager saveObject:self.plistDic cacheType:KQCahceTypeUserOms];
        
        [KQPOmsTool deleteDisableFiles:deleteDic];
    }
    
}

- (void)removeUnusedRes:(NSString *)resFrom
                deleteDic:(NSDictionary *)dict
                originDic:(NSMutableDictionary *)origDic{
    [self removeUnusedItems:resFrom deleteDic:dict];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, KQBOmsConfigData *obj, BOOL * _Nonnull stop) {
         if ([obj.resFrom isEqualToString:resFrom]) {
             [self removeOMSRes:obj];
         }
    }];

}

- (void)resetResData{
    [self resetData];
    [BannerManager resetData];
    [SodukoManager resetData];
    [PageManager resetData];
    [ImageManager resetData];
    [StartupManager resetData];
    [TabManager resetData];
    [MultiCardManager resetData];
    [CityListManager resetData];
}

- (void)addOMSRes:(KQBOmsConfigData *)configModel {
    NSString *className = [self judgeResType:configModel];
    
    Class handlerClass = NSClassFromString(className);
    
    [(KQBBaseOmsResManager *)[handlerClass sharedManager] updateData:[self getOmsResourceById:configModel.resourceId.integerValue] resId:configModel.resourceId resHome:[KQPOmsTool resDirectory:configModel.resourceUrl]];
}

- (void)removeOMSRes:(KQBOmsConfigData *)configModel{
    NSString *className = [self judgeResType:configModel];
    
    Class handlerClass = NSClassFromString(className);
    
    [(KQBBaseOmsResManager *)[handlerClass sharedManager] removeResById:configModel.resourceId];

}
- (NSString *)judgeResType:(KQBOmsConfigData *)configModel{
    NSString *className;
    
    switch ([configModel.resourceType integerValue]) {
        case KQOmsTypeBanner:
            className = @"KQBBannerManager";
            break;
        case KQOmsTypeStartupPage:
            className = @"KQBStartupPageManager";
            break;
        case KQOmsTypeSoduko:
            className = @"KQBSodukoManager";
            break;
        case KQOmsTypeOldPage:
            className = @"KQBPageManager";
            break;
        case KQOmsTypeTab:
            className = @"KQBTabManager";
            break;
        case KQOmsTypeImage:
            className = @"KQBImageManager";
            break;
        case KQOmsTypeDescription:
            className = @"KQBDescriptionManager";
            break;
        case KQOmsTypeFunctionSwitch:
            className = @"KQBFunctionSwitchManager";
            break;
        case KQOmsTypeH5Resource:
            className = @"KQBH5ResourceManager";
            break;
        case KQOmsTypeMatrix:
            className = @"KQBMatrixManager";
            break;
        case KQOmsTypePageHeader:
            className = @"KQBPageHeaderManager";
            break;
        case KQOmsTypeCreditProduct:
            className = @"KQBCreditProductManager";
            break;
        case KQOmsTypeDynamicPage:
            className = @"KQBPageManager";
            break;
        case KQOmsTypeDynamicCard:
            className = @"KQBCardManager";
            break;
        case KQOmsTypeCityList:
            className = @"KQBCityListManager";
            break;

        default:
            break;
    }
    
    return className;
}

- (void)redispatchRes:(NSNotification *)notification {
    NSString*resourceId = notification.object;
    KQBOmsConfigData *configData = [self.plistDic objectForKey:resourceId];
    if (configData && [configData.resStatus isEqualToString:KQC_FORMAT(@"%ld", (unsigned long)KQOmsResStatusComplete)]) {
        [self addOMSRes:configData];
    }
}

- (NSString *)getMD5ById:(NSString *)resId{
    KQBOmsConfigData *configData = [self.plistDic objectForKey:resId];
    return configData.md5;
}

- (KQBOmsConfigData *)getOMSConfigById:(NSString *)resId{
    return [self.plistDic objectForKey:resId];
}

- (nullable NSString *)getImageDefaultRes:(nonnull NSString *)resId imageName:(nonnull NSString *)imageName{
    if ([NSString  kqc_isBlank:resId]) {
        return nil;
    }
    NSArray *images = [imageName componentsSeparatedByString:@"/"];
    NSString *resName = KQC_FORMAT(@"%@_%@", resId,[images lastObject]);
    return resName;
}
@end
