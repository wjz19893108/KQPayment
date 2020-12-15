//
//  KQShareDataAnalyze.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/4.
//  Copyright © 2015年 program. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/*
 分享字段key常量定义
 */
FOUNDATION_EXTERN NSString *const KQP_SHARE_TITLE_KEY;                // 分享标题
FOUNDATION_EXTERN NSString *const KQP_SHARE_CONTENT_KEY;              // 分享内容
FOUNDATION_EXTERN NSString *const KQP_SHARE_URL_KEY;                  // 分享目标URL
FOUNDATION_EXTERN NSString *const KQP_SHARE_ICON_URL_KEY;             // 分享界面的ICON，可空
FOUNDATION_EXTERN NSString *const KQP_SHARE_PREVIEW_IMAGE_URL_KEY;    // 分享到QQ的预览图片，可空
FOUNDATION_EXTERN NSString *const KQP_SHARE_NEED_REAL_NAME_KEY;       // 本次分享是否需要实名，可空，默认不需要
FOUNDATION_EXTERN NSString *const KQP_SHARE_DATA;                     // 分享数据的json格式，为上面6个key的集合

@class KQCShareData;
@interface KQPShareDataAnalyze : NSObject

/**
 根据字典组装待分享的数据

 @param dic 源字典
 @param successBlock 待分享数据
 */
+ (void)analyzeShareDictionary:(NSDictionary *)dic successBlock:(void(^)(KQCShareData *shareData))successBlock;

//+ (KQShareData*)analyzeWebViewAndWebButton:(NSString*)urlString;

/**
 直接从webview中加载的H5页面解析有没有分享的数据

 @param webView 加载H5完成的webview
 @param successBlock 待分享数据
 */
+ (void)analyzeShareWebView:(WKWebView *)webView successBlock:(void(^)(KQCShareData *shareData))successBlock;

@end
