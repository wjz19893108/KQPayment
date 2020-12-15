//
//  KQCApplication.m
//  KQCore
//
//  Created by xy on 2016/10/28.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCApplication.h"
#import <AdSupport/AdSupport.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>

@implementation KQCApplication

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

NSNotificationName const KQCApplicationCrashNotification = @"ApplicationCrashNotification";
NSNotificationName const KQCApplicationStatusNotification = @"ApplicationStatusNotification";
NSNotificationName const KQCApplicationEnvironmentDidChangedNotification = @"ApplicationEnvironmentDidChangedNotification";
NSNotificationName const KQCApplicationServerDidChangedNotification = @"ApplicationServerDidChangedNotification";

NSNotificationName const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSNotificationName const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSNotificationName const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

static KQCAppEnvironmentType _environmentType;
static NSString * _channel;
static KQCAppServerType _serverType = KQCAppServerTypeMBP;

+ (void)setAppServerType:(KQCAppServerType)serverType{
    _serverType = serverType;
    [[NSNotificationCenter defaultCenter] postNotificationName:KQCApplicationServerDidChangedNotification object:@(_serverType)];
}

+ (KQCAppServerType)appServerType{
    return _serverType;
}

+ (void)setEnvironmentType:(KQCAppEnvironmentType)environmentType{
    _environmentType = environmentType;
    [[NSNotificationCenter defaultCenter] postNotificationName:KQCApplicationEnvironmentDidChangedNotification object:@(_environmentType)];
}

+ (KQCAppEnvironmentType)environmentType{
    return _environmentType;
}

+ (void)setAppChannel:(NSString *)channel{
    _channel = channel;
}

+ (NSString *)appChannel{
    return _channel ? : @"AppStore";
}

+ (NSString *)version {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)idfaString{
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    } else {
        
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        } else {
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            } else {
                
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                } else {
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

+ (NSString *)idfvString{
    if([[UIDevice currentDevice] respondsToSelector:@selector( identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return @"";
}

+ (NSArray *)backtrace{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount;i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount;i++){
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

- (void)handleException:(NSException *)exception{
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    NSArray *stackArray = nil;
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]){
        stackArray = [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey];
    }else{
        stackArray = [exception callStackSymbols];
    }
    NSString *stackStr = [stackArray componentsJoinedByString:@"\n"];
    
    NSString *formatStr = @"\n%@\n崩溃名称:%@\n崩溃原因:%@\n堆栈信息:\n%@";
    NSString *stackTrace = KQC_FORMAT(formatStr, exception ,[exception name] ,[exception reason] ,stackStr);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KQCApplicationCrashNotification object:stackTrace];
    
    //注释代码的作用是此处放开对异常的捕获，使console能继续输出crash日志。能否被第三方捕获待验证
    
    //    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]){
    //        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    //    }else{
    //        [exception raise];
    //    }
}

// WZ  弹出框不弹
//+ (UIView *)keyboardBelowWindow{
//    NSInteger count = [UIApplication sharedApplication].windows.count;
//    BOOL metTextWindow;
//    metTextWindow = NO;
//    for (NSInteger i = count-1; i>=0; i--) {
//        UIView *view = (UIView *)[[UIApplication sharedApplication].windows objectAtIndex:i];
//        if (metTextWindow && ![NSStringFromClass([view class]) isEqualToString:@"UITextEffectsWindow"]){
//            return view;
//        } else if ([NSStringFromClass([view class]) isEqualToString:@"UITextEffectsWindow"]){
//            metTextWindow = YES;
//        }
//    }
//    return KQC_TOP_WINDOW;
//}
+ (UIView *)keyboardBelowWindow{
    NSInteger count = [UIApplication sharedApplication].windows.count;
    BOOL metTextWindow;
    metTextWindow = NO;
    for (NSInteger i = count-1; i>=0; i--) {
        UIView *view = (UIView *)[[UIApplication sharedApplication].windows objectAtIndex:i];
        if (metTextWindow && ![NSStringFromClass([view class]) isEqualToString:@"UITextEffectsWindow"]){
            return view;
        } else if ([NSStringFromClass([view class]) isEqualToString:@"UITextEffectsWindow"]){
            metTextWindow = YES;
        }
    }
    UIWindow *window = KQC_TOP_WINDOW;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
        return [UIApplication sharedApplication].keyWindow;
    }
    return window;
}
//+ (UIWindow *)progressViewParentWindow{
//    __block UIWindow *window = nil;
//
//    [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([NSStringFromClass([obj class]) isEqualToString:@"UIRemoteKeyboardWindow"]) {
//            return;
//        }
//
//        window = obj;
//        *stop = YES;
//    }];
//
//    if (!window) {
//        window = KQC_TOP_WINDOW;
//    }
//    return window;
//}
+ (UIWindow *)progressViewParentWindow{
    __block UIWindow *window = nil;
    [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSStringFromClass([obj class]) isEqualToString:@"UIRemoteKeyboardWindow"]) {
            return;
        }
        window = obj;
        *stop = YES;
    }];
    if (!window) {
        window = KQC_TOP_WINDOW;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) {
        return [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

@end

void HandleException(NSException *exception){
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum){
        return;
    }
    
    [[[KQCApplication alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                                              withObject:exception
                                                           waitUntilDone:YES];
}

void SignalHandler(int signal){
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum){
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [KQCApplication backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    NSException *excep = [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                                 reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil),signal]
                                               userInfo:userInfo];
    
    [[[KQCApplication alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                                              withObject:excep
                                                           waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}
