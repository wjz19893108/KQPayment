//
//  KQH5HostManager.m
//  kuaiQianbao
//
//  Created by xy on 16/6/3.
//
//

#import "KQBH5HostManager.h"


@implementation KQBH5HostInfo

+ (instancetype)hostInfo:(NSString *)host jsMethodArray:(NSArray *)methodArray{
    KQBH5HostInfo *hostInfo = [[KQBH5HostInfo alloc] init];
    hostInfo.host = host;
    hostInfo.jsMethodArray = methodArray;
    
    return hostInfo;
}

@end


@interface KQBH5HostManager()

@property (nonatomic, strong) NSMutableArray *availableHostArray;
@property (nonatomic, strong) KQBH5HostInfo *currentHostInfo;

@end

@implementation KQBH5HostManager

+ (KQBH5HostManager *)sharedManager{
    static KQBH5HostManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.availableHostArray = [NSMutableArray array];
        self.isAllowAllUrl = YES;
    }
    return self;
}

- (BOOL)isAllowUrl:(NSURL *)url{
    if (self.isAllowAllUrl) {
        return YES;
    }
    
    if (![self isJSMethod:url]) {
        NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"host = %@", url.host];
        NSArray *resultArray = [self.availableHostArray filteredArrayUsingPredicate:urlPredicate];
        if (!resultArray || resultArray.count == 0) {
            return NO;
        }
        self.currentHostInfo = resultArray[0];
        return YES;
    }
    
    if (!self.currentHostInfo.jsMethodArray
        || self.currentHostInfo.jsMethodArray.count == 0) {
        return YES;
    }
    
    NSString *methodName = [[url path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    return [self.currentHostInfo.jsMethodArray containsObject:methodName];
}

- (BOOL)isJSMethod:(NSURL *)url{
    if (![url.scheme isEqualToString:KuaiqianScheme]) {
        return NO;
    }
    
    if (![url.host isEqualToString:KuaiqianSchemeHost]) {
        return NO;
    }
    return YES;
}

- (void)updateData:(NSString *)hostStr{
    self.isAllowAllUrl = NO;
    if (!hostStr || [hostStr isEqual:[NSNull null]]) {
        [self.availableHostArray removeAllObjects];
        return;
    }
    
    [self resetAvailableHostArray:hostStr];
}

- (void)resetAvailableHostArray:(NSString *)hostStr{
    NSData *hostData = [hostStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:hostData options:NSJSONReadingMutableContainers error:&error];
    if (!dic || error) {
        DLog(@"conver hostStr to dic error:%@", dic);
        return;
    }
    
    [self.availableHostArray removeAllObjects];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        KQBH5HostInfo *hostInfo = [[KQBH5HostInfo alloc] init];
        hostInfo.host = key;
        if ([obj isKindOfClass:[NSArray class]]) {
            hostInfo.jsMethodArray = obj;
        }
        [self.availableHostArray addObject:hostInfo];
    }];
}
@end
