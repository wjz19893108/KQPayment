//
//  KQH5CacheManager.m
//  kuaiQianbao
//
//  Created by xy on 16/3/23.
//
//

#import "KQBH5ResourceManager.h"
#import "KQHttpService.h"
#import "KQBCacheManager.h"
@implementation KQBH5CacheUrlInfo

+ (instancetype)urlInfoWithUrl:(NSString *)url desc:(NSString *)desc complete:(BOOL)complete{
    KQBH5CacheUrlInfo *info = [[KQBH5CacheUrlInfo alloc] init];
    info.url = url;
    info.desc = desc;
    info.complete = complete;
    return info;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.desc forKey:@"desc"];
    [aCoder encodeObject:@(self.isComplete) forKey:@"complete"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.desc = [aDecoder decodeObjectForKey:@"desc"];
        self.complete = [[aDecoder decodeObjectForKey:@"complete"] boolValue];
    }
    return self;
}

@end

@interface KQBH5ResourceManager()

@property (nonatomic, strong) NSArray *urlInfoArray; // 所有缓存的数据, 数组元素为KQBH5CacheUrlInfo
@property (nonatomic, strong) NSMutableArray *availableUrlArray; // 有效的缓存
@property (nonatomic, strong) NSMutableArray *downloadingArray; // 当前正在下载的资源列表

@end

@implementation KQBH5ResourceManager

+ (KQBH5ResourceManager *)sharedManager{
    static KQBH5ResourceManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.downloadingArray = [NSMutableArray array];
        self.omsResType = KQBResManagerTypeH5Resource;
        [self resetData];
    }
    return self;
}

- (void)clearCache{
    self.availableUrlArray = nil;
    
    [self.urlInfoArray enumerateObjectsUsingBlock:^(KQBH5CacheUrlInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.complete = NO;
    }];
    [self saveCache];
}

- (void)loadCache{
    [super loadCache];
    self.urlInfoArray = self.resDic[@"urlInfo"];
    if (!self.urlInfoArray) {
        self.urlInfoArray = [NSArray array];
    }
    [self resetAvailableUrlArray];
    [self downloadAllFiles]; // 检测是否有上次未下载成功的文件
}

- (void)saveCache{
    if (!self.urlInfoArray){
        return;
    }
    
    NSDictionary *saveDic = @{@"urlInfo":self.urlInfoArray};
    [KQBCacheManager saveObject:saveDic cacheType:KQCacheTypeH5Resource];
}

- (void)resetAvailableUrlArray{
    self.availableUrlArray = [NSMutableArray array];
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"isComplete = %@", @(YES)];
    NSArray *resultArray = [self.urlInfoArray filteredArrayUsingPredicate:urlPredicate];
    [resultArray enumerateObjectsUsingBlock:^(KQBH5CacheUrlInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![NSString kqc_isBlank:obj.url]) {
            [self.availableUrlArray addObject:obj.url];
        }
    }];
}

- (void)downloadAllFiles{
    NSString *directoryPath = [KQBCacheManager directoryPath:KQCacheTypeH5Resource];
    
    [self.urlInfoArray enumerateObjectsUsingBlock:^(KQBH5CacheUrlInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isComplete) {
            return;
        }
        
        if ([NSString kqc_isBlank:obj.url]) {
            return;
        }
        
        if ([self.downloadingArray containsObject:obj.url]) {
            return;
        }
        [self.downloadingArray addObject:obj.url];
        
        NSString *fileName = [KQBH5ResourceManager fileNameByUrl:obj.url];
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        
        [KQHttpService downloadFileFrom:obj.url toFile:filePath successBlock:^(NSString *responseStr, NSData *responseData) {
            [self.downloadingArray removeObject:obj.url];
            obj.complete = YES;
            [self.availableUrlArray addObject:obj.url];
            [self saveCache];
            
        } failBlock:^(NSError *error) {
            [self.downloadingArray removeObject:obj.url];
            [KQBCacheManager removeCacheFile:fileName cacheType:KQCacheTypeH5Resource];
        }];
    }];
}

- (void)deleteDisableFiles:(NSArray *)fileArray{
    // 异步删除，防止卡主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fileArray enumerateObjectsUsingBlock:^(KQBH5CacheUrlInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *fileName = [KQBH5ResourceManager fileNameByUrl:obj.url];
            [KQBCacheManager removeCacheFile:fileName cacheType:KQCacheTypeH5Resource];
        }];
    });
}

+ (NSString *)fileNameByUrl:(NSString *)url{
    NSString *fileName = [KQCSecure digestWithSHA1:url];
    return fileName;
}

+ (NSData *)cacheDataWithUrl:(NSString *)url{
    NSString *fileName = [KQBH5ResourceManager fileNameByUrl:url];
    NSString *directoryPath = [KQBCacheManager directoryPath:KQCacheTypeH5Resource];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

- (BOOL)isCacheExist:(NSString *)url{
    return [self.availableUrlArray containsObject:url];
}

- (void)updateData:(NSDictionary *)msgContent resId:(NSString *)resId resHome:(NSString *)resHome{
    NSMutableArray *resultArray = [self.urlInfoArray mutableCopy];
    NSMutableArray *deleteArray = [self.urlInfoArray mutableCopy];
    
    [msgContent enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"url = %@", key];
        NSArray *array = [resultArray filteredArrayUsingPredicate:urlPredicate];
        if (array.count == 0) { // 如果本地缓存不存在并且本次不重复，则加入待下载列表
            [resultArray addObject:[KQBH5CacheUrlInfo urlInfoWithUrl:key desc:obj complete:NO]];
        } else { // 已经存在，本次无需做任何操作，从待删除列表里面删除
            [deleteArray removeObjectsInArray:array];
        }
    }];
    
    [resultArray removeObjectsInArray:deleteArray];
    
    self.urlInfoArray = resultArray;
    
    [self resetAvailableUrlArray];
    
    [self saveCache];
    
    [self deleteDisableFiles:deleteArray];
    
    [self downloadAllFiles];
}

- (KQBResManagerType)omsResType{
    return KQBResManagerTypeH5Resource;
}

@end
