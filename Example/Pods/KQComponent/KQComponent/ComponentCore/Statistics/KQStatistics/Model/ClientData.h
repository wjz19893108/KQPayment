//
//  ClientData.h
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import <Foundation/Foundation.h>
#import "DeviceInfoData.h"

@interface ClientData : NSObject<NSCoding>

@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *memberCode;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *osVersion;
@property (nonatomic,strong) NSString *platform;
@property (nonatomic,strong) NSString *language;
@property (nonatomic,strong) NSString *appkey;
@property (nonatomic,strong) NSString *resolution;
@property (nonatomic,strong) NSString *ismobiledevice;
@property (nonatomic,strong) NSString *phonetype;
@property (nonatomic,strong) NSString *imsi;
@property (nonatomic,strong) NSString *mccmnc;
@property (nonatomic,strong) NSString *network;
@property (nonatomic,strong) NSString *version;
@property (nonatomic,strong) NSString *modulename;
@property (nonatomic,strong) NSString *devicename;
@property (nonatomic,strong) NSString *wifimac;
@property (nonatomic,strong) NSString *havebt;
@property (nonatomic,strong) NSString *havewifi;
@property (nonatomic,strong) NSString *havegps;
@property (nonatomic,strong) NSString *havegravity;
@property (nonatomic,strong) NSString *imei;
@property (nonatomic,strong) NSString *ip;
@property (nonatomic,strong) NSString *longitude;
@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *channel;

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *street;

+ (ClientData *)getDeviceInfoWithAppKey:(NSString *)key andDeviceInfoData:(DeviceInfoData *)deviceInfo;

@end
