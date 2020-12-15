//
//  KQBCacheManager.m
//  KQBusiness
//
//  Created by pengkang on 2016/10/27.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBCacheManager.h"
#import "KQBCacheEngine.h"
//#import "KQBFileEngine.h"
//#import "KQBOPFileEngine.h"
#if __has_include(<KQCore/KQCoreDatabase.h>)
    #import <KQCore/KQCoreDatabase.h>
#endif

#if __has_include("SDImageCache.h")
    #import "SDImageCache.h"
#endif

@implementation KQBCacheManager

#define KQCacheVersionValue     @"1.1"
#define KQCacheVersionKey       @"CacheVersionKey"

static NSString *DocumentDirectory = nil;
static NSString *KQPublicDirectory = @"Public"; // 公用目录，系统配置相关位于此目录下
static NSString *KQUserDirectory = @"User"; // 公用目录，系统配置相关位于此目录下

static NSDictionary *CacheNameDic = nil;
static NSMutableDictionary *CacheValueDic = nil;
static NSMutableDictionary *CachePathDic = nil;
static NSString *PublicDirPath = nil;
static NSString *UserRootDirPath = nil;
static NSString *CurrentUserDirPath = nil;

static NSMutableDictionary *logFileHandleDic = nil;

static id<KQBCacheSecureDelegate> SecureDelegte = nil;

NSString *KQPageCacheMainPersonInfoKey = @"page_mainPersonInfo";
NSString *KQPageCacheMyInfoKey = @"page_myInfoIndex";
NSString *KQPageCacheCreditKey = @"page_creditIndex";
NSString *KQPageCacheUserInfoKey = @"page_userInfo";
NSString *KQPageCacheAUKey = @"page_aU";

#define kKQCacheDirPath   @"CacheDirPathKey"
#define kKQCacheFilePath  @"CacheFilePathKey"

static NSString *KQPublicAESKey = @"RBTczAZUu0GX/xyNAj3Hg1U5jQjEZkVdmB4go2JUvLAvMmMEQXCevAwN7TU0Xhj0";

