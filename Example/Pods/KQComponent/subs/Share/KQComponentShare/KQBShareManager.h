//
//  KQShareManager.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/5.
//  Copyright © 2015年 program. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KQBShareMacro.h"
#import <WebKit/WebKit.h>

@interface KQBShareManager : NSObject

/*
 点击分享按钮时，调用此block，返回YES代表业务中断分享流程，返回NO代表不中断
 */
@property (nonatomic, copy, nullable) BeforeShowShareView beforeShowShareViewBlock;

/*
 需要分享选择时执行相应的业务，请赋值该block
 */
@property (nonatomic, copy, nullable) ShareSelectedBlock selectedBlock;

/*
 需要分享成功时执行相应的业务，请赋值该block
 */
@property (nonatomic, copy, nullable) ShareSuccessBlock successBlock;

/*
 需要分享失败时执行相应的业务，请赋值该block
 */
@property (nonatomic, copy, nullable) ShareFailedBlock failedBlock;

/*
 执行过analyzeShareDictionary或analyzeShareWebView或analyzeWebViewAndWebButton时
 该UIButton才有效，该按钮的触摸事件是shareAction，直接弹出分享选择View
 */
@property (nonatomic, strong, readonly, nullable) UIButton* shareButton;

/*
 完全Native界面和分享按钮，通过分析字典来获取分享数据
 */
+ (void)analyzeShareDictionary:(NSDictionary*)dic parentViewController:(KQCAppBaseViewController * __nullable)parentVC
successBlock:(void(^)(KQBShareManager *manager))successBlock;

/*
 web界面，native分享按钮，通过分析WKWebView的element来获取分享数据
 */
+ (void)analyzeShareWebView:(WKWebView*)webView parentViewController:(KQCAppBaseViewController * __nullable)parentVC
successBlock:(void(^)(KQBShareManager *manager))successBlock;

/*
 web界面，web分享按钮，通过分享url链接来获取分享数据
 由KQBaseWebTask的process方法直接分析字符串得到字典，并调用analyzeShareDictionary方法来分析分享数据
 */
//+ (KQShareManager*)analyzeWebViewAndWebButton:(NSString*)urlString;

/*
 分享结果答复
 */
+ (BOOL)handleOpenUrl:(NSURL * __nonnull)url;

/**
 注册程序在微信注册的appid
 
 @param appid appid
 @param universalLink universalLink
 */
+ (void)registerApp:(NSString *)appid universalLink:(NSString *)universalLink;

/*
 执行过analyzeShareDictionary或analyzeShareWebView或analyzeWebViewAndWebButton时
 该方法才有效，直接弹出分享选择View
 */
- (void)shareAction;

/**
 统计引流数据
 */
+ (void)sendShareInfoMessage;

@end
