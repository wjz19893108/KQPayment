//
//  DeviceInfoData.m
//  kuaiQianbao
//
//  Created by 陈屹东 on 16/4/18.
//
//

#import "DeviceInfoData.h"

@implementation DeviceInfoData

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.ismobiledevice = YES;
        self.havebt = YES;
        self.havewifi = YES;
        self.havegps = YES;
        self.havegravity = YES;
        
        self.channel = @"99bill";
        self.platform = @"iOS";
        self.language = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0];
        
        self.phonetype = @"";
        self.imsi = @"";
        self.modulename = @"";
        self.wifimac = @"";
        self.imei = @"";

        //提供SDK下列参数需要自行实现
        self.version = [KQCApplication version];
        self.osVersion = [KQCDevice deviceInfoDic][@"osVersion"];
        self.devicename = [KQCDevice deviceInfoDic][@"deviceName"];
        self.mccmnc = [KQCDevice deviceInfoDic][@"mccmnc"];
        //deviceId该参数属于设备相关，但是生成规则依赖具体技术支持--by lihui
        self.deviceId = [KQCDevice deviceId];
        self.resolution = [KQCDevice deviceInfoDic][@"size"];

    }
    return self;
}



@end
