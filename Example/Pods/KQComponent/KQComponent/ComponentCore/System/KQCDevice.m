//
//  KQCDeviceEngine.m
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCDevice.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/mount.h>
#import "KQCKeychain.h"

@implementation KQCDevice

static NSString *KQC_UUID = nil;
static NSString *KQCDeviceId = nil;
static NSString *KQCDeivceIdKey = nil;

static KQCDeviceType KQC_DeviceType = -1;
static NSString *KQC_DeviceName = nil;

NSNotificationName const KQCDeviceTimeOutOfRangeNotification = @"DeviceTimeOutOfRangeNotification";

+ (void)load{
    [KQCDevice getDeviceInfo];
}

+ (void)initializeConfig:(NSString *)deviceIdKey{
    KQCDeivceIdKey = deviceIdKey;
    KQC_UUID = KQC_FORMAT(@"%@.%@", [[NSBundle mainBundle] bundleIdentifier], @"uuid");
}

+ (NSString *)deviceId{
    if (![NSString kqc_isBlank:KQCDeviceId]) {
        return KQCDeviceId;
    }
    
    NSString *uuidString = [KQCKeychain loadValue:KQC_UUID];
    if ([NSString kqc_isBlank:uuidString] // 默认缓存的uuid为空 并且外面设置了特殊的key,则再读一次指定key的缓存
        && ![NSString kqc_isBlank:KQCDeivceIdKey]) {
        NSString *tempKey = KQC_FORMAT(@"%@.uuid", KQCDeivceIdKey);
        uuidString = [KQCKeychain loadValue:tempKey];
    }
    
    if ([NSString kqc_isBlank:uuidString]) {
        uuidString = [KQCDevice uniqueString];
        [KQCKeychain saveValue:uuidString key:KQC_UUID];
    }
    
    if (!KQCDeviceId) {
        KQCDeviceId = uuidString;
    }
    
    return KQCDeviceId;
}

+ (KQCDeviceType)deviceType{
    return KQC_DeviceType;
}

+ (BOOL)hasScreenNotch{
    if (@available(iOS 11.0, *)) {
        return ([UIApplication sharedApplication].windows[0].safeAreaInsets.bottom > 0.f);
    }
    return NO;
}

+ (NSString *)macAddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}


+ (NSString *)uniqueString{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString* uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}

+ (NSString *)deviceIPAddress{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                //NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection on the iPhone
                        cellAddress = addr;
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    if (!addr) {
        addr = @"";
    }
    return addr;
}

+ (NSDictionary *)deviceInfoDic{
    short scale = [UIScreen mainScreen].scale;
    NSDictionary *ssidInfoDic = [KQCDevice fetchSSIDInfo];
    NSDictionary *deviceInfoDic = @{@"osVersion":[[UIDevice currentDevice] systemVersion],
                                    @"size":[NSString stringWithFormat:@"%.0f*%.0f", scale * KQC_SCREEN_WIDTH, scale * KQC_SCREEN_HEIGHT],
                                    @"wifiName":KQC_NON_NIL(ssidInfoDic[@"SSID"]),
                                    @"wifiMac":KQC_NON_NIL(ssidInfoDic[@"BSSID"]),
                                    @"deviceName":KQC_NON_NIL(KQC_DeviceName),
                                    @"mccmnc":KQC_NON_NIL([KQCDevice getCarrierInfo])};
    return deviceInfoDic;
}

+ (NSDictionary *)fetchSSIDInfo{
    //模拟器不支持获取wifi信息
#if TARGET_IPHONE_SIMULATOR
    return nil;
#else
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    
    NSDictionary *dic = nil;
    
    for (NSString *ifnam in ifs) {
        dic = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (dic != nil){
            break;
        }
    }
    return dic;
#endif
}

+ (NSString *)deviceInfo{
    return KQC_DeviceName;
}

+ (NSString *)getCarrierInfo{
    NSString *carrierInfo = @"";
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    carrierInfo = KQC_FORMAT(@"%@%@", [carrier mobileCountryCode],[carrier mobileNetworkCode]);
    return carrierInfo;
}