+ (void)initializeManager:(id<KQBCacheSecureDelegate>)delegate{
    SecureDelegte = delegate;
    
    [KQBCacheEngine initializeManager];
    
    NSString *lastVersion = [KQBCacheEngine readUserDefaults:KQCacheVersionKey];
    if (![lastVersion isEqualToString:KQCacheVersionValue]) {
        [KQBCacheManager clearLastVersionCache];
        [KQBCacheEngine saveUserDefaults:KQCacheVersionKey value:KQCacheVersionValue];
    }
    
    CacheNameDic = @{@(KQCacheTypeMain):@{kKQCacheDirPath:@"Main", kKQCacheFilePath:@"main.plist"},
                     @(KQCacheTypeOMS):@{kKQCacheDirPath:@"OMS", kKQCacheFilePath:@"omsConfig.plist"},
                     @(KQCacheTypePosOrder):@{kKQCacheDirPath:@"mPosOrder"},
                     @(KQCacheTypePosSignImage):@{kKQCacheDirPath:@"mPosSign"},
                @(KQCacheTypeFunctionSwitch):@{kKQCacheDirPath:@"FunctionSwitch",kKQCacheFilePath:@"functionSwitch.plist"},
                     @(KQCacheTypeH5Resource):@{kKQCacheDirPath:@"H5StaticResource", kKQCacheFilePath:@"resource.plist"},
                     @(KQCacheTypeMessageCenter):@{kKQCacheDirPath:@"MessageCenter", kKQCacheFilePath:@"msgCenter.sqlite"},
                     @(KQCacheTypeStatistics):@{kKQCacheDirPath:@"Statistics"},
                     @(KQCacheTypeDescription):@{kKQCacheDirPath:@"Description", kKQCacheFilePath:@"description.plist"},
                     @(KQCacheTypeSoduko):@{kKQCacheDirPath:@"Soduko", kKQCacheFilePath:@"sodukoConfig.plist"},
                     @(KQCacheTypeUserData):@{kKQCacheDirPath:@"UserData", kKQCacheFilePath:@"UserData.plist"},
                    @(KQCacheTypePromotionResource):@{kKQCacheDirPath:@"PromotionResource", kKQCacheFilePath:@"PromotionResource.html"},
                     @(KQCahceTypeSecureCert):@{kKQCacheDirPath:@"SecureCert", kKQCacheFilePath:@"secureCert.plist"},
                     @(KQCacgeTypeLog):@{kKQCacheDirPath:@"Log"},
                     @(KQCacheTypeStartup):@{kKQCacheDirPath:@"Startup", kKQCacheFilePath:@"startup.plist"},
                     
                     @(KQCahceTypeUserOms):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userOmsConfig.plist"},
                     @(KQCahceTypeUserBanner):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userBanner.plist"},
                     @(KQCacheTypeUserSoduko):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userSoduko.plist"},
                     @(KQCacheTypeUserTab):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userTab.plist"},
                     @(KQCacheTypeUserImages):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userImages.plist"},
                     @(KQCacheTypeUserPage):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userPages.plist"},
                     @(KQCacheTypeUserMatrix):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userMatrix.plist"},
                     @(KQCacheTypeUserCreditProduct):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userCreditProduct.plist"},
                     @(KQCacheTypeUserFall):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userFall.plist"},
                     @(KQCacheTypeUserFinancialProduct):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userFinancialProduct.plist"},
                     @(KQCacheTypeUserPageHeader):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userPageHeader.plist"},
                     @(KQCacheTypeUserBufferedPage):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userBufferedPage.plist"},
                     @(KQCacheTypeUserMultiCard):@{kKQCacheDirPath:@"UserOms", kKQCacheFilePath:@"userMulticard.plist"},
                     @(KQCacheTypeCardList):@{kKQCacheDirPath:@"CardList", kKQCacheFilePath:@"cardList.plist"}};
    
    CacheValueDic = [NSMutableDictionary dictionary];
    
    CachePathDic = [NSMutableDictionary dictionary];
    NSString *rootDir = [KQBCacheManager sandBoxPath];
    
    PublicDirPath = [rootDir stringByAppendingPathComponent:KQPublicDirectory];
    UserRootDirPath = [rootDir stringByAppendingPathComponent:KQUserDirectory];
    
    [KQBCacheManager initializeSubPath:YES];

#if __has_include(<KQCore/KQCoreDatabase.h>)
    // 初始化数据库
    KQC_SharedDatabase.dbPath = [KQBCacheManager filePath:KQCacheTypeMessageCenter];
#endif
}

+ (void)resetUserFolder:(NSString *)userId{
    if ([NSString kqc_isBlank:userId]) {
        CurrentUserDirPath = nil;
        return;
    }
    
    CurrentUserDirPath = [UserRootDirPath stringByAppendingPathComponent:userId];
    [KQBCacheManager initializeSubPath:NO];
}

+ (void)initializeSubPath:(BOOL)isPublicDir{
    NSString *rootPath = isPublicDir ? PublicDirPath : CurrentUserDirPath;
    BOOL isRootPathBlank = [NSString kqc_isBlank:rootPath];
    
    [CacheNameDic enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        if (isPublicDir && [key integerValue] >= KQCacheUserFolderFlag) {
            return;
        }
        
        if (!isPublicDir && [key integerValue] < KQCacheUserFolderFlag) {
            return;
        }
        
        if (!isPublicDir) {
            [CacheValueDic removeObjectForKey:key];
        }
        
        if (isRootPathBlank) {
            [CachePathDic removeObjectForKey:key];
            return;
        }
        
        NSString *dirPath = obj[kKQCacheDirPath];
        NSString *filePath = obj[kKQCacheFilePath];
        
        NSMutableDictionary *tempCachePathDic = [NSMutableDictionary dictionary];
        if (![NSString kqc_isBlank:dirPath]) {
            dirPath = [rootPath stringByAppendingPathComponent:dirPath];
            tempCachePathDic[kKQCacheDirPath] = dirPath;
            
            if (![NSString kqc_isBlank:filePath]) {
                filePath = [dirPath stringByAppendingPathComponent:filePath];
                tempCachePathDic[kKQCacheFilePath] = filePath;
            }
        }
        
        CachePathDic[key] = tempCachePathDic;
    }];
    
    [KQBCacheManager resetAllFolder];
}

