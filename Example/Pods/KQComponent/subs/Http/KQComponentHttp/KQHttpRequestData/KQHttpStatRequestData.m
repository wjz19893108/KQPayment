//
//  KQHttpStatRequestData.m
//  kuaiQianbao
//
//  Created by lihui on 16/5/26.
//
//

#import "KQHttpStatRequestData.h"

//@implementation KQHttpStatResponseHeader
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
//@implementation KQHttpStatResponse
//
//@end

@implementation KQHttpStatRequestData

- (instancetype)initWithBizType:(NSString *)bizType serviceType:(KQHttpServiceType)serviceType{
    self = [super initWithBizType:bizType serviceType:serviceType];
    if (self) {
        self.customerHttpHeader = @{@"Content-Encoding":@"gzip"};
//        self.needSign = NO;
    }
    return self;
}

- (NSData *)buildRequestData:(NSError **)error{
    NSData *data = [self.paramDic objectForKey:@"data"];
    if (!data) {
        return nil;
    }
    
    //post数据做gzip压缩
    data = [data kqc_gzipDeflate];
    return data;
}

- (id)parseResponseData:(NSData *)responseData{
    if (!responseData) {
        return nil;
    }
    
    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    headerDic[@"responseCode"] = @"00";
    if (responseStr) {
        headerDic[@"responseMsg"] = responseStr;
    }
    
    NSDictionary *resultDic = @{@"header":headerDic};
    return resultDic;
    
//    KQHttpStatResponse *response = [[KQHttpStatResponse alloc] init];
//    
//    KQHttpStatResponseHeader *header = [[KQHttpStatResponseHeader alloc] init];
//    header.responseCode = @"00";
//    header.responseMsg = responseStr;
//    
//    response.header = header;
//    return response;
}

@end
