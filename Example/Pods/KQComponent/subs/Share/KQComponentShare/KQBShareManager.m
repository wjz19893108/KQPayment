//
//  KQShareManager.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/5.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQBShareManager.h"
#import "KQBShareView.h"
#import "KQPShareDataAnalyze.h"
#import "KQCShareRespFromSNS.h"
#import "KQCShareToSNS.h"
#import "KQBUserManager.h"
#import "KQBCacheManager.h"
#import "KQHttpService.h"

#define CachedWxShareInfoKey @"WxShareDataInfo"
#define ShareDesKey @"99bill99bill"
static __weak KQBShareManager *g_weakManager = nil;
/*
 在WKWebView的情况下，若重新刷新，势必会重新生成新按钮，或者后端网页变了，没有分析功能，这种情况下需要去掉旧的按钮
 这个弱引用就是这个用途
 */
//分享按钮交由调用vc自己管理 feng.zou 2016-03-24
//static __weak UIButton *g_weakShareBtn = nil;

@interface KQBShareManager ()

@property (nonatomic, strong, readwrite) UIButton *shareButton;
@property (nonatomic, strong) KQCShareData *shareData;
@property (nonatomic, assign) KQCShareType shareType;
@property (nonatomic, weak) KQCAppBaseViewController *parentVC;

@end

@implementation KQBShareManager

+ (void)registerApp:(NSString *)appid universalLink:(NSString *)universalLink {
    [KQCShareToSNS registerApp:appid universalLink:universalLink];
}

+ (void)analyzeShareDictionary:(NSDictionary*)dic parentViewController:(KQCAppBaseViewController * __nullable)parentVC
successBlock:(void(^__nullable)(KQBShareManager *manager))successBlock {
    [KQBShareManager resetData];
    [KQPShareDataAnalyze analyzeShareDictionary:dic successBlock:^(KQCShareData *shareData) {
        if (!shareData) {
            if (successBlock) {
                successBlock(nil);
            }
            return;
        }
        
        // 分享到小程序时参与引流活动的种子用户信息
        if(shareData.shareIsMiniProgram){
            NSString *encrptedStr = [KQCSecure encryptWithoutIv:KQB_CurrentUser.userMebCode desKey:ShareDesKey];
            shareData.shareSeedMebcode = encrptedStr;
        }
        
        if (successBlock) {
            successBlock([KQBShareManager initWithShareData:shareData parentViewController:parentVC]);
        }
    }];
}

+ (void)analyzeShareWebView:(WKWebView*)webView parentViewController:(KQCAppBaseViewController * __nullable)parentVC
successBlock:(void(^__nullable)(KQBShareManager *manager))successBlock {
    [KQBShareManager resetData];
    [KQPShareDataAnalyze analyzeShareWebView:webView successBlock:^(KQCShareData *shareData) {
        if (!shareData) {
            if (successBlock) {
                successBlock(nil);
            }
            return;
        }
        
        if (successBlock) {
            successBlock([KQBShareManager initWithShareData:shareData parentViewController:parentVC]);
        }
    }];
}

/*
+ (KQShareManager*)analyzeWebViewAndWebButton:(NSString*)urlString
{
    KQCShareData *shareData = [KQCShareDataAnalyze analyzeWebViewAndWebButton:urlString];
    if (!shareData) {
        return nil;
    }
    
    return [KQShareManager initWithShareData:shareData];
}*/

+ (void)resetData
{
    //[g_weakShareBtn removeFromSuperview];
}

+ (KQBShareManager*)initWithShareData:(KQCShareData*)shareData parentViewController:(KQCAppBaseViewController * __nullable)parentVC
{
    KQBShareManager *manager = [[KQBShareManager alloc] init];   
    g_weakManager = manager;
    UIButton *shareButton = [[UIButton alloc] init];
    [shareButton addTarget:manager action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    manager.shareButton = shareButton;
    manager.shareData = shareData;
    manager.parentVC = parentVC;
    return manager;
}

- (void)shareAction
{
    if (!self.shareData) {
        return;
    }
    if ([self checkRealName]) {
        return;
    }
    if (self.beforeShowShareViewBlock) {
        if (self.beforeShowShareViewBlock(self.shareData)){
            return;
        }
    }
    
    __weak __typeof(&*self)weakSelf = self;
    KQBShareView *shareView = [[KQBShareView alloc] initWithTitle:@"分享到" shareData:self.shareData];
    shareView.selectedViewBlock = ^(KQCShareType shareType){
        weakSelf.shareType = shareType;
    };
    shareView.selectedBlock = self.selectedBlock;
    [shareView show];
}

- (BOOL)checkRealName{
    if (!self.shareData.shareNeedRealName){
        return NO;
    }
    if (!self.parentVC) {
        return NO;
    }
    //TODO
//    BOOL notRealName = ![RealNameManager realNameCheck:self.parentVC tips:@"您尚未实名，无法使用该功能" logEventID:SHIMINGRUKOU_SHARE finish:NULL];
//    return notRealName;
    return YES;
}

+ (BOOL)handleOpenUrl:(NSURL *)url{
    
    BOOL isFromShare = [KQCShareRespFromSNS handleOpenUrl:url resultBlock:^(BOOL isSuccess, NSDictionary * shareDic, KQShareMessageType shareScene) {
        if (shareScene == KQShareMessageTypeLaunchFromWX) {
            // 此处统计引流信息逻辑
            NSString * encryptedSeedMebcode = shareDic[@"seedMebcode"]; // 种子用户加密后的mebcode
            NSString * seedMebcode = [KQCSecure decryptWithoutIv:encryptedSeedMebcode desKey:ShareDesKey];
            NSString * recommendOpenId = shareDic[@"recommendOpenId"]; // 推荐人openId
            NSString * recommendedOpenId = shareDic[@"recommendedOpenId"];// 被推荐人openId
            NSString * shareOriginUrl = shareDic[@"openPath"];
            if([NSString kqc_isBlank:seedMebcode]) {
                return;
            }
            
            NSDictionary *paramDic = @{@"member":@{@"openId":KQC_NON_NIL(recommendedOpenId)}, @"memberTwo":@{@"openId":KQC_NON_NIL(recommendOpenId),@"userMebCode":KQC_NON_NIL(seedMebcode)},@"url":KQC_NON_NIL(shareOriginUrl)};
            if (!KQB_CurrentUser.isLogin && [NSString kqc_isBlank:recommendedOpenId]) {
                // 缓存信息，登录后调用
                [KQBCacheManager saveValue:paramDic forKey:CachedWxShareInfoKey cacheType:KQCacheTypeMain];
                return;
            }
            
            [KQBShareManager requestM364:paramDic];
        }
        return;
    }];
    return isFromShare;
}

- (void)dealloc{
    DLog(@"%@:dealloc", self);
}

+ (void)sendShareInfoMessage {
    NSDictionary*paramDic = [KQBCacheManager loadValueForKey:CachedWxShareInfoKey cacheType:KQCacheTypeMain];
    if(!paramDic) {
        return;
    }
    [KQBShareManager requestM364:paramDic];
}

+ (void)requestM364:(NSDictionary *)dic {
    [KQHttpService request:dic bizType:@"M364" successBlock:^(id response) {
        [KQBCacheManager clearValueForKey:CachedWxShareInfoKey cacheType:KQCacheTypeUserData];
    } showWaitMode:KQHttpServiceWaitingViewModeNotShow];
}
@end
