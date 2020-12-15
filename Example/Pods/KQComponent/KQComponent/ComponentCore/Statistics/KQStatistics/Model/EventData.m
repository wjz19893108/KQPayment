//
//  EventData.m
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import "EventData.h"
//#import "KQCUserManager.h"
#import "KQCStatisticsManager.h"
#import "KQStatisticsNetworkDelegate.h"
#import "KQStatisticsUserDelegate.h"

@implementation EventData

//yymodel  黑名单方法，将EventData转换为NSDictionary时忽略dicForEvent属性，做特殊处理
+ (NSArray *)modelPropertyBlacklist {
    return @[@"dicForEvent"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.eventId forKey:@"eventId"];
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.memberCode forKey:@"memberCode"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:@(self.isPage) forKey:@"isPage"];
    [aCoder encodeObject:@(self.enterOrLeave) forKey:@"enterOrLeave"];
    [aCoder encodeObject:self.from forKey:@"from"];
    [aCoder encodeObject:self.platform forKey:@"platform"];
    [aCoder encodeObject:self.osVersion forKey:@"osVersion"];
    [aCoder encodeObject:self.appkey forKey:@"appkey"];
    [aCoder encodeObject:self.channel forKey:@"channel"];
    [aCoder encodeObject:self.version forKey:@"version"];
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.dicForEvent forKey:@"dicForEvent"];
    
    [aCoder encodeObject:self.province forKey:@"province"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.district forKey:@"district"];
    [aCoder encodeObject:self.street forKey:@"street"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.eventId = [aDecoder decodeObjectForKey:@"eventId"];
        self.deviceId = [aDecoder decodeObjectForKey:@"deviceId"];
        self.memberCode = [aDecoder decodeObjectForKey:@"memberCode"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.isPage = [[aDecoder decodeObjectForKey:@"isPage"] boolValue];
        self.enterOrLeave = [[aDecoder decodeObjectForKey:@"enterOrLeave"] boolValue];
        self.from = [aDecoder decodeObjectForKey:@"from"];
        self.platform = [aDecoder decodeObjectForKey:@"platform"];
        self.osVersion = [aDecoder decodeObjectForKey:@"osVersion"];
        self.appkey = [aDecoder decodeObjectForKey:@"appkey"];
        self.channel = [aDecoder decodeObjectForKey:@"channel"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
        self.message = [aDecoder decodeObjectForKey:@"message"];
        self.dicForEvent = [aDecoder decodeObjectForKey:@"dicForEvent"];
        
        self.province = [aDecoder decodeObjectForKey:@"province"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.district = [aDecoder decodeObjectForKey:@"district"];
        self.street = [aDecoder decodeObjectForKey:@"street"];
    }
    return self;
}

- (instancetype)initWithPageName:(NSString *)pageName
                          appKey:(NSString *)appKey
                           label:(NSString *)label
                      attributes:(NSDictionary *)attributes
                      deviceInfo:(DeviceInfoData *)deviceInfo{
    self = [super init];
    if (self){
        self.eventId = pageName;
        self.deviceId = deviceInfo.deviceId;
        self.memberCode = @"";
        if (KQStatisticsManager.userDelegate && [KQStatisticsManager.userDelegate  respondsToSelector:@selector(secretUserMebCode)]) {
            self.memberCode = KQC_NON_NIL([KQStatisticsManager.userDelegate secretUserMebCode]);
        }
        self.time = [KQCDate dateFormat:[NSDate date] destFormat:KQDateFormatAccurateMillisecondWithSpace];
        self.isPage = NO;
        self.from = @"UX";
        self.platform = deviceInfo.platform;
        self.osVersion = deviceInfo.osVersion;
        self.appkey = appKey;
        self.channel = deviceInfo.channel;
        self.version = deviceInfo.version;
        self.message = label;
        self.dicForEvent = attributes;
        
        self.province = KQC_NON_NIL(KQC_Engine_Location.address.state);
        self.city = KQC_NON_NIL(KQC_Engine_Location.address.city);
        self.district = KQC_NON_NIL(KQC_Engine_Location.address.subLocality);
        self.street = KQC_NON_NIL(KQC_Engine_Location.address.street);
    }
    return self;
}

- (instancetype)initWithPageName:(NSString *)pageName
                          appKey:(NSString *)appKey
                         isEnter:(BOOL)isEnter
                      deviceInfo:(DeviceInfoData *)deviceInfo{
    self = [super init];
    if (self){
        self.eventId = pageName;
        self.deviceId = deviceInfo.deviceId;
        self.memberCode = @"";
        if (KQStatisticsManager.userDelegate && [KQStatisticsManager.userDelegate  respondsToSelector:@selector(secretUserMebCode)]) {
            self.memberCode = KQC_NON_NIL([KQStatisticsManager.userDelegate secretUserMebCode]);
        }
        self.time = [KQCDate dateFormat:[NSDate date] destFormat:KQDateFormatAccurateMillisecondWithSpace];
        self.isPage = YES;
        self.enterOrLeave = isEnter;
        self.from = @"UX";
        self.platform = deviceInfo.platform;
        self.osVersion = deviceInfo.osVersion;
        self.appkey = appKey;
        self.channel = deviceInfo.channel;
        self.version = deviceInfo.version;
        
        self.province = KQC_NON_NIL(KQC_Engine_Location.address.state);
        self.city = KQC_NON_NIL(KQC_Engine_Location.address.city);
        self.district = KQC_NON_NIL(KQC_Engine_Location.address.subLocality);
        self.street = KQC_NON_NIL(KQC_Engine_Location.address.street);
    }
    return self;
}
@end
