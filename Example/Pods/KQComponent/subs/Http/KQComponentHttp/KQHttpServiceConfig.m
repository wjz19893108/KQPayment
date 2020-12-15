//
//  KQHttpServiceConfig.m
//  KQComponentHttp
//
//  Created by xy on 2017/11/7.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import "KQHttpServiceConfig.h"

@implementation KQHttpServiceConfig

+ (instancetype)serviceConfig:(KQHttpServiceType)serviceType url:(NSString *)url bizTypeArray:(NSArray *)bizTypeArray{
    KQHttpServiceConfig *config = [[KQHttpServiceConfig alloc] init];
    config.serviceType = serviceType;
    config.url = url;
    config.bizTypeArray = bizTypeArray;
    return config;
}

@end
