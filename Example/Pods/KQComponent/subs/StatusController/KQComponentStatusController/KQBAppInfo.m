//
//  KQBAppInfo.m
//  KQBusiness
//
//  Created by pengkang on 2016/12/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBAppInfo.h"
#import <objc/runtime.h>
#import "KQBCacheManager.h"

@implementation KQBAppInfo

- (instancetype)initWithAppInfo:(id)response{
    self = [super init];
    
    if (self) {
        _appType = [self getValueForKey:@"appType" fromResponse:response];
        _latestAppVersionUrl = [self getValueForKey:@"latestAppVersionUrl" fromResponse:response];
        _appFlag = [self getValueForKey:@"appFlag" fromResponse:response];
        _gradientLaunchMessageTitle = [self getValueForKey:@"gradientLaunchMessageTitle" fromResponse:response];
        _gradientLaunchMessageContent = [self getValueForKey:@"gradientLaunchMessageContent" fromResponse:response];
        _md5 = [self getValueForKey:@"md5" fromResponse:response];
    }
    return self;
}

- (NSString *)getValueForKey:(NSString *)keyName fromResponse:(id )response{
    NSString *propertyValue;
    SuppressPerformSelectorLeakWarning(propertyValue = [response performSelector:NSSelectorFromString(keyName)]);
    return propertyValue;
}

-(void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
    
}

@end


@interface KQBConfigInfo()<NSCoding>

@end

@implementation KQBConfigInfo

- (instancetype)init{
    self = [super init];
    if (self) {
        
        id cacheObject = [KQBCacheManager loadValueForKey:KQPageCacheAUKey cacheType:KQCacheTypeMain];
        
        if (cacheObject) {
            self = cacheObject;
        }
    }
    return self;
}

- (void)saveCache{
    [KQBCacheManager saveValue:self forKey:KQPageCacheAUKey cacheType:KQCacheTypeMain];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.upgradeRemindTimes forKey:@"upgradeRemindTimes"];
    [aCoder encodeObject:self.remainUpgradeTimes forKey:@"remainUpgradeTimes"];
    [aCoder encodeObject:self.lastRemindTime forKey:@"lastRemindTime"];
    [aCoder encodeObject:self.md5 forKey:@"md5"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.upgradeRemindTimes = [aDecoder decodeObjectForKey:@"upgradeRemindTimes"];
        self.remainUpgradeTimes = [aDecoder decodeObjectForKey:@"remainUpgradeTimes"];
        self.lastRemindTime = [aDecoder decodeObjectForKey:@"lastRemindTime"];
        self.md5 = [aDecoder decodeObjectForKey:@"md5"];
    }
    return self;
}

@end
