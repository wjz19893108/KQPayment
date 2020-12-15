//
//  KQCHttpRequestModel.h
//  KQCore
//
//  Created by xy on 2016/11/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQCHttpRequestModel : NSObject

/**
 请求网络的目标地址
 */
@property (nonatomic, strong) NSString *url;

/**
 请求的body数据流
 */
@property (nonatomic, strong) NSData *body;

/**
 请求的http头
 */
@property (nonatomic, strong) NSDictionary *header;

/**
 请求超时时间，如果值为0，则采用系统默认超时时间
 */
@property (nonatomic, assign) NSInteger timeout;

/**
 是否忽略证书验证
 */
@property (nonatomic, assign, getter=isIgnoreCert) BOOL ignoreCert;

/**
 成功回调
 */
@property (nonatomic, copy) void (^successBlock)(NSData *responseData, NSDictionary *responseHeader);

/**
 失败回调
 */
@property (nonatomic, copy) void (^failedBlock)(NSError *error, NSInteger httpStatusCode);

+ (instancetype)requsetModel:(NSString *)url body:(NSData *)body header:(NSDictionary *)header successBlock:(void (^)(NSData *responseData, NSDictionary *responseHeader))successBlock failedBlock:(void (^)(NSError *error,NSInteger httpStatusCode))failedBlock;

+ (instancetype)requsetModel:(NSString *)url body:(NSData *)body header:(NSDictionary *)header successBlock:(void (^)(NSData *responseData, NSDictionary *responseHeader))successBlock failedBlock:(void (^)(NSError *error,NSInteger httpStatusCode))failedBlock timeout:(NSInteger)timeout ignoreCert:(BOOL)ignoreCert;

@end
