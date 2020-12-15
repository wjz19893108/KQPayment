//
//  KQBCacheEngine.h
//  KQCore
//
//  Created by pengkang on 2016/10/26.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KQCacheAgentType) {
    KQCacheAgentTypePlist = 0,      // Plist文件
    KQCacheAgentTypeDatabase        // 数据库
};

@interface KQBCacheEngine : NSObject

/**
 初始化缓存目录
 */
+ (void)initializeManager;

/**
 当前环境的路径名称

 @return 名称
 */
+ (NSString *)environmentName;


/**
 存储对象为Plist

 @param object 对象
 @param path 路径
 */
+ (BOOL)saveObject:(id)object path:(NSString *)path;


/**
 存储对象

 @param object 对象
 @param path 文件路径or表
 @param cacheType 存储介质
 */
+ (BOOL)saveObject:(id)object path:(NSString *)path agentType:(KQCacheAgentType)cacheType;

/**
 设置Plist中的Value

 @param value 值
 @param key 键
 @param path 文件路径
 */
+ (BOOL)saveValue:(id)value forKey:(NSString *)key atPath:(NSString *)path;

/**
 设置Value
 
 @param value 值
 @param key 键
 @param path 文件路径
 @param cacheType 存储介质
 */
+ (BOOL)saveValue:(id)value forKey:(NSString *)key atPath:(NSString *)path cacheType:(KQCacheAgentType)cacheType;

/**
 读取Plist对象

 @param path 文件路径
 */
+ (id)loadObjectFrom:(NSString *)path;


/**
 读取缓存对象

 @param path 文件或数据库表名
 @param cacheType 介质类型
 */
+ (id)loadObjectFrom:(NSString *)path agentType:(KQCacheAgentType)cacheType;

/**
 读取Plist值

 @param key 键
 @param filePath 文件路径
 */
+ (id)loadValueForKey:(NSString *)key atPath:(NSString *)filePath;


/**
 读取Value

 @param key 键
 @param filePath 文件路径或数据库表名
 @param cacheType 介质类型
 */
+ (id)loadValueForKey:(NSString *)key atPath:(NSString *)filePath cacheType:(KQCacheAgentType)cacheType;

/**
 清除对象

 @param filePath 文件路径
 */
+ (void)clearObject:(NSString *)filePath;

/**
 删除文件

 @param filePath 文件路径
 */
+ (void)removeCacheFileAt:(NSString *)filePath;


/**
 删除文件夹

 @param directoryPath 文件夹路径
 */
+ (void)removeDirectory:(NSString *)directoryPath;


/**
 存储文件

 @param fileName 文件名
 @param data 数据
 @param directoryPath 文件夹
 */
+ (void)saveCacheFile:(NSString *)fileName data:(NSData *)data directoryPath:(NSString *)directoryPath;


/**
 存储UserDefault

 @param key 键
 @param value 值
 */
+ (void)saveUserDefaults:(NSString *)key value:(id)value;


/**
 重置UserDefault

 @param key 键
 */
+ (id)readUserDefaults:(NSString *)key;

@end
