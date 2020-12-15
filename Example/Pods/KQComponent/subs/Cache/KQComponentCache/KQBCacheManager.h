//
//  KQBCacheManager.h
//  KQBusiness
//
//  Created by pengkang on 2016/10/27.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQBCacheSecureDelegate.h"
#import "KQBCacheMacro.h"

@interface KQBCacheManager : NSObject

/**
 *  初始化缓存目录
 */
+ (void)initializeManager:(id<KQBCacheSecureDelegate>)delegate;

/**
 *  重新设置用户目录
 *
 *  @param userId 用户唯一标识
 */
+ (void)resetUserFolder:(NSString *)userId;

/**
 *  删除指定缓存类型下的文件
 *
 *  @param fileName  文件名
 *  @param cacheType 缓存类型
 */
+ (void)removeCacheFile:(NSString *)fileName cacheType:(KQCacheType)cacheType;

/**
 *  删除指定缓存类型下的目录
 *
 *  @param directoryPath 目录路径
 *  @param cacheType     缓存类型
 */
+ (void)removeDirectory:(NSString *)directoryPath cacheType:(KQCacheType)cacheType;

/**
 *  获取指定缓存类型的配置文件路径
 *
 *  @param cacheType 缓存类型
 *
 *  @return 配置文件路径
 */
+ (NSString *)filePath:(KQCacheType)cacheType;

/**
 *  获取指定缓存类型的文件根目录
 *
 *  @param cacheType 缓存类型
 *
 *  @return 目录路径
 */
+ (NSString *)directoryPath:(KQCacheType)cacheType;

/**
 *  将数据保存到指定缓存目录下的指定文件名
 *
 *  @param fileName  保存文件名
 *  @param data      待保存数据
 *  @param cacheType 缓存类型
 */
+ (void)saveCacheFile:(NSString *)fileName data:(NSData *)data cacheType:(KQCacheType)cacheType;

/**
 *  清除所有缓存
 *
 *  @param complete 清除完成后的回调
 */
+ (void)clearAllCache:(void(^)(void))complete;

/**
 *  计算当前缓存大小 单位:M
 *
 *  @return 缓存大小
 */
+ (NSString *)currentCacheSize;

/**
 *  覆盖存储KQCacheTypeUserData的整个数据
 *
 *  @param object 整体对象，需要实现NSCoding协议
 *
 *  @return 失败 or 成功
 */
+ (BOOL)saveObject:(id)object;

/**
 *  覆盖存储指定类型的整个数据
 *
 *  @param object    整体对象，需要实现NSCoding协议
 *  @param cacheType 缓存类型
 *
 *  @return 失败 or 成功
 */
+ (BOOL)saveObject:(id)object cacheType:(KQCacheType)cacheType;

/**
 *  覆盖存储指定类型的整个数据
 *
 *  @param object    整体对象，需要实现NSCoding协议
 *  @param cacheType 缓存类型
 *  @param agentType 缓存介质
 *  @return 失败 or 成功
 */
+ (BOOL)saveObject:(id)object cacheType:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType;

/**
 *  存储KQCacheTypeUserData的指定key数据
 *
 *  @param value     数据，需要实现NSCoding协议
 *  @param key       指定key
 *
 *  @return 失败 or 成功
 */
+ (BOOL)saveValue:(id)value forKey:(NSString *)key;

/**
 *  存储指定类型的指定key数据
 *
 *  @param value     数据，需要实现NSCoding协议
 *  @param key       指定key
 *  @param cacheType 缓存类型
 *
 *  @return 失败 or 成功
 */
+ (BOOL)saveValue:(id)value forKey:(NSString *)key cacheType:(KQCacheType)cacheType;

/**
 *  存储指定类型的指定key数据
 *
 *  @param value     数据，需要实现NSCoding协议
 *  @param key       指定key
 *  @param cacheType 缓存类型
 *  @param agentType 缓存介质
 *  @return 失败 or 成功
 */
+ (BOOL)saveValue:(id)value forKey:(NSString *)key cacheType:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType;


/**
 *  读取KQCacheTypeUserData的完整数据
 *
 *  @return 目标缓存数据
 */
+ (id)loadObject;

/**
 *  读取指定类型的完整数据
 *
 *  @param cacheType 缓存类型
 *
 *  @return 目标缓存数据
 */
+ (id)loadObject:(KQCacheType)cacheType;

/**
 *  读取指定类型的完整数据
 *
 *  @param cacheType 缓存类型
 *  @param agentType 缓存介质
 *  @return 目标缓存数据
 */
+ (id)loadObject:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType;

/**
 *  加载KQCacheTypeUserData指定key的数据
 *
 *  @param key       指定key
 *
 *  @return 目标缓存数据
 */
+ (id)loadValueForKey:(NSString *)key;

/**
 *  加载指定类型指定key的数据
 *
 *  @param key       指定key
 *  @param cacheType 缓存类型
 *
 *  @return 目标缓存数据
 */
+ (id)loadValueForKey:(NSString *)key cacheType:(KQCacheType)cacheType;

/**
 *  加载指定类型指定key的数据
 *
 *  @param key       指定key
 *  @param cacheType 缓存类型
 *  @param agentType 缓存介质
 *  @return 目标缓存数据
 */
+ (id)loadValueForKey:(NSString *)key cacheType:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType;

/**
 *  清除指定类型的数据
 *
 *  @param cacheType 缓存类型
 */
+ (void)clearObject:(KQCacheType)cacheType;

/**
 *  清除指定类型指定key的数据
 *
 *  @param key       指定key
 *  @param KQCacheType 缓存类型
 */
+ (void)clearValueForKey:(NSString *)key cacheType:(KQCacheType)KQCacheType;

/**
 *  清除指定类型指定key的数据
 *
 *  @param key       指定key
 *  @param cacheType 缓存类型
 *  @param agentType 缓存介质
 */

+ (void)clearValueForKey:(NSString *)key cacheType:(KQCacheType)cacheType agentType:(KQBCacheAgentType)agentType;
/**
 *  读取用户唯一标识
 *
 *  @return 用户唯一标识
 */
+ (NSString *)readUserId;

/**
 *  保存用户唯一标识
 *
 *  @param userId 用户唯一标识
 */
+ (void)saveUserId:(NSString *)userId;


/**
 *  缓存文件持续读写，追加写
 *
 *  @param content    追加内容
 *  @param fileName   文件名
 *  @param cacheType  缓存类型
 */
+ (void)cacheLivingFileAppend:(NSData *)content fileName:(NSString *)fileName cacheType:(KQCacheType)cacheType;


/**
 *  缓存文件目前写入大小
 *
 *  @param cacheType 缓存类型
 *
 *  @return 大小
 */
+ (unsigned long long)cacheLivingFileSize:(KQCacheType)cacheType;

@end
