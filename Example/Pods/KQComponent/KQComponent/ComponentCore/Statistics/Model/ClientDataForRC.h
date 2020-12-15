//
//  ClientDataForRC.h
//  kuaiQianbao
//
//  Created by lihui on 16/5/16.
//
//

#import <Foundation/Foundation.h>
#import "DeviceInfoData.h"

@interface ClientDataForRC : NSObject<NSCoding>

@property (nonatomic, strong) NSString *eventId;                    //埋点事件名
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *memberCode;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *osVersion;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *appkey;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *imei;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;

@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *street;


+ (ClientDataForRC *)getDeviceInfoWithAppKey:(NSString *)key withEventId:(NSString*)Id andDeviceInfoData:(DeviceInfoData *)deviceInfo;

@end
