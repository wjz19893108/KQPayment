//
//  KQURLConnection.m
//  kuaiQianbao
//
//  Created by wangping on 16/7/26.
//
//

#import "KQCURLConnection.h"

#define kNotifyKQURLConnectionStop @"kNotifyKQURLConnectionStop"

@interface KQCURLConnection ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) NSMutableData *receivedData;

@property (nonatomic, copy) void(^completionHandlerBlock)(NSURLResponse *response, id responseObject, NSError *error);

@end

@implementation KQCURLConnection

+ (void)cancel {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyKQURLConnectionStop object:nil];
}

/**
 *   构建Connection
 *
 *  @param request           请求对象
 *  @param completionHandler 成功返回事件
 *
 *  @return 当前类实例
 */
- (instancetype)initWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:kNotifyKQURLConnectionStop object:nil];
        
        _receivedData = [NSMutableData dataWithCapacity:0];
        
        if (request && completionHandler) {
            _request = request;
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            self.completionHandlerBlock = completionHandler;
        }
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stop];
}

/**
 *  开始发起请求
 */
- (void)start {
    if (!_receivedData) {
        _receivedData = [NSMutableData dataWithCapacity:0];
    }
    
    if (_connection) {
        [_connection start];
    } else {
        
        if (_request) {
             _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
        }
        else {
            if (self.completionHandlerBlock) {
                
                NSMutableDictionary *mutableUserInfo = [@{
                                                          NSLocalizedDescriptionKey: @"connection close",
                                                          NSURLErrorFailingURLErrorKey:@"",
                                                          } mutableCopy];
                
                NSError *error = [NSError errorWithDomain:@"KQCURLConnection" code:-1 userInfo:mutableUserInfo];
                self.completionHandlerBlock(nil,nil,error);
            }
        }
       
        
    }
}

/**
 *  关闭请求
 */
- (void)stop {
    if (_connection) {
        [_connection cancel];
        _connection = nil;
        
        self.completionHandlerBlock = nil;
    }
}

#pragma mark - delegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_completionHandlerBlock) {
        _completionHandlerBlock(nil, _receivedData, nil);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (_receivedData) {
        [_receivedData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (data) {
        [_receivedData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_completionHandlerBlock) {
        _completionHandlerBlock(nil, _receivedData, error);
    }
}

@end
