//
//  KQCNetworkState.m
//  KQCoreHttpEngine
//
//  Created by xy on 2018/5/16.
//  Copyright © 2018年 99bill. All rights reserved.
//

#import "KQCNetworkState.h"
#import "AFNetworkReachabilityManager.h"

@implementation KQCNetworkState

+ (void)load{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (BOOL)isExistenceNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (NSString*)networkType{
    AFNetworkReachabilityStatus networkStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    NSString *info = @"";
    
    switch (networkStatus) {
        case AFNetworkReachabilityStatusUnknown:
            break;
        case AFNetworkReachabilityStatusNotReachable:
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:// 3G网络
            info = @"3G";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:// wifi网络
            info = @"WiFi";
            break;
    }
    return info;
}

@end
