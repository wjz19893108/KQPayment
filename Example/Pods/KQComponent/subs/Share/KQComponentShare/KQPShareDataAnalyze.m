//
//  KQShareDataAnalyze.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/4.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQPShareDataAnalyze.h"

NSString *const KQP_SHARE_TITLE_KEY = @"shareTitle";
NSString *const KQP_SHARE_CONTENT_KEY = @"shareContent";
NSString *const KQP_SHARE_URL_KEY = @"shareUrl";
NSString *const KQP_SHARE_ICON_URL_KEY = @"shareIconUrl";
NSString *const KQP_SHARE_PREVIEW_IMAGE_URL_KEY = @"sharePreviewImageUrl";
NSString *const KQP_SHARE_NEED_REAL_NAME_KEY = @"shareNeedRealName";
NSString *const KQP_SHARE_DATA = @"shareData";
NSString *const KQP_SHARE_IS_MINIPROGRAM = @"shareMiniProgram";
NSString *const KQP_SHARE_MINIPROGRAM_PATH = @"shareMiniProgramPath";
NSString *const KQP_SHARE_IMAGE = @"shareImage";
NSString *const KQP_SHARE_IMAGE_DATA = @"shareImageData";

#define SHARE_JS_REQ(key, name)   [NSString stringWithFormat:@"document.getElementById('%@').%@", key, name]
#define GET_ELEMENT_VALUE(key)    [webView stringByEvaluatingJavaScriptFromString:SHARE_JS_REQ(key, @"value")]

@interface KQPShareDataAnalyze ()

@end

@implementation KQPShareDataAnalyze

+ (void)analyzeShareDictionary:(NSDictionary*)dic successBlock:(void(^__nullable)(KQCShareData *shareData))successBlock {
    [KQPShareDataAnalyze shareDataWithDic:dic successBlock:successBlock];
}

/*
 + (KQShareData*)analyzeWebViewAndWebButton:(NSString*)urlString
 {
 NSString *prefix = @"99billApp://kuaiqianbao/share?";
 if ([urlString hasPrefix:prefix]) {
 NSString *content = [urlString substringFromIndex:prefix.length];
 NSArray *values = [content componentsSeparatedByString:@"&"];
 __block NSString *shareTitle = nil;
 __block NSString *shareContent = nil;
 __block NSString *shareUrl = nil;
 __block NSString *shareIconUrl = nil;
 __block NSString *sharePreviewImageUrl = nil;
 [values enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL * _Nonnull stop) {
 if ([value hasPrefix:@"shareTitle="]) {
 shareTitle = [value substringFromIndex:@"shareTitle=".length];
 }
 if ([value hasPrefix:@"shareContent="]) {
 shareContent = [value substringFromIndex:@"shareContent=".length];
 }
 if ([value hasPrefix:@"shareUrl="]) {
 shareUrl = [value substringFromIndex:@"shareUrl=".length];
 }
 if ([value hasPrefix:@"shareIconUrl="]) {
 shareIconUrl = [value substringFromIndex:@"shareIconUrl=".length];
 }
 if ([value hasPrefix:@"sharePreviewImageUrl="]) {
 sharePreviewImageUrl = [value substringFromIndex:@"sharePreviewImageUrl=".length];
 }
 }];
 if ((shareTitle == nil)||(shareContent == nil)||(shareUrl == nil)||(shareIconUrl == nil)||(sharePreviewImageUrl == nil)) {
 return nil;
 }
 KQShareData *shareData = [[KQShareData alloc] init];
 shareData.shareTitle = shareTitle;
 shareData.shareContent = shareContent;
 shareData.shareUrl = shareUrl;
 shareData.shareIconUrl = shareIconUrl;
 shareData.sharePreviewImageUrl = sharePreviewImageUrl;
 return shareData;
 }
 return nil;
 }*/

+ (void)analyzeShareWebView:(WKWebView*)webView successBlock:(void(^__nullable)(KQCShareData *shareData))successBlock {
    [KQPShareDataAnalyze analyzeWebView:webView successBlock:^(NSDictionary *shareDic) {
        [KQPShareDataAnalyze shareDataWithDic:shareDic successBlock:successBlock];
    }];
}

+ (void)analyzeWebView:(WKWebView*)webView successBlock:(void(^__nullable)(NSDictionary * shareDic))successBlock {
   __block NSDictionary *shareDic = nil;
    // 先判断shareData存在不存在，优化分享预埋数据
    
    [webView evaluateJavaScript:SHARE_JS_REQ(KQP_SHARE_DATA, @"value") completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        NSString *shareDataStr = ret;
        if ([NSString kqc_isBlank:shareDataStr]) {
            if (successBlock) {
                successBlock(@{});
            }
            return;
        }
        NSData *shareData = [shareDataStr dataUsingEncoding:NSUTF8StringEncoding];
        shareDic = [NSJSONSerialization JSONObjectWithData:shareData options:NSJSONReadingMutableContainers error:nil];
        if (shareDic) {
            if (successBlock) {
                successBlock(shareDic);
            }
            return;
        }
        
        if (successBlock) {
            successBlock(@{});
        }
    }];

