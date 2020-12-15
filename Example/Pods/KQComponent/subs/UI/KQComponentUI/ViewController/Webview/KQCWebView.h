//
//  KQCWebview.h
//  KQCore
//
//  Created by pengkang on 2016/12/6.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol KQCWebviewDelegate;

@interface KQCWebView : WKWebView

@property (nonatomic, weak) id<KQCWebviewDelegate> kqwebviewDelegate;

@property (nonatomic, weak) UIViewController *baseVC;

@property (nonatomic, strong) id progressDelegate;

- (instancetype)initWithFrame:(CGRect)frame viewController:(UIViewController *)baseVC configuration:(WKWebViewConfiguration *)configuration;

- (instancetype)initWithFrame:(CGRect)frame viewController:(UIViewController *)baseVC;

- (instancetype)initWithWebFrame:(CGRect)frame;


/**
 执行JS方法

 @param methodName 方法名
 @param param 参数
 */
- (void)excuteJSMethod:(NSString *)methodName param:(NSString *)param, ...;

@end

@protocol KQCWebviewDelegate <NSObject>



/**
 JSBridge处理方法

 @param url 目标url
 @return 处理结果
 */
- (BOOL)kqc_jsBridge:(NSURL *)url;

@optional
/**
 接口处理

 @param methodName 方法名
 @param paramDic 参数
 @return 处理结果
 */
- (BOOL)kqc_processParam:(NSString *)methodName paramDic:(NSDictionary *)paramDic;


- (void)kqc_webviewWillStartLoad:(KQCWebView *)webView;

- (void)kqc_webviewDidStartLoad:(KQCWebView *)webView;

- (void)kqc_webviewDidFinishLoad:(KQCWebView *)webview;

- (void)kqc_webview:(KQCWebView *)kqcWebview didFailLoadWithError:(NSError *)error;

@end



