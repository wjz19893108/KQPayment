//
//  KQCHttpRequestModel.m
//  KQCore
//
//  Created by xy on 2016/11/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCHttpRequestModel.h"

@implementation KQCHttpRequestModel

+ (instancetype)requsetModel:(NSString *)url body:(NSData *)body header:(NSDictionary *)header successBlock:(void (^)(NSData *responseData, NSDictionary *responseHeader))successBlock failedBlock:(void (^)(NSError *error,NSInteger httpStatusCode))failedBlock{
    return [KQCHttpRequestModel requsetModel:url body:body header:header successBlock:successBlock failedBlock:failedBlock timeout:0 ignoreCert:YES];
}

+ (instancetype)requsetModel:(NSString *)url body:(NSData *)body header:(NSDictionary *)header successBlock:(void (^)(NSData *responseData, NSDictionary *responseHeader))successBlock failedBlock:(void (^)(NSError *error,NSInteger httpStatusCode))failedBlock timeout:(NSInteger)timeout ignoreCert:(BOOL)ignoreCert{
    KQCHttpRequestModel *model = [[KQCHttpRequestModel alloc] init];
    model.url = url;
    model.body = body;
    model.header = header;
    model.successBlock = successBlock;
    model.failedBlock = failedBlock;
    model.timeout = timeout;
    model.ignoreCert = ignoreCert;
    return model;
}

@end
