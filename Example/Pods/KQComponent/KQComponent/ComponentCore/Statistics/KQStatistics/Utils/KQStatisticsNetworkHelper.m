//
//  KQStatisticsNetworkHelper.m
//  KQComponent
//
//  Created by wangping on 2018/6/11.
//

#import "KQStatisticsNetworkHelper.h"
#import "AFNetworkReachabilityManager.h"
#import "AFHTTPSessionManager.h"
#import "AFSecurityPolicy.h"
#import "zlib.h"

#import "KQCStatisticsManager.h"
#import "KQStatisticsNetworkDelegate.h"
#import "KQStatisticsUserDelegate.h"

@interface KQStatisticsNetworkHelper()

@end

@implementation KQStatisticsNetworkHelper
static NSString *KQStatUrl = nil;    // 埋点地址
static NSString *KQStatRCUrl = nil;  // 实时埋点地址

+ (NSString*)networkType {
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

+ (KQStatisticsNetworkHelper *)shareInstance {
    static KQStatisticsNetworkHelper *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[KQStatisticsNetworkHelper alloc] init];
    });
    return shareInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self switchUrl];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(environmentChanged:) name:KQCApplicationEnvironmentDidChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notify environment changed
- (void)environmentChanged:(NSNotification *)notification{
    [self switchUrl];
}

- (void)switchUrl{
    KQCAppEnvironmentType environmentType = [KQCApplication environmentType];
    switch (environmentType) {
        case KQCAppEnvironmentTypePro:
            KQStatUrl = @"https://dts.99bill.com/bg-channel/cocdata";
            KQStatRCUrl = @"https://dts.99bill.com/bg-channel/rmcdata";
            break;
        case KQCAppEnvironmentTypeDev:
            KQStatUrl = @"https://192.168.47.198/bg-channel/cocdata";
            KQStatRCUrl = @"https://192.168.47.198/bg-channel/rmcdata";
            break;
        default:
            KQStatUrl = @"https://192.168.8.143/bg-channel/cocdata";
            KQStatRCUrl = @"https://192.168.8.143/bg-channel/rmcdata";
            break;
    }
}

- (void)sendHttpRequest:(NSData *)data policy:(KQStatisticsPolicyType)policyType successBlock:(SuccessStatisticsBlock)successBlock failedBlock:(FailedStatisticsBlock)failedBlock {
    if (!data) {
        failedBlock(nil, 0);
        return;
    }
    
    @synchronized (self) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        // 安装证书
        if (KQStatisticsManager.networkDelegate && [KQStatisticsManager.networkDelegate respondsToSelector:@selector(setupSecurityPolicy:)]) {
            [KQStatisticsManager.networkDelegate setupSecurityPolicy:manager];
        }
//        [self setupSecurityPolicy:manager];
        
        
        NSURLSessionDataTask *task = [manager uploadTaskWithRequest:[self statusticsRequest:policyType] fromData:[self kqc_gzipDeflate:data] progress:^(NSProgress * _Nonnull uploadProgress) {
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (error) {
                if (failedBlock) {
                    failedBlock(error, httpResponse.statusCode);
                }
            } else {
                if (successBlock) {
                    successBlock(responseObject, httpResponse.allHeaderFields);
                }
            }
        }];
        
        [task resume];
    }
}

- (NSMutableURLRequest *)statusticsRequest:(KQStatisticsPolicyType)policyType{
    NSString *urlReq = policyType == KQStatisticsPolicyTypeNormal ? KQStatUrl : KQStatRCUrl;    
    NSURL *requestUrl = [NSURL URLWithString:urlReq];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields =  @{@"Content-Encoding":@"gzip"};
    request.timeoutInterval = 30.0f;
    return request;
}


#pragma mark - utils

- (NSData *)kqc_gzipDeflate:(NSData *)data
{
    
    if ([data length] == 0) return data;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)[compressed length] - (uInt)strm.total_out;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

@end