+ (void)resetAllFolder{
    [CachePathDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *dirPath = obj[kKQCacheDirPath];
        if (![NSString kqc_isBlank:dirPath]) {
            [KQBFileEngine createDirectory:dirPath];
        }
    }];
}

+ (NSString *)encryptKey:(KQCacheType)cacheType{
    if (cacheType >= KQCacheUserFolderFlag) {
        return nil;
    } else {
        return KQPublicAESKey;
    }
}

+ (NSString *)currentCacheSize{
    long long totalSize = 0;
    totalSize += [KQBCacheManager sizeOfCacheType:KQCacheTypeOMS];
    totalSize += [KQBCacheManager sizeOfCacheType:KQCahceTypeUserOms];
    totalSize += [KQBCacheManager sizeOfCacheType:KQCacheTypeUserData];
    totalSize += [KQBCacheManager sizeOfCacheType:KQCacheTypeMessageCenter];
    totalSize += [KQBCacheManager sizeOfCacheType:KQCacheTypeSoduko];
    totalSize += [KQBCacheManager sizeOfCacheType:KQCacheTypeH5Resource];
    totalSize += [KQBCacheManager sizeOfCacheType:KQCacheTypeDescription];
    
    totalSize += [NSURLCache sharedURLCache].currentDiskUsage;
#if __has_include("SDImageCache.h")
    totalSize += [[SDImageCache sharedImageCache] getSize];
#endif
    
    CGFloat size = totalSize / (1024.0 * 1024.0);
    
    return KQC_FORMAT(@"%.1fM", size);
}

+ (long long)sizeOfCacheType:(KQCacheType)cacheType{
    NSString *omsDir = [KQBCacheManager directoryPath:cacheType];
    return [KQBFileEngine sizeAtPath:omsDir];
}

+ (void)clearAllCache:(void(^)(void))complete{
    [CacheValueDic removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *omsDir = [KQBCacheManager directoryPath:KQCacheTypeOMS];
        [KQBFileEngine removeSubDirectory:omsDir];
        
        NSString *userOmsDir = [KQBCacheManager directoryPath:KQCahceTypeUserOms];
        [KQBFileEngine removeSubDirectory:userOmsDir];
        //        [KQP_Manager_Protocol.omsDelegate resetData];
        
        NSString *messageDataPath = [KQBCacheManager directoryPath:KQCacheTypeMessageCenter];
        [KQBFileEngine removeSubDirectory:messageDataPath];
#if __has_include(<KQCore/KQCoreDatabase.h>)
        [KQC_SharedDatabase resetData];
#endif
        
        NSString *H5ResourcePath = [KQBCacheManager directoryPath:KQCacheTypeH5Resource];
        [KQBFileEngine removeSubDirectory:H5ResourcePath];
        //        [KQP_Manager_Protocol.htmlDelegate clearCache];
        
        NSString *descriptionPath = [KQBCacheManager directoryPath:KQCacheTypeDescription];
        [KQBFileEngine removeSubDirectory:descriptionPath];
        
        NSMutableDictionary *userDic = [[KQBCacheManager loadObject] mutableCopy];
        if (userDic) {
            [userDic removeObjectForKey:KQPageCacheMainPersonInfoKey];
            [userDic removeObjectForKey:KQPageCacheMyInfoKey];
            [userDic removeObjectForKey:KQPageCacheCreditKey];
            [KQBCacheManager saveObject:userDic];
        }
        
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    #if __has_include("SDImageCache.h")
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            complete();
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCacheClearFinish object:nil];
        }];
    #else
        complete();
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCacheClearFinish object:nil];
    #endif
    });
}

+ (void)clearLastVersionCache{
    NSString *sandBox = [KQBCacheManager sandBoxPath];
    [KQBFileEngine removeSubDirectory:sandBox];
}

+ (NSString *)documentDirectory{
    if (!DocumentDirectory) {
        NSArray *directoryArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (directoryArray.count > 0) {
            DocumentDirectory = directoryArray[0];
        }
    }
    return DocumentDirectory;
}

+ (NSString *)sandBoxPath{
    NSString *rootDir = [KQBCacheManager documentDirectory];
    rootDir = [rootDir stringByAppendingPathComponent:[KQBCacheEngine environmentName]];
    return rootDir;
}

