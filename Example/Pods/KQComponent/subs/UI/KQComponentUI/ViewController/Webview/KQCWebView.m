
//
//  KQCWebview.m
//  KQCore
//
//  Created by pengkang on 2016/12/6.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCWebView.h"
//#import "NJKWebViewProgress.h"

@interface KQCWebView()<WKNavigationDelegate, WKUIDelegate>

//@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

//@property (nonatomic, strong) KQBaseWebTask *webTask;

@end

@implementation KQCWebView{
    BOOL _authenticated;
    NSURLConnection *_urlConnection;
}

- (instancetype)initWithFrame:(CGRect)frame viewController:(UIViewController *)baseVC configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.UIDelegate = self;
        self.navigationDelegate = self;
        self.baseVC = baseVC;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame  viewController:(UIViewController *)baseVC{
    self = [super initWithFrame:frame];
    if (self) {
//        self.progressProxy = [[NJKWebViewProgress alloc] init];
//        self.delegate = _progressProxy;
//        self.progressProxy.webViewProxyDelegate = self;
        
        self.UIDelegate = self;
        self.navigationDelegate = self;
        self.baseVC = baseVC;
    }
    return self;
}
- (instancetype)initWithWebFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.progressProxy = [[NJKWebViewProgress alloc] init];
//        self.delegate = _progressProxy;
//        self.progressProxy.webViewProxyDelegate = self;
        self.UIDelegate = self;
        self.navigationDelegate = self;
        self.baseVC = nil;
    }
    return self;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    if ([_kqwebviewDelegate respondsToSelector:@selector(kqc_webviewWillStartLoad:)]) {
        [_kqwebviewDelegate kqc_webviewWillStartLoad:self];
    }
    
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    NSURL *webURL = navigationAction.request.URL;;
    NSLog(@"%@", webURL);
    if (navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlStr = [navigationAction.request.URL absoluteString];
    if([urlStr containsString:@"apps.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if ([_kqwebviewDelegate respondsToSelector:@selector(kqc_jsBridge:)]) {
        NSURL *webURL = navigationAction.request.URL;;
        if (webURL) {
            if (![_kqwebviewDelegate kqc_jsBridge:webURL]) {
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
         
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (BOOL)isJumpToExternalAppWithURL:(NSURL *)URL{
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https"]];
    return ![validSchemes containsObject:URL.scheme];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    NSURL *url = webView.URL;
    DLog(@"request url:\n%@", url.absoluteString);
    if ([_kqwebviewDelegate respondsToSelector:@selector(kqc_webviewDidStartLoad:)]) {
        [_kqwebviewDelegate kqc_webviewDidStartLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    if ([_kqwebviewDelegate respondsToSelector:@selector(kqc_webviewDidFinishLoad:)]) {
        [_kqwebviewDelegate kqc_webviewDidFinishLoad:self];
    }
}


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (challenge.previousFailureCount == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if ([_kqwebviewDelegate respondsToSelector:@selector(kqc_webview:didFailLoadWithError:)]) {
        [_kqwebviewDelegate kqc_webview:self didFailLoadWithError:error];
    }
}

- (BOOL)processSchemeParam:(NSString *)methodName paramDic:(NSDictionary *)paramDic{
    if (self.kqwebviewDelegate&&[self.kqwebviewDelegate respondsToSelector:@selector(kqc_processParam:paramDic:)]) {
        [self.kqwebviewDelegate kqc_processParam:methodName paramDic:paramDic];
    }
    return YES;
}
- (void)excuteJSMethod:(NSString *)methodName param:(NSString *)param, ...{
    if ([NSString kqc_isBlank:methodName]) {
        return;
    }
    
    NSMutableString *jsFunc = [NSMutableString stringWithFormat:@"%@(", methodName];
    if (param) {
        [jsFunc appendFormat:@"%@,", param];
        
        id otherParam;
        va_list otherParamList;
        va_start(otherParamList, param);
        while ((otherParam = va_arg(otherParamList, id))) {
            [jsFunc appendFormat:@"%@,", param];
        }
        va_end(otherParamList);
        
        // 去除最后一个逗号
        [jsFunc deleteCharactersInRange:NSMakeRange(jsFunc.length - 1, 1)];
    }
    
    [jsFunc appendString:@");"];
    
    [self evaluateJavaScript:jsFunc completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
    }];
    
//    [self stringByEvaluatingJavaScriptFromString:jsFunc];
}
- (void)dealloc
{
//    self.delegate = nil;
    self.progressDelegate = nil;
//    self.progressProxy = nil;
}


@end
