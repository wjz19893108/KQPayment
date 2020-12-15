//
//  KQH5CacheManager.h
//  kuaiQianbao
//
//  Created by xy on 16/3/23.
//
//

#import "KQBBaseOmsResManager.h"

#define H5ResourceManager      [KQBH5ResourceManager sharedManager]

@class KQBOmsConfigData;

@interface KQBH5CacheUrlInfo : NSObject<NSCoding>

@property (nonatomic, strong) NSString *url;  // 对应的静态资源链接
@property (nonatomic, strong) NSString *desc; // 对应的静态资源描述
@property (nonatomic, assign, getter=isComplete) BOOL complete; // 是否下载完成

@end

@interface KQBH5ResourceManager : KQBBaseOmsResManager

+ (KQBH5ResourceManager *)sharedManager;

/**
 获取url对应的缓存数据

 @param url 指定的url
 @return 对应的数据
 */
+ (NSData *)cacheDataWithUrl:(NSString *)url;

/**
 是否存在缓存

 @param url 指定url
 @return YES：存在 NO：不存在
 */
- (BOOL)isCacheExist:(NSString *)url;

/**
 清除所有缓存
 */
- (void)clearCache;

@end
