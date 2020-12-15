//
//  ErrorLog.m
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import "ErrorLog.h"
//#import "KQCUserManager.h"
#import "KQCStatisticsManager.h"

#import "KQStatisticsNetworkDelegate.h"
#import "KQStatisticsUserDelegate.h"

@implementation ErrorLog

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.stacktrace forKey:@"stacktrace"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.activity forKey:@"activity"];
    [aCoder encodeObject:self.appkey forKey:@"appkey"];
    [aCoder encodeObject:self.osVersion forKey:@"osVersion"];
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.version forKey:@"version"];
    [aCoder encodeObject:self.platform forKey:@"platform"];
    [aCoder encodeObject:self.devicename forKey:@"devicename"];
    [aCoder encodeObject:self.channel forKey:@"channel"];
    [aCoder encodeObject:self.memberCode forKey:@"memberCode"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.stacktrace = [aDecoder decodeObjectForKey:@"stacktrace"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.activity = [aDecoder decodeObjectForKey:@"activity"];
        self.appkey = [aDecoder decodeObjectForKey:@"appkey"];
        self.osVersion = [aDecoder decodeObjectForKey:@"osVersion"];
        self.deviceId = [aDecoder decodeObjectForKey:@"deviceId"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
        self.platform = [aDecoder decodeObjectForKey:@"platform"];
        self.devicename = [aDecoder decodeObjectForKey:@"devicename"];\
        self.channel = [aDecoder decodeObjectForKey:@"channel"];
        self.memberCode = [aDecoder decodeObjectForKey:@"memberCode"];
    }
    return self;
}

- (instancetype)initWithStackTrace:(NSString *)stackTrace
                            appKey:(NSString *)appKey
                        deviceInfo:(DeviceInfoData *)deviceInfo{
    self = [super init];
    if (self){
        self.stacktrace = stackTrace;
        self.time = [KQCDate dateFormat:[NSDate date] destFormat:KQDateFormatAccurateMillisecondWithSpace];
        self.activity = [[NSBundle mainBundle] bundleIdentifier];
        self.appkey = appKey;
        self.osVersion = deviceInfo.osVersion;
        self.deviceId = deviceInfo.deviceId;
        self.version = deviceInfo.version;
        self.platform = deviceInfo.platform;
        self.devicename = deviceInfo.devicename;
        self.channel = deviceInfo.channel;
        
        self.memberCode = @"";
        if (KQStatisticsManager.userDelegate && [KQStatisticsManager.userDelegate  respondsToSelector:@selector(secretUserMebCode)]) {
            self.memberCode = KQC_NON_NIL([KQStatisticsManager.userDelegate secretUserMebCode]);
        }
    }
    return self;
}
@end
