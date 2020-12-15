//
//  KQCLocationAddress.h
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQCLocationAddress : NSObject

/**
 国家
 */
@property (nonatomic, strong) NSString *country;

/**
 省
 */
@property (nonatomic, strong) NSString *state;

/**
 城市名
 */
@property (nonatomic, strong) NSString *city;

/**
 城市附加信息
 */
@property (nonatomic, strong) NSString *subLocality;

/**
 详细地址
 */
@property (nonatomic, strong) NSString *detailAddress;

/**
 街道
 */
@property (nonatomic, strong) NSString *street;

/**
 地址名称 例子：APPLE Inc
 */
@property (nonatomic, strong) NSString *name;

/**
 城市id
 */
@property (nonatomic, strong) NSString *cityId;
@end