+ (NSString *)directoryPath:(KQCacheType)cacheType{
    NSDictionary *cachePathDic = CachePathDic[@(cacheType)];
    return cachePathDic[kKQCacheDirPath];
}

+ (NSString*)filePath:(KQCacheType)cacheType{
    NSDictionary *cachePathDic = CachePathDic[@(cacheType)];
    return cachePathDic[kKQCacheFilePath];
}

+ (BOOL)saveObject:(id)object{
    return [KQBCacheManager saveObject:object cacheType:KQCacheTypeUserData agentType:KQBCacheAgentTypePlist];
}

+ (BOOL)saveObject:(id)object cacheType:(KQCacheType)cacheType{
    return [KQBCacheManager saveObject:object cacheType:cacheType agentType:KQBCacheAgentTypePlist];
}

+ (BOOL)saveObject:(id)object cacheType:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType{
    if (!object) {
        [CacheValueDic removeObjectForKey:@(cacheType)];
    } else {
        CacheValueDic[@(cacheType)] = object;
    }
    
    NSString *filePath = [KQBCacheManager filePath:cacheType];
    if ([NSString kqc_isBlank:filePath]) {
        return NO;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    if (!data) {
        return NO;
    }
    
    NSString *key = [KQBCacheManager encryptKey:cacheType];
    
    NSString *encryptStr = nil;
    if (key) {
        encryptStr = [KQCSecure encryptData:data aes256Key:key];
    } else {
        if (SecureDelegte && [SecureDelegte respondsToSelector:@selector(encryptDataByAES:)]) {
            encryptStr = [SecureDelegte encryptDataByAES:data];
        } else {
            encryptStr = [data base64EncodedString];
        }
    }
    if ([NSString kqc_isBlank:encryptStr]) {
        return NO;
    }
    return [KQBCacheEngine saveObject:encryptStr path:filePath agentType:[KQBCacheManager convertType:agentType]];
}

+ (BOOL)saveValue:(id)value forKey:(NSString *)key{
    return [KQBCacheManager saveValue:value forKey:key cacheType:KQCacheTypeUserData agentType:KQBCacheAgentTypePlist];
}

+ (BOOL)saveValue:(id)value forKey:(NSString *)key cacheType:(KQCacheType)cacheType{
    return [KQBCacheManager saveValue:value forKey:key cacheType:cacheType agentType:KQBCacheAgentTypePlist];
}

+ (BOOL)saveValue:(id)value forKey:(NSString *)key cacheType:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType{
    if ([NSString kqc_isBlank:key]) {
        DLog(@"key is null, cacheType:%@", @(cacheType));
        return NO;
    }
    
    NSMutableDictionary *objectDic = nil;
    id object = [KQBCacheManager loadObject:cacheType agentType:agentType];
    
    if (!object) {
        objectDic = [NSMutableDictionary dictionary];
    } else if ([object isKindOfClass:[NSDictionary class]]){
        objectDic = [object mutableCopy];
    } else {
        DLog(@"target is not a dic cacheType:%@", @(cacheType));
        return NO;
    }
    
    if (value) {
        objectDic[key] = value;
    } else {
        [objectDic removeObjectForKey:key];
    }
    
    CacheValueDic[@(cacheType)] = objectDic;
    return [KQBCacheManager saveObject:objectDic cacheType:cacheType agentType:agentType];
}

+ (id)loadObject{
    return [KQBCacheManager loadObject:KQCacheTypeUserData agentType:KQBCacheAgentTypePlist];
}

+ (id)loadObject:(KQCacheType)cacheType{
    return [KQBCacheManager loadObject:cacheType agentType:KQBCacheAgentTypePlist];
}

+ (id)loadObject:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType{
    id obj = CacheValueDic[@(cacheType)];
    if (obj) {
        return obj;
    }
    
    NSString *filePath = [KQBCacheManager filePath:cacheType];
    
    NSString *encryptStr = [KQBCacheEngine loadObjectFrom:filePath agentType:[KQBCacheManager convertType:agentType]];
    
    if ([NSString kqc_isBlank:encryptStr]) {
        return nil;
    }
    
    NSString *key = [KQBCacheManager encryptKey:cacheType];
    
    NSData *data = nil;
    if (key) {
        data = [KQCSecure decryptData:encryptStr aes256Key:key];
    } else {
        if (SecureDelegte && [SecureDelegte respondsToSelector:@selector(decryptDataByAES:)]) {
            data = [SecureDelegte decryptDataByAES:encryptStr];
        } else {
            data = [NSData dataFromBase64String:encryptStr];
        }
    }
    
    if (!data) {
        return nil;
    }
    
    obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (obj) {
        CacheValueDic[@(cacheType)] = obj;
    }
    return obj;
}

+ (id)loadValueForKey:(NSString *)key{
    return [KQBCacheManager loadValueForKey:key cacheType:KQCacheTypeUserData agentType:KQBCacheAgentTypePlist];
}

+ (id)loadValueForKey:(NSString *)key cacheType:(KQCacheType)cacheType{
    return [KQBCacheManager loadValueForKey:key cacheType:cacheType agentType:KQBCacheAgentTypePlist];
}

+ (id)loadValueForKey:(NSString *)key cacheType:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType{
    if ([NSString kqc_isBlank:key]) {
        DLog(@"key is null, cacheType:%@", @(cacheType));
        return nil;
    }
    
    id object = [KQBCacheManager loadObject:cacheType agentType:agentType];
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return object[key];
}

+ (void)clearObject:(KQCacheType)cacheType{
    [CacheValueDic removeObjectForKey:@(cacheType)];
    
    NSString *filePath = [KQBCacheManager filePath:cacheType];
    [KQBCacheEngine clearObject:filePath];
}

+ (void)clearValueForKey:(NSString *)key cacheType:(KQCacheType)cacheType{
    [KQBCacheManager saveValue:nil forKey:key cacheType:cacheType agentType:KQBCacheAgentTypePlist];
}

+ (void)clearValueForKey:(NSString *)key cacheType:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType{
    [KQBCacheManager saveValue:nil forKey:key cacheType:cacheType agentType:agentType];
}

+ (void)removeCacheFile:(NSString *)fileName cacheType:(KQCacheType)cacheType{
    [CacheValueDic removeObjectForKey:@(cacheType)];
    if ([NSString kqc_isBlank:fileName]) {
        return;
    }
    
    NSString *directoryPath = [KQBCacheManager directoryPath:cacheType];
    if ([NSString kqc_isBlank:directoryPath]) {
        return;
    }
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    [KQBCacheEngine removeCacheFileAt:filePath];
}

+ (void)removeDirectory:(NSString *)directoryPath cacheType:(KQCacheType)cacheType{
    [CacheValueDic removeObjectForKey:@(cacheType)];
    if ([NSString kqc_isBlank:directoryPath]) {
        return;
    }
    NSString *rootDirectoryPath = [KQBCacheManager directoryPath:cacheType];
    [KQBCacheEngine removeDirectory:rootDirectoryPath];
}

+ (void)saveCacheFile:(NSString *)fileName data:(NSData *)data cacheType:(KQCacheType)cacheType{
    if ([NSString kqc_isBlank:fileName]
        || !data) {
        return;
    }
    
    NSString *directoryPath = [KQBCacheManager directoryPath:cacheType];
    if (![KQBFileEngine createDirectory:directoryPath]) {
        return;
    }
    [KQBCacheEngine saveCacheFile:fileName data:data directoryPath:directoryPath];
}

+ (NSString *)readUserId{
    NSString *encryptId = [KQBCacheEngine readUserDefaults:@"temp0001"];
    NSString *userId = [KQCSecure decrypt:encryptId aes256Key:KQPublicAESKey];
    return userId;
}

+ (void)saveUserId:(NSString *)userId{
    NSString *encryptId = [KQCSecure encrypt:userId aes256Key:KQPublicAESKey];
    [KQBCacheEngine saveUserDefaults:@"temp0001" value:encryptId];
}

/**
 *  缓存文件持续读写，追加写
 *
 *  @param content    追加内容
 *  @param fileName   文件名
 *  @param cacheType  缓存类型
 */
+ (void)cacheLivingFileAppend:(NSData *)content fileName:(NSString *)fileName cacheType:(KQCacheType)cacheType {
    if ([NSString kqc_isBlank:fileName]) {
        return;
    }
    
    dispatch_async([KQBCacheManager cacheLivingFileQueue], ^{
        NSString *filePath = [[KQBCacheManager directoryPath:cacheType] stringByAppendingPathComponent:fileName];
        KQBOPFileEngine *fileOPManager = [KQBCacheManager cacheLivingFileHandle:cacheType];
        if ( !fileOPManager || [NSString kqc_isBlank:fileOPManager.filePath] || ![fileOPManager.filePath isEqualToString:filePath]) {
            [KQBCacheManager cacheLivingFileOpen:filePath cacheType:cacheType];
        }
        
        [KQBCacheManager cacheLivingFileAppend:content cacheType:cacheType];
    });
}

/**
 *  缓存文件目前写入大小
 *
 *  @param cacheType 缓存类型
 *
 *  @return 大小
 */
+ (unsigned long long)cacheLivingFileSize:(KQCacheType)cacheType {
    __block unsigned long long ofset = 0;
    dispatch_sync([KQBCacheManager cacheLivingFileQueue], ^{
        KQBOPFileEngine *fileOPManager = [KQBCacheManager cacheLivingFileHandle:cacheType];
        if (fileOPManager) {
            ofset = [fileOPManager size];
        }
        
    });
    
    return ofset;
}

/**
 *  打开持久文件，创建文件操作句柄
 *
 *  @param fileName  文件名
 *  @param cacheType 缓存类型
 */
+ (void)cacheLivingFileOpen:(NSString *)fileName cacheType:(KQCacheType)cacheType {
    if (!logFileHandleDic) {
        logFileHandleDic = [NSMutableDictionary dictionary];
    }
    
    if ([NSString kqc_isBlank:fileName]) {
        return;
    }
    
    [KQBCacheManager cacheLivingFileClose:cacheType];
    
    KQBOPFileEngine *fileOPManager = [[KQBOPFileEngine alloc] initWithFilePath:fileName];
    if (fileOPManager) {
        [logFileHandleDic setObject:fileOPManager forKey:[NSString stringWithFormat:@"%ld", (long)cacheType]];
    }
}

/**
 *  关闭持久文件，释放文件句柄
 *
 *  @param cacheType 缓存类型
 */
+ (void)cacheLivingFileClose:(KQCacheType)cacheType {
    if (!logFileHandleDic) {
        return;
    }
    
    KQBOPFileEngine *fileOPManager = [KQBCacheManager cacheLivingFileHandle:cacheType];
    if (fileOPManager) {
        [fileOPManager close];
        [logFileHandleDic removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)cacheType]];
    }
    
}

