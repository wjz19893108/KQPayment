//
//  KQBBaseWebVC.h
//  KQBusiness
//
//  Created by pengkang on 2016/12/6.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KQBBaseViewController.h"
#import "KQPJSBridge.h"

@class KQBJSBridge;

@interface KQBBaseWebVCMenuModel : NSObject

@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL needRealName;
@property (nonatomic, strong) NSString *jumpModel;
@property (nonatomic, strong) NSString *jumpTarget;
@property (nonatomic, strong) NSString *functionName;
@property (nonatomic, assign) BOOL needLogin;

@end

@interface KQBBaseWebVC : KQBBaseViewController <KQCWebviewDelegate>

@property (nonatomic, strong) KQCWebView *webView;
@property (nonatomic, strong) NSString *targetUrl;
@property (nonatomic, strong) NSString *screenTitle; // 界面title，外面传入
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) KQBJSBridge *jsBridge;

+ (void)addToWebViewUserAgent;

/**
 加载H5

 @param urlStr H5链接
 */
- (void)loadUrl:(NSString *)urlStr;

/**
 回退事件

 @param button 按钮
 */
- (void)leftBtnClick:(UIButton *)button;

/**
 添加右上角菜单

 @param dataArray 菜单数组
 */
- (void)addRightButtonWithBannerArray:(NSArray *)dataArray;

/**
 添加左上角菜单

 @param dataArray 菜单数组
 */
- (void)addLeftButtonWithBannerArray:(NSArray *)dataArray;

@end