+ (NSDictionary *)fetchDiskSizeInfo{
    struct statfs buf;
    unsigned long long totalFreeSpace = -1;
    unsigned long long availableFreeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        totalFreeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
        availableFreeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    
    NSDictionary *dic = @{@"available":KQC_NON_NIL([KQCDevice fileSizeToString:availableFreeSpace]),
                          @"total":KQC_NON_NIL([KQCDevice fileSizeToString:totalFreeSpace])};
    
    return dic;
}

+ (NSString *)fileSizeToString:(unsigned long long)fileSize{
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    
    if (fileSize < 10) {
        return @"0 B";
    } else if (fileSize < KB) {
        return @"< 1 KB";
    } else if (fileSize < MB) {
        return [NSString stringWithFormat:@"%.4f KB", ((CGFloat)fileSize)/KB];
    } else if (fileSize < GB) {
        return [NSString stringWithFormat:@"%.4f MB", ((CGFloat)fileSize)/MB];
    } else {
        return [NSString stringWithFormat:@"%.4f GB", ((CGFloat)fileSize)/GB];
    }
}

+ (void)getDeviceInfo{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"i386"] ||
        [platform isEqualToString:@"x86_64"]) {
        KQC_DeviceType = KQCDeviceTypeSimulator;
        KQC_DeviceName = @"iPhone Simulator";
    } else if ([platform isEqualToString:@"iPhone3,1"] ||
               [platform isEqualToString:@"iPhone3,2"] ||
               [platform isEqualToString:@"iPhone3,3"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone4;
        KQC_DeviceName = @"iPhone4";
    } else if ([platform isEqualToString:@"iPhone4,1"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone4S;
        KQC_DeviceName = @"iPhone4S";
    } else if ([platform isEqualToString:@"iPhone5,1"] ||
               [platform isEqualToString:@"iPhone5,2"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone5;
        KQC_DeviceName = @"iPhone5";
    } else if ([platform isEqualToString:@"iPhone5,3"] ||
               [platform isEqualToString:@"iPhone5,4"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone5C;
        KQC_DeviceName = @"iPhone5C";
    } else if ([platform isEqualToString:@"iPhone6,1"] ||
               [platform isEqualToString:@"iPhone6,2"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone5S;
        KQC_DeviceName = @"iPhone5S";
    } else if ([platform isEqualToString:@"iPhone7,2"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone6;
        KQC_DeviceName = @"iPhone6";
    } else if ([platform isEqualToString:@"iPhone7,1"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone6P;
        KQC_DeviceName = @"iPhone6P";
    } else if ([platform isEqualToString:@"iPhone8,1"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone6S;
        KQC_DeviceName = @"iPhone6S";
    } else if ([platform isEqualToString:@"iPhone8,2"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone6SP;
        KQC_DeviceName = @"iPhone6SP";
    } else if ([platform isEqualToString:@"iPhone8,4"]) {
        KQC_DeviceType = KQCDeviceTypeIPhoneSE;
        KQC_DeviceName = @"iPhoneSE";
    } else if ([platform isEqualToString:@"iPhone9,1"] ||
               [platform isEqualToString:@"iPhone9,3"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone7;
        KQC_DeviceName = @"iPhone7";
    } else if ([platform isEqualToString:@"iPhone9,2"] ||
               [platform isEqualToString:@"iPhone9,4"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone7P;
        KQC_DeviceName = @"iPhone7P";
    } else if ([platform isEqualToString:@"iPhone10,1"] ||
               [platform isEqualToString:@"iPhone10,4"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone8;
        KQC_DeviceName = @"iPhone8";
    } else if ([platform isEqualToString:@"iPhone10,2"] ||
               [platform isEqualToString:@"iPhone10,5"]) {
        KQC_DeviceType = KQCDeviceTypeIPhone8P;
        KQC_DeviceName = @"iPhone8P";
    } else if ([platform isEqualToString:@"iPhone10,3"] ||
               [platform isEqualToString:@"iPhone10,6"]) {
        KQC_DeviceType = KQCDeviceTypeIPhoneX;
        KQC_DeviceName = @"iPhoneX";
    } else {
        KQC_DeviceType = KQCDeviceTypeUnknown;
        KQC_DeviceName = @"Unknown";
    }
}

@end
