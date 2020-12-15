//
//  KQHttpServiceConfig.h
//  KQComponentHttp
//
//  Created by xy on 2017/11/7.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQHttpMacro.h"

@interface KQHttpServiceConfig : NSObject

/**
 对应服务器类型
 */
@property (nonatomic, assign) KQHttpServiceType serviceType;

/**
 对应的url
 */
@property (nonatomic, strong, nonnull) NSString *url;

/**
 包含的bizType数组
 */
@property (nonatomic, strong, nullable) NSArray *bizTypeArray;

+ (nonnull instancetype)serviceConfig:(KQHttpServiceType)serviceType url:(NSString * __nonnull)url bizTypeArray:(NSArray * __nullable)bizTypeArray;

@end