//    shareDic = @{KQP_SHARE_TITLE_KEY:GET_ELEMENT_VALUE(KQP_SHARE_TITLE_KEY),
//                 KQP_SHARE_CONTENT_KEY:GET_ELEMENT_VALUE(KQP_SHARE_CONTENT_KEY),
//                 KQP_SHARE_URL_KEY:GET_ELEMENT_VALUE(KQP_SHARE_URL_KEY),
//                 KQP_SHARE_ICON_URL_KEY:GET_ELEMENT_VALUE(KQP_SHARE_ICON_URL_KEY),
//                 KQP_SHARE_PREVIEW_IMAGE_URL_KEY:GET_ELEMENT_VALUE(KQP_SHARE_PREVIEW_IMAGE_URL_KEY),
//                 KQP_SHARE_NEED_REAL_NAME_KEY:GET_ELEMENT_VALUE(KQP_SHARE_NEED_REAL_NAME_KEY),
//                 KQP_SHARE_IS_MINIPROGRAM: KQC_NON_NIL(GET_ELEMENT_VALUE(KQP_SHARE_IS_MINIPROGRAM)),
//                 KQP_SHARE_MINIPROGRAM_PATH:KQC_NON_NIL(GET_ELEMENT_VALUE(KQP_SHARE_MINIPROGRAM_PATH)),
//                 };
//    return shareDic;
}

+ (void)shareDataWithDic:(NSDictionary *)shareDic successBlock:(void(^__nullable)(KQCShareData *shareData))successBlock {
    DLog(@"分享数据：%@", shareDic);
    NSString *shareTitle = [shareDic objectForKey:KQP_SHARE_TITLE_KEY];
    NSString *shareContent = [shareDic objectForKey:KQP_SHARE_CONTENT_KEY];
    NSString *shareUrl = [shareDic objectForKey:KQP_SHARE_URL_KEY];
    NSString *shareIconUrl = [shareDic objectForKey:KQP_SHARE_ICON_URL_KEY];
    NSString *sharePreviewImageUrl = [shareDic objectForKey:KQP_SHARE_PREVIEW_IMAGE_URL_KEY];
    NSString *shareNeedRealName = [shareDic objectForKey:KQP_SHARE_NEED_REAL_NAME_KEY];
    NSString *shareIsMiniProgram = [shareDic objectForKey:KQP_SHARE_IS_MINIPROGRAM];
    NSString *shareMiniProgramPath = [shareDic objectForKey:KQP_SHARE_MINIPROGRAM_PATH];
    NSString *shareImageData = [shareDic objectForKey:KQP_SHARE_IMAGE_DATA];
    
    id shareImageValue = [shareDic objectForKey:KQP_SHARE_IMAGE];
    BOOL shareImage = NO;
    if ([shareImageValue isKindOfClass:[NSString class]]) {
        shareImage = [[shareImageValue lowercaseString] isEqualToString:@"true"];
    } else if ([shareImageValue isKindOfClass:[NSNumber class]]) {
        shareImage = [shareImageValue boolValue];
    }
    
    if (!shareImage) {
        if ([NSString kqc_isBlank:shareTitle]
            || [NSString kqc_isBlank:shareContent]
            || [NSString kqc_isBlank:shareUrl]) {
            if (successBlock) {
                successBlock(nil);
            }
            return;
        }
    } else {
        if ([NSString kqc_isBlank:shareImageData]) {
            if (successBlock) {
                successBlock(nil);
            }
            return;
        }
    }
    
    NSArray *imageDataArray = [shareImageData componentsSeparatedByString:@","];
    
    KQCShareData *shareData = [[KQCShareData alloc] init];
    shareData.shareTitle = shareTitle;
    shareData.shareContent = shareContent;
    shareData.shareUrl = shareUrl;
    shareData.shareIconUrl = shareIconUrl;
    shareData.sharePreviewImageUrl = sharePreviewImageUrl;
    shareData.shareNeedRealName = [[shareNeedRealName lowercaseString] isEqualToString:@"true"];
    shareData.shareIsMiniProgram = [[shareIsMiniProgram lowercaseString] isEqualToString:@"true"];
    shareData.shareImage = shareImage;
    if (imageDataArray.count > 0) {
        if (imageDataArray.count == 1) {
            shareData.shareImageData = [NSData dataFromBase64String:imageDataArray[0]];
        } else {
            shareData.shareImageData = [NSData dataFromBase64String:imageDataArray[1]];
        }
    }
    shareData.shareMiniProgramPath = shareMiniProgramPath;
    if (successBlock) {
        successBlock(shareData);
    }
}

@end
