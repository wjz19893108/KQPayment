//
//  ClientDataForRC.m
//  kuaiQianbao
//
//  Created by lihui on 16/5/16.
//
//

#import "ClientDataForRC.h"
#import "YYModel.h"
//#import "KQCUserManager.h"
#import "KQCStatisticsManager.h"
#import "KQStatisticsNetworkHelper.h"

#import "KQStatisticsUserDelegate.h"
#import "KQStatisticsNetworkDelegate.h"

@implementation ClientDataForRC

- (id)initWithAppKey:(NSString *)key withEventId:(NSString*)Id andDeviceInfo:(DeviceInfoData *)deviceData {
    if (self = [super init]) {
        
        NSDictionary *deviceDic = (NSDictionary *)[deviceData yy_modelToJSONObject];
        
        unsigned int count = 0;
        
        objc_property_t *properties = class_copyPropertyList([ClientDataForRC class], &count);
        
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
        self.eventId = Id;
        self.ip = [KQCDevice deviceIPAddress];
        self.longitude = KQC_Engine_Location.longitude;
        self.latitude = KQC_Engine_Location.latitude;
        
        self.province = KQC_NON_NIL(KQC_Engine_Location.address.state);
        self.city = KQC_NON_NIL(KQC_Engine_Location.address.city);
        self.district = KQC_NON_NIL(KQC_Engine_Location.address.subLocality);
        self.street = KQC_NON_NIL(KQC_Engine_Location.address.street);
        

        if (KQStatisticsManager.userDelegate && [KQStatisticsManager.userDelegate respondsToSelector:@selector(userId)]) {
            self.memberCode = KQC_NON_NIL([KQStatisticsManager.userDelegate userId]);
        }
        
//        self.memberCode = KQC_NON_NIL(KQC_CurrentUser.secretUserMebCode);
    }
    return self;
}

+ (ClientDataForRC *)getDeviceInfoWithAppKey:(NSString *)key withEventId:(NSString*)Id andDeviceInfoData:(DeviceInfoData *)deviceInfo {
    ClientDataForRC *data = [[ClientDataForRC alloc] initWithAppKey:key withEventId:Id andDeviceInfo:deviceInfo];
    return data;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.eventId forKey:@"eventId"];
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.memberCode forKey:@"memberCode"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.osVersion forKey:@"osVersion"];
    [aCoder encodeObject:self.platform forKey:@"platform"];
    [aCoder encodeObject:self.appkey forKey:@"appkey"];
    [aCoder encodeObject:self.version forKey:@"version"];
    [aCoder encodeObject:self.imei forKey:@"imei"];
    [aCoder encodeObject:self.ip forKey:@"ip"];
    [aCoder encodeObject:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
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
        self.osVersion = [aDecoder decodeObjectForKey:@"osVersion"];
        self.platform = [aDecoder decodeObjectForKey:@"platform"];
        self.appkey = [aDecoder decodeObjectForKey:@"appkey"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
        self.imei = [aDecoder decodeObjectForKey:@"imei"];
        self.ip = [aDecoder decodeObjectForKey:@"ip"];
        self.longitude = [aDecoder decodeObjectForKey:@"longitude"];
        self.latitude = [aDecoder decodeObjectForKey:@"latitude"];
        self.province = [aDecoder decodeObjectForKey:@"province"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        
        self.district = [aDecoder decodeObjectForKey:@"district"];
        self.street = [aDecoder decodeObjectForKey:@"street"];
    }
    return self;
}
@end
