//
//  ClientData.m
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import "ClientData.h"
#import <objc/runtime.h>
#import "YYModel.h"
//#import "KQCUserManager.h"

#import "KQCStatisticsManager.h"
#import "KQStatisticsNetworkHelper.h"

#import "KQStatisticsUserDelegate.h"
#import "KQStatisticsNetworkDelegate.h"

@implementation ClientData

- (id)initWithAppKey:(NSString *)key andDeviceInfo:(DeviceInfoData *)deviceData {
    if (self = [super init]) {
        NSDictionary *deviceDic = (NSDictionary *)[deviceData yy_modelToJSONObject];
        
        unsigned int count = 0;
        
        objc_property_t *properties = class_copyPropertyList([ClientData class], &count);
        
        for (int i = 0; i < count; ++i) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *keyName = KQC_FORMAT(@"%s",name);
            
            id value = [deviceDic objectForKey:keyName];
            if (value) {
                [self setValue:value forKey:keyName];
            }
        }
        
        self.time = [KQCDate dateFormat:[NSDate date] destFormat:KQDateFormatAccurateMillisecondWithSpace];
        self.appkey = key;
        self.network = [KQStatisticsNetworkHelper networkType];
        self.ip = [KQCDevice deviceIPAddress];
        self.longitude = KQC_Engine_Location.longitude;
        self.latitude = KQC_Engine_Location.latitude;
        self.memberCode = @"";
        if (KQStatisticsManager.userDelegate && [KQStatisticsManager.userDelegate respondsToSelector:@selector(userId)]) {
            self.memberCode = KQC_NON_NIL([KQStatisticsManager.userDelegate userId]);
        }
        
        
        self.province = KQC_NON_NIL(KQC_Engine_Location.address.state);
        self.city = KQC_NON_NIL(KQC_Engine_Location.address.city);
        self.district = KQC_NON_NIL(KQC_Engine_Location.address.subLocality);
        self.street = KQC_NON_NIL(KQC_Engine_Location.address.street);
    }
    return self;
}

+ (ClientData *)getDeviceInfoWithAppKey:(NSString *)key andDeviceInfoData:(DeviceInfoData *)deviceInfo {
    ClientData *data = [[ClientData alloc] initWithAppKey:key andDeviceInfo:deviceInfo];
    return data;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.memberCode forKey:@"memberCode"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.osVersion forKey:@"osVersion"];
    [aCoder encodeObject:self.platform forKey:@"platform"];
    [aCoder encodeObject:self.language forKey:@"language"];
    [aCoder encodeObject:self.appkey forKey:@"appkey"];
    [aCoder encodeObject:self.resolution forKey:@"resolution"];
    [aCoder encodeObject:self.ismobiledevice forKey:@"ismobiledevice"];
    [aCoder encodeObject:self.phonetype forKey:@"phonetype"];
    [aCoder encodeObject:self.imsi forKey:@"imsi"];
    [aCoder encodeObject:self.mccmnc forKey:@"mccmnc"];
    [aCoder encodeObject:self.network forKey:@"network"];
    [aCoder encodeObject:self.version forKey:@"version"];
    [aCoder encodeObject:self.modulename forKey:@"modulename"];
    [aCoder encodeObject:self.devicename forKey:@"devicename"];
    [aCoder encodeObject:self.wifimac forKey:@"wifimac"];
    [aCoder encodeObject:self.havebt forKey:@"havebt"];
    [aCoder encodeObject:self.havewifi forKey:@"havewifi"];
    [aCoder encodeObject:self.havegps forKey:@"havegps"];
    [aCoder encodeObject:self.havegravity forKey:@"havegravity"];
    [aCoder encodeObject:self.imei forKey:@"imei"];
    [aCoder encodeObject:self.ip forKey:@"ip"];
    [aCoder encodeObject:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    [aCoder encodeObject:self.channel forKey:@"channel"];
    
    [aCoder encodeObject:self.province forKey:@"province"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.district forKey:@"district"];
    [aCoder encodeObject:self.street forKey:@"street"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.deviceId = [aDecoder decodeObjectForKey:@"deviceId"];
        self.memberCode = [aDecoder decodeObjectForKey:@"memberCode"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.osVersion = [aDecoder decodeObjectForKey:@"osVersion"];
        self.platform = [aDecoder decodeObjectForKey:@"platform"];
        self.language = [aDecoder decodeObjectForKey:@"language"];
        self.appkey = [aDecoder decodeObjectForKey:@"appkey"];
        self.resolution = [aDecoder decodeObjectForKey:@"resolution"];
        self.ismobiledevice = [aDecoder decodeObjectForKey:@"ismobiledevice"];
        self.phonetype = [aDecoder decodeObjectForKey:@"phonetype"];
        self.imsi = [aDecoder decodeObjectForKey:@"imsi"];
        self.mccmnc = [aDecoder decodeObjectForKey:@"mccmnc"];
        self.network = [aDecoder decodeObjectForKey:@"network"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
        self.modulename = [aDecoder decodeObjectForKey:@"modulename"];
        self.devicename = [aDecoder decodeObjectForKey:@"devicename"];
        self.wifimac = [aDecoder decodeObjectForKey:@"wifimac"];
        self.havebt = [aDecoder decodeObjectForKey:@"havebt"];
        self.havewifi = [aDecoder decodeObjectForKey:@"havewifi"];
        self.havegps = [aDecoder decodeObjectForKey:@"havegps"];
        self.havegravity = [aDecoder decodeObjectForKey:@"havegravity"];
        self.imei = [aDecoder decodeObjectForKey:@"imei"];
        self.ip = [aDecoder decodeObjectForKey:@"ip"];
        self.longitude = [aDecoder decodeObjectForKey:@"longitude"];
        self.latitude = [aDecoder decodeObjectForKey:@"latitude"];
        self.channel = [aDecoder decodeObjectForKey:@"channel"];
        
        self.province = [aDecoder decodeObjectForKey:@"province"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.district = [aDecoder decodeObjectForKey:@"district"];
        self.street = [aDecoder decodeObjectForKey:@"street"];
        

    }
    return self;
}

@end
