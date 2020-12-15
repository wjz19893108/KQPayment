//
//  KQHttpResponseData.h
//  KQComponentHttp
//
//  Created by xy on 2017/11/7.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQHttpResponseData : NSObject

/**
 *  错误码
 */
@property (nonatomic, strong, nonnull) NSString *errorCode;

/**
 *  错误消息
 */
@property (nonatomic, strong, nullable) NSString *errorMessage;

/**
 *  返回的body对象
 */
@property (nonatomic, strong, nullable) id responseBody;

/**
 请求消耗的时间
 */
@property (nonatomic, assign) NSTimeInterval costTime;

@end
