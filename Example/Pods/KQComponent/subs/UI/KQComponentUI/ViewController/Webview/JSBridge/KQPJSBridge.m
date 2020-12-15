//
//  KQPJSBridge.m
//  KQProtocol
//
//  Created by pengkang on 2016/12/7.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQPJSBridge.h"
#import "KQPJSErrorCode.h"

#define KuaiqianScheme      @"bill99app"
#define KuaiqianSchemeHost  @"kuaiqianbao"

@implementation KQPJSBridge

- (id)initWithWebView:(KQCWebView *)webView
{
    self = [super init];
    if (self) {
        [self initialize:nil webView:webView];
    }
    return self;
}

- (void)initialize:(UIViewController *)webVC webView:(KQCWebView *)webView{
    self.baseWebView = webView;
    self.jsRequestDic = [NSMutableDictionary dictionary];
}

- (BOOL)process:(NSURL *)url{
    
    if([KQCApplication environmentType] != KQCAppEnvironmentTypeDev){
        BOOL isAllow = NO;
        if(_jsDelegate && [_jsDelegate respondsToSelector:@selector(isAllowUrl:)]){
            isAllow = [_jsDelegate isAllowUrl:url];
        }
        if (!isAllow) {
            DLog(@"not allow visit::::%@", url);
            return NO;
        }
    }
    
    if (![[url scheme] isEqualToString:KuaiqianScheme]) {
        return YES;
    }
    
    if (![[url host] isEqualToString:KuaiqianSchemeHost]) {
        return YES;
    }
    
    NSMutableString *decodeString = [NSMutableString string];
    if (url.query) {
        [decodeString appendString:url.query];
    }
    
    if (url.fragment) {
        [decodeString appendFormat:@"#%@", url.fragment];
    }
    
    NSString *jsonStr = [[decodeString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *paymentParamDic = [self parseUrlParameter:jsonStr];
    
    NSString *methodName = [[url path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    SEL selector = NSSelectorFromString(KQC_FORMAT(@"%@:", methodName));
    if ([self respondsToSelector:selector]) {
        SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:paymentParamDic]);
        return NO;
    }
    
    if (_jsDelegate && [_jsDelegate respondsToSelector:@selector(processSchemeParam:paramDic:)]){
        return [_jsDelegate processSchemeParam:methodName paramDic:paymentParamDic];
    }
    
    [self failedCallback:paymentParamDic message:@{@"errorCode":ERROR_CODE_FUNCTION_NOT_FOUND, @"errorMsg":ERROR_MSG_FUNCTION_NOT_FOUND}];
    
    return YES;
}

#pragma mark - 解析
- (NSDictionary *)parseUrlParameter:(NSString *)urlQuery{
    //无参数时返回nil
    if (!urlQuery) {
        return nil;
    }
    
    NSData *data = [urlQuery dataUsingEncoding:NSUTF8StringEncoding];
    //    NSError *jsonError;
    NSMutableDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    //    DLog(@"error :: %@",[jsonError localizedDescription]);
    if (!paramDic) {
        //eg：urlQuery = orderId=20151029180010070000&ticketprice=70
        NSArray *paremeterString = [urlQuery componentsSeparatedByString:@"&"];
        
        if (paremeterString.count == 0) {
            return nil;
        }
        
        paramDic = [[NSMutableDictionary alloc] init];
        for (NSString *param in paremeterString) {
            NSArray *array = [param componentsSeparatedByString:@"="];
            
            [paramDic setObject:((param.length > [array[0] length] + 1)?[param substringFromIndex:[array[0] length]+1]:@"") forKey:array[0]];
        }
    }else{
        //eg：urlQuery = JSON
        id paramJsonObj = paramDic[@"paramJson"];
        if (paramJsonObj) {
            [paramDic removeObjectForKey:@"paramJson"];
        }
        
        if ([paramJsonObj isKindOfClass:[NSDictionary class]]) {
            [paramDic addEntriesFromDictionary:paramJsonObj];
        }
    }
    return paramDic;
}

#pragma  mark - 成功回调
- (void)successCallback:(NSDictionary *)dic message:(NSDictionary *)messageDic{
    [self excuteWebCallbackWithId:@"successCallbackId" param:dic message:messageDic];
}

#pragma  mark - 失败回调
- (void)failedCallback:(NSDictionary *)dic message:(NSDictionary *)messageDic{
    [self excuteWebCallbackWithId:@"errorCallBackId" param:dic message:messageDic];
}

- (void)excuteWebCallbackWithId:(NSString *)callbackId
                          param:(NSDictionary *)dic
                        message:(NSDictionary *)messageDic {
    if (![dic objectForKey:callbackId]) {
        return;
    }
    
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    if ([messageDic isKindOfClass:[NSDictionary class]]) {
        [resultDic addEntriesFromDictionary:messageDic];
    }
    [resultDic setObject:[dic objectForKey:callbackId] forKey:@"callbackId"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (self.baseWebView) {
        [self.baseWebView excuteJSMethod:@"kuaiqian.appCallBack" param:jsonString, nil];
        return;
    }
}

@end
