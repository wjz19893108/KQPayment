//
//  KQBCacheEngine.m
//  KQCore
//
//  Created by pengkang on 2016/10/26.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBCacheEngine.h"

@implementation KQBCacheEngine

static NSDictionary *EnvironmentNameDic = nil;

+ (void)initializeManager{
    EnvironmentNameDic = @{@(KQCAppEnvironmentTypeDev):@"dev",
                       @(KQCAppEnvironmentTypeIntegrated):@"integrated",
                       @(KQCAppEnvironmentTypeSandbox):@"sandbox",
                       @(KQCAppEnvironmentTypePro):@""};
    
    [KQBFileEngine initializeManager];
//    [SDImageCache sharedImageCache].config.maxCacheAge = 86400 * 30;
}

+ (NSString *)environmentName{
    return EnvironmentNameDic[@([KQCApplication environmentType])];
}

#pragma mark - 存储对象
+ (BOOL)saveObject:(id)object path:(NSString *)path {
    return [KQBCacheEngine saveObject:object path:path agentType:KQCacheAgentTypePlist];
}

+ (BOOL)saveObject:(id)object path:(NSString *)path agentType:(KQCacheAgentType)cacheType {
    if ([NSString kqc_isBlank:path]) {
        return NO;
    }
    return [KQBCacheEngine writeObject:object cacheType:cacheType path:path];
}

#pragma mark - 存储某个对象的Key-Value
+ (BOOL)saveValue:(id)value forKey:(NSString *)key atPath:(NSString *)path {
    return [KQBCacheEngine saveValue:value forKey:key atPath:path cacheType:KQCacheAgentTypePlist];
}

+ (BOOL)saveValue:(id)value forKey:(NSString *)key atPath:(NSString *)path cacheType:(KQCacheAgentType)cacheType {
    if ([NSString kqc_isBlank:key]) {
        DLog(@"key is null, cacheType:%@", @(cacheType));
        return NO;
    }
    
    NSMutableDictionary *objectDic = nil;
    id object = [KQBCacheEngine loadObjectFrom:path agentType:cacheType];
    
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
    
    return [KQBCacheEngine saveObject:objectDic path:path agentType:cacheType];
}

#pragma mark - 读取对象
+ (id)loadObjectFrom:(NSString *)path {
    return [KQBCacheEngine loadObjectFrom:path agentType:KQCacheAgentTypePlist];
}

+ (id)loadObjectFrom:(NSString *)path agentType:(KQCacheAgentType)cacheType{
    
    NSString *encryptStr = [KQBCacheEngine readObjectFromCacheType:cacheType path:path];
    
    if ([NSString kqc_isBlank:encryptStr]) {
        return nil;
    }

    return encryptStr;
}

#pragma mark - 读取某个对象的Key-Value
+ (id)loadValueForKey:(NSString *)key atPath:(NSString *)path{
    return [KQBCacheEngine loadValueForKey:key atPath:path cacheType:KQCacheAgentTypePlist];
}

+ (id)loadValueForKey:(NSString *)key atPath:(NSString *)path cacheType:(KQCacheAgentType)cacheType{
    if ([NSString kqc_isBlank:key]) {
        DLog(@"key is null, cacheType:%@", @(cacheType));
        return nil;
    }
    
    id object = [KQBCacheEngine loadObjectFrom:path agentType:cacheType];
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return object[key];
}

#pragma mark - Other
+ (void)clearObject:(NSString *)path{
    [KQBFileEngine removeFile:path];
}

+ (void)removeCacheFileAt:(NSString *)path{
    if ([NSString kqc_isBlank:path]) {
        return;
    }
    [KQBFileEngine removeFile:path];
}

+ (void)removeDirectory:(NSString *)directoryPath{
    if ([NSString kqc_isBlank:directoryPath]) {
        return;
    }
    [KQBFileEngine removeDirectory:directoryPath];
}

+ (void)saveCacheFile:(NSString *)fileName data:(NSData *)data directoryPath:(NSString *)directoryPath{
    if ([NSString kqc_isBlank:fileName]
        || !data) {
        return;
    }
    
    if (![KQBFileEngine createDirectory:directoryPath]) {
        return;
    }
    
    NSString *path = [directoryPath stringByAppendingPathComponent:fileName];
    [KQBFileEngine saveData:data filePath:path];
}

#pragma mark - userDefault 操作
+ (NSString *)userDefaultsRealKey:(NSString *)key{
    if ([NSString kqc_isBlank:key]) {
        return nil;
    }
    
    NSString *environmentName = [KQBCacheEngine environmentName];
    if (![NSString kqc_isBlank:environmentName]) {
        key = KQC_FORMAT(@"%@_%@", key, environmentName);
    }
    return key;
}

+ (id)readUserDefaults:(NSString *)key{
    NSString *realKey = [KQBCacheEngine userDefaultsRealKey:key];
    if ([NSString kqc_isBlank:realKey]) {
        return nil;
    }
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:realKey];
}

+ (void)saveUserDefaults:(NSString *)key value:(id)value{
    NSString *realKey = [KQBCacheEngine userDefaultsRealKey:key];
    if ([NSString kqc_isBlank:realKey]) {
        return;
    }
    
    if (!value) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:realKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:realKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)writeObject:(id)object cacheType:(KQCacheAgentType)agentType path:(NSString *)path{
    switch (agentType) {
        case KQCacheAgentTypePlist:
           
            return [KQBFileEngine writeObject:object filePath:path];
            break;
        case KQCacheAgentTypeDatabase:
            
            return NO;
            break;
    }
}

+ (id)readObjectFromCacheType:(KQCacheAgentType)agentType path:(NSString *)path{
    switch (agentType) {
        case KQCacheAgentTypePlist:
            return [KQBFileEngine readObject:path];
            break;
        case KQCacheAgentTypeDatabase:
            return nil;
            break;
    }
}

@end
