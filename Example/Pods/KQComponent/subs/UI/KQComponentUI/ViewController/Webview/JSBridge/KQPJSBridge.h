//
//  KQPJSBridge.h
//  KQProtocol
//
//  Created by pengkang on 2016/12/7.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KQCWebView.h"

@protocol KQPJSBrigeDelegate <NSObject>

/**
 是否允许加载该url

 @param url 目标url
 @return YES：允许 NO：不允许
 */
- (BOOL)isAllowUrl:(NSURL *)url;

/**
 是否已处理该请求

 @param methodName 方法名
 @param paramDic 方法参数
 @return YES：已处理 NO：不处理
 */
- (BOOL)processSchemeParam:(NSString *)methodName paramDic:(NSDictionary *)paramDic;

@end

@interface KQPJSBridge : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) id <KQPJSBrigeDelegate> jsDelegate;
@property (nonatomic, weak) KQCWebView *baseWebView;
@property (nonatomic, strong) NSMutableDictionary *jsRequestDic;

- (id)initWithWebView:(KQCWebView *)webView;

- (BOOL)process:(NSURL*)url;

/**
 *  JS Bridge 事件成功回调函数
 *  dic ：解析后的JS传入参数  e.g. {successCallBackId:"",errorCallBackId:"",xxx:""}
 *  messageDic：JS回调函数参数   e.g. NSDictionary *messageDic = @{@"result":@"ok"};
 *  更多参数详情见：http://kb.99bill.net/pages/viewpage.action?pageId=15434877
 */
- (void)successCallback:(NSDictionary *)dic message:(NSDictionary *)messageDic;

/**
 *  JS Bridge 事件失败回调函数
 *  dic ：解析后的JS传入参数  e.g. {successCallBackId:"",errorCallBackId:"",xxx:""}
 *  messageDic：JS回调函数参数   e.g. NSDictionary *messageDic = @{@"result":@"fail"};
 *  更多参数详情见：http://kb.99bill.net/pages/viewpage.action?pageId=15434877
 */
- (void)failedCallback:(NSDictionary *)dic message:(NSDictionary *)messageDic;

@end