/**
 *  追加写入文件
 *
 *  @param content   写入内容
 *  @param cacheType 缓存类型
 */
+ (void)cacheLivingFileAppend:(NSData *)content cacheType:(KQCacheType)cacheType {
    KQBOPFileEngine *fileOPManager = [KQBCacheManager cacheLivingFileHandle:cacheType];
    if (fileOPManager && content && [content length] > 0) {
        [fileOPManager appendData:content];
    }
}


/**
 *  获取文件操作对象
 *
 *  @param cacheType 缓存类型
 *
 *  @return KQBOPFileEngine 实例
 */
+ (KQBOPFileEngine *)cacheLivingFileHandle:(KQCacheType)cacheType {
    KQBOPFileEngine *fileOPManager = [logFileHandleDic objectForKey:[NSString stringWithFormat:@"%ld", (long)cacheType]];
    if ([fileOPManager isKindOfClass:[KQBOPFileEngine class]]) {
        return fileOPManager;
    }
    return nil;
}

/**
 *  持续文件写入的串行队列
 *
 *  @return 队列
 */
+ (dispatch_queue_t)cacheLivingFileQueue {
    static dispatch_queue_t sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = dispatch_queue_create("KQBCacheManagerLivingFileQueue", NULL);
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        dispatch_set_target_queue(sharedQueue, globalQueue);
    });
    return sharedQueue;
}

+ (KQCacheAgentType)convertType:(KQBCacheAgentType) resType{
    switch (resType) {
        case KQBCacheAgentTypePlist:
            return KQCacheAgentTypePlist;
            break;
        case KQBCacheAgentTypeDatabase:
            return KQCacheAgentTypeDatabase;
            break;
    }
}

@end
