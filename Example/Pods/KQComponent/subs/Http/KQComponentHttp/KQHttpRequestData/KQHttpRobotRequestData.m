//
//  KQHttpRobotRequestData.m
//  kuaiQianbao
//
//  Created by xy on 15/9/1.
//
//

#import "KQHttpRobotRequestData.h"

//@implementation KQHttpRobotResponseHeader
//
//- (void)storeInDictionary:(NSMutableDictionary *)dic{
//    if (!dic) {
//        return;
//    }
//    
//    dic[@"responseCode"] = self.responseCode;
//    if (self.responseMsg) {
//        dic[@"responseMsg"] = self.responseMsg;
//    }
//}
//
//@end
//
//@implementation KQHttpRobotResponse
//
//@end

@implementation KQHttpRobotRequestData

- (instancetype)initWithBizType:(NSString *)bizType serviceType:(KQHttpServiceType)serviceType{
    self = [super initWithBizType:bizType serviceType:serviceType];
    if (self) {
        self.host = [self.host stringByAppendingFormat:@"/%@", bizType];
        self.customerHttpHeader = @{@"Content-Type":@"application/x-www-form-urlencoded; charset=utf-8"};
//        self.needSign = NO;
    }
    return self;
}

- (NSData *)buildRequestData:(NSError **)error{
    NSString *prefix = [NSString stringWithFormat:@"路径：%@    请求数据:{", self.bizType];
    NSMutableString *str = [[NSMutableString alloc] initWithString:prefix];
    [self.paramDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [str appendFormat:@"%@ = %@\n", key, obj];
    }];
    [str appendString:@"}"];
    DLog(@"%@", str);
    
    NSString *body = [self.paramDic kqc_urlEncodedKeyValueString];
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)parseResponseData:(NSData *)responseData{
    if (!responseData) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *returnValue = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    if (error) {
        DLog(@"JSON Parsing Error: %@", error);
        return nil;
    }
    
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    headerDic[@"responseCode"] = @"00";
    NSMutableDictionary *resultDic = [@{@"header":headerDic} mutableCopy];
    if (returnValue[@"info"]) {
        resultDic[@"msgContent"] = returnValue[@"info"];
    }
    DLog(@"小i返回数据：%@", returnValue[@"info"]);
    
    return resultDic;
    
//    KQHttpRobotResponse *response = [[KQHttpRobotResponse alloc] init];
//    
//    KQHttpRobotResponseHeader *header = [[KQHttpRobotResponseHeader alloc] init];
//    header.responseCode = @"00";
//    
//    response.header = header;
//    response.msgContent = returnValue[@"info"];
//    DLog(@"小i返回数据：%@", response.msgContent);
//    return response;
}

@end
