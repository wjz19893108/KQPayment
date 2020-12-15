
//
//  KQBBaseWebVC.m
//  KQBusiness
//
//  Created by pengkang on 2016/12/6.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBBaseWebVC.h"
#import "KQBColor.h"
#import "KQBFont.h"
#import "KQBRightBarButtonItemPopView.h"
#import "KQBJSBridge.h"
#import "UIButton+KQBAddition.h"
#import "KQCMobClick.h"

@implementation KQBBaseWebVCMenuModel

@end

@interface KQBBaseWebVC () {
//    KQBShareManager *shareManager;
    UIButton *shareButton;
}

@property (nonatomic, strong) NSString *origUrlStr;
@property (nonatomic, strong) NSString *h5Title;  // H5加载完成，从H5获取的title。当有screenTitle时，该值无效
@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) NSArray *rightButtonDataArray;
@property (nonatomic, strong) NSArray *leftButtonDataArray;
@property (nonatomic, strong) UIProgressView *myProgressView;

@end

@implementation KQBBaseWebVC

static const NSString *kTitle = @"title";
static const NSString *kIcon = @"icon";

- (id)init
{
    self = [super init];
    if (self) {
        //to do
        [self initialize];
    }
    return self;
}

- (void)initializeErrorView{
    CGFloat yMargin = 60.f;
    
    self.errorView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.errorView.backgroundColor = self.contentView.backgroundColor;
    [self.contentView addSubview:self.errorView];
    
    UIImage *errorImage = [UIImage imageNamed:@"pic_noweb"];
    UIImageView *errorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yMargin * KQC_HEIGHT_RATIO, errorImage.size.width, errorImage.size.height)];
    errorImageView.image = errorImage;
    [self.errorView addSubview:errorImageView];
    errorImageView.centerX = self.errorView.width / 2;
    
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, errorImageView.bottom, self.errorView.width, 50.f)];
    errorLabel.text = @"网络异常，请您尝试刷新";
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.textColor = [KQBColor colorWithType:KQBColorTypeTextFieldInfo];
    errorLabel.font = [KQBFont fontWithType:KQBFontTypeTextFieldDetail];
    errorLabel.textAlignment = NSTextAlignmentCenter;
    [self.errorView addSubview:errorLabel];
    
    UIButton *refreshButton = [KQSecondaryButton secondaryButtonWithType:UIButtonTypeCustom title:@"刷新" frame:CGRectMake(0, errorLabel.bottom, 145, 44.f) target:self action:@selector(refreshButtonClick:) tag:0];
    [self.errorView addSubview:refreshButton];
    refreshButton.centerX = errorImageView.centerX;
}

- (void)refreshButtonClick:(UIButton *)button{
    [self loadUrl:self.targetUrl];
    self.errorView.hidden = YES;
}

- (void)initialize{
    self.jsBridge = [[KQBJSBridge alloc] initWithWebView:self.webView];
}

+ (void)addToWebViewUserAgent
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WKWebView *webView = [WKWebView new];
        [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable oldAgent, NSError * _Nullable error) {
            if (![oldAgent isKindOfClass:[NSString class]]) {
                // 为了避免没有获取到oldAgent，所以设置一个默认的userAgent
                // Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
                oldAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU iPhone OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", [[UIDevice currentDevice] model], [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
            }
            
            //自定义user-agent
//            if (![oldAgent hasSuffix:addAgent]) {
                
                NSString *version = [KQCApplication version];
                
                NSString *newAgent = [oldAgent stringByAppendingFormat:@" KuaiQianBao/%@",version];
                [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":newAgent}];
                // 一定要设置customUserAgent，否则执行navigator.userAgent拿不到oldAgent
                
                if (@available(iOS 9.0, *)) {
                    webView.customUserAgent = newAgent;
                }
                
//            }
        }];
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![NSString kqc_isBlank:self.screenTitle]) {
        [self setNavigationTitle:self.screenTitle];
    }
    
    self.navigationController.navigationBar.translucent = NO;
    
    // 解决https://cc.rrxiu.cc/v/czlbc1?v=czlbc1页面加载放大问题，因此注释掉如下写法
//    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    NSString *jScript = @"";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    // 偏好配置
    WKPreferences *preference = [[WKPreferences alloc] init];
    preference.minimumFontSize = 0;     // 最小字体大小，当将 javaScriptEnabled 属性设为 NO 时，可以看到明显的效果
    preference.javaScriptCanOpenWindowsAutomatically = YES; // iOS默认为NO，MacOS默认为YES，是否允许不经过用户交互由 JS 自动打开窗口
    preference.javaScriptEnabled = YES; // 是否允许页面执行 js
    wkWebConfig.preferences = preference;
    
    _webView = [[KQCWebView alloc] initWithFrame:self.contentView.bounds viewController:self configuration:wkWebConfig];
    //    _webView.scalesPageToFit = YES;
//    _webView.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height - 44);
//    _webView.scrollView.contentSize = CGSizeMake(self.contentView.width, self.contentView.height);
    _webView.backgroundColor = [UIColor clearColor];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _webView.allowsBackForwardNavigationGestures = YES;
    //    _webView.delegate = self;
    [self.contentView addSubview:_webView];
    
    _webView.progressDelegate = self;
    _webView.kqwebviewDelegate = self;
    
//    self.contentView.scrollEnabled = NO;
    self.showCloseButton = YES;
    [self addLeftButton:@"" Action:@selector(leftBtnClick:)];
    [self setPanGestureFlag:NO];
    
    
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    self.myProgressView.frame = barFrame;

    self.jsBridge.baseWebView = _webView;
    
    if (self.fileData) {
        [self loadViewWithData:self.fileData baseUrl:self.targetUrl];
    }else{
        [self loadUrl:self.targetUrl];
    }
    
     [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)loadViewWithData:(NSData *)data baseUrl:(NSString *)url{
//    _webView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    if (@available(iOS 9.0, *)) {
        [_webView loadData:self.fileData
                     MIMEType:@"text/html"
        characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:self.targetUrl]];
        
    }else {
        [self.view addSubview:_webView];
        [_webView loadHTMLString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] baseURL:[NSURL URLWithString:self.targetUrl]];
    }
    
//    [_webView loadData:self.fileData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:self.targetUrl]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    // 外面传递了标题进来，不展示H5的标题
    if (![NSString kqc_isBlank:self.screenTitle]) {
        return;
    }
    
    if ([NSString kqc_isBlank:self.h5Title]
        || [self.h5Title isEqualToString:self.titleLabel.text]) {
        return;
    }
    
    [self setNavigationTitle:self.h5Title];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.myProgressView removeFromSuperview];
}

- (void)leftBtnClick:(UIButton *)button{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        [KQC_Engine_UI popViewController];
    }
}

- (void)loadUrl:(NSString *)urlStr {
    _targetUrl = urlStr;
    
    //此方法在9.0以后废弃。此处任然沿用老的方法，可以避免%的二次转义。替换方法不推荐对整URL处理，所以暂时弃用。--by：lihui
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)urlStr,
                                                                                                    (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                                    NULL,
                                                                                                    kCFStringEncodingUTF8));
    
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    _origUrlStr = [[urlRequest URL] absoluteString];
    [_webView loadRequest:urlRequest];
}

#pragma mark - KQCWebViewDelegate
- (void)kqc_webviewWillStartLoad:(KQCWebView *)webView{
    if (self.isShowCloseButton) {
        // 延迟计算关闭按钮，等待主现成排队
        dispatch_async(dispatch_get_main_queue(), ^(void){
//            WKBackForwardList *backForwardList = [self.webView backForwardList];
            self.closeButton.hidden = !self.webView.canGoBack;
        });
    }
}

- (void)kqc_webviewDidStartLoad:(KQCWebView *)webView{
//
//    CGFloat progressBarHeight = 2.f;
//       CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
//       CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
}

- (void)kqc_webviewDidFinishLoad:(KQCWebView *)webview{
    if ([NSString kqc_isBlank:self.screenTitle]) { // 有screenTitle就不考虑H5的title了
        [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id ret, NSError *error) {
           
            if ([ret isKindOfClass:[NSString class]]) {
                NSString *retStr = (NSString *)ret;
                
                self.h5Title = KQC_NON_NIL(retStr);
                
                if (self.lifeCycle >= KQAppBaseViewControllerLifeCycleViewDidAppear) { // 界面加载完成，设置标题，否则会来回弹
                    [self setNavigationTitle:self.h5Title];
                }
            }
        }];
    }

    [self analyzeShareWebView:webview];
    
//    NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:webview.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSHTTPURLResponse *tmpresponse = (NSHTTPURLResponse*)response;
//        if (tmpresponse.statusCode >= 300) {
//            [KQCMobClick realTimeEvent:@"H5Error" attributes:@{@"url":KQC_NON_NIL(self.targetUrl),@"description":KQC_FORMAT(@"%ld", (long)tmpresponse.statusCode)}];
//        }
//    }];
//    [dataTask resume];
}

- (void)kqc_webview:(KQCWebView *)KQCWebView didFailLoadWithError:(NSError *)error{
    if (error.code == NSURLErrorCancelled
        || ![error.userInfo[NSURLErrorFailingURLStringErrorKey] isEqualToString:self.origUrlStr]) {
        return;
    }
    //获取H5异常埋点信息
    [KQCMobClick realTimeEvent:@"H5Error" attributes:@{@"url":KQC_NON_NIL(self.targetUrl),@"description":KQC_FORMAT(@"%ld", (long)error.localizedFailureReason)}];
    
    if (self.errorView) {
        self.errorView.hidden = NO;
        return;
    }
    self.h5Title = @"错误页面";
    [self initializeErrorView];
}


- (BOOL)kqc_jsBridge:(NSURL *)url{
    return [self.jsBridge process:url];
}

#pragma mark - NavigationBarRightMenu
- (void)addRightButtonWithBannerArray:(NSArray *)dataArray{
    self.rightButtonDataArray = dataArray;
    if (self.rightButtonDataArray.count == 0) {
        [self addRightButtonWithTitle:nil Action:nil];
        return;
    }
    
    if (self.rightButtonDataArray.count == 1) {
        KQBBaseWebVCMenuModel *menu = self.rightButtonDataArray[0];
        if (![NSString kqc_isBlank:menu.iconUrl]) {
            [self addRightButtonWithImage:menu.iconUrl Action:@selector(rightButtonClick:)];
        } else {
            [self addRightButtonWithTitle:menu.name Action:@selector(rightButtonClick:)];
        }
    } else {
        [self addRightButtonWithEnabled:nil imageName:@"gengduo" action:@selector(rightButtonClick:) enabled:YES];
    }
}

- (void)rightButtonClick:(UIButton *)button{
    if (self.rightButtonDataArray.count == 0) {
        return;
    }
    
    if (self.rightButtonDataArray.count == 1) {
        KQBBaseWebVCMenuModel *menu = self.rightButtonDataArray[0];
        [self executeMethod:menu];
        return;
    }
    
    NSMutableArray *titleArray = [NSMutableArray array];
    [self.rightButtonDataArray enumerateObjectsUsingBlock:^(KQBBaseWebVCMenuModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [titleArray addObject:@{kTitle:obj.name, kIcon:KQC_NON_NIL(obj.iconUrl)}];
    }];
    
    
    CGPoint point = CGPointMake(KQC_SCREEN_WIDTH - 25.f, button.bottom + 15);
    KQBRightBarButtonItemPopView *pop = [[KQBRightBarButtonItemPopView alloc] initWithPoint:point popViewArray:titleArray];
    pop.borderColor = [UIColor whiteColor];
    pop.fillColor = [UIColor whiteColor];
    pop.fontColor = [UIColor blackColor];
    pop.textAlignment = NSTextAlignmentLeft;
    pop.maskColor = [UIColor blackColor];
    pop.maskAlpha = 0.2f;
    pop.selectRowAtIndex = ^(NSInteger index){
        KQBBaseWebVCMenuModel *menu = self.rightButtonDataArray[index];
        [self executeMethod:menu];
    };
    [pop show];
}

#pragma mark - NavigationBarLeftMenu
- (void)addLeftButtonWithBannerArray:(NSArray *)dataArray{
    self.leftButtonDataArray = dataArray;
    if (self.leftButtonDataArray.count == 0) {
        [self addLeftButton:nil Action:nil];
        return;
    }
    
    if (self.leftButtonDataArray.count == 1) {
        KQBBaseWebVCMenuModel *menu = self.leftButtonDataArray[0];
        [self addLeftBannerButton:menu.name imageName:menu.iconUrl Action:@selector(leftButtonClick:)];
    } else {
        [self addLeftButton:@"" imageName:@"gengduo" Action:@selector(leftButtonClick:)];
    }
}

- (void)leftButtonClick:(UIButton *)button{
    if (self.leftButtonDataArray.count == 0) {
        return;
    }
    
    if (self.leftButtonDataArray.count == 1) {
        KQBBaseWebVCMenuModel *menu = self.leftButtonDataArray[0];
        [self executeMethod:menu];
        return;
    }
    
    NSMutableArray *titleArray = [NSMutableArray array];
    [self.leftButtonDataArray enumerateObjectsUsingBlock:^(KQBBaseWebVCMenuModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [titleArray addObject:@{kTitle:obj.name, kIcon:KQC_NON_NIL(obj.iconUrl)}];
    }];
    
    
    CGPoint point = CGPointMake(25.f, button.bottom + 15);
    KQBRightBarButtonItemPopView *pop = [[KQBRightBarButtonItemPopView alloc] initWithPoint:point popViewArray:titleArray];
    pop.selectRowAtIndex = ^(NSInteger index){
        KQBBaseWebVCMenuModel *menu = self.leftButtonDataArray[index];
        [self executeMethod:menu];
    };
    [pop show];
}

- (void)executeMethod:(KQBBaseWebVCMenuModel *)menu{
    if ([NSString kqc_isBlank:menu.functionName]) {
        KQBScreenJumpModel *jumpModel = [KQBScreenJumpModel jumpModelWithJumpMode:menu.jumpModel jumpTarget:menu.jumpTarget isNeedLogin:menu.needLogin isNeedRealName:menu.needRealName];
        [[KQBScreenJumpManager sharedKQBScreenJumpManager] handleDirect:jumpModel];
        return;
    }
    
    if (!menu.needLogin) {
        [self.webView excuteJSMethod:menu.functionName param:nil];
        return;
    }
    
    [ComponentManager.userStatusDelegate userShouldLogin:^(BOOL isSuccess) {
        if (!isSuccess) {
            return;
        }
        
        if (!menu.needRealName) {
            [self.webView excuteJSMethod:menu.functionName param:nil];
            return;
        }
        
        [ComponentManager.userStatusDelegate userShouldRealName:^(BOOL isSuccess) {
            if (isSuccess) {
                [self.webView excuteJSMethod:menu.functionName param:nil];
            }
        } tips:@"您尚未实名，无法使用该功能"];
    }];
}

- (void)dealloc
{
    
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.webView.UIDelegate = nil;
    self.webView.navigationDelegate = nil;
    self.webView = nil;
}

#pragma mark - share
- (void)analyzeShareWebView:(WKWebView *)webView {
    [shareButton removeFromSuperview];
    
    [KQBShareManager analyzeShareWebView:webView parentViewController:self successBlock:^(KQBShareManager *shareManager) {
        if (!shareManager) {
            return;
        }

        if (shareManager.shareButton) {
            //防止重复刷新生成分享按钮 feng.zou 2016-03-24
            self->shareButton = shareManager.shareButton;
            [shareManager.shareButton setFrame:CGRectMake(0, 0, 44, 44)];
            shareManager.shareButton.backgroundColor = [UIColor clearColor];
            shareManager.shareButton.navgationImageName = @"ic_share";
            [self addCustomButton:shareManager.shareButton];
        }
        //由于可能会使用实名认证，当推入实名时改View不要销毁，feng.zou 2015-11-17
        self.isCanSave = YES;
    }];
}
        

#pragma mark - event response
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        [self.myProgressView setProgress:newprogress];
        if (newprogress >= 1.0f) {
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.myProgressView.alpha = 0.0f;
                             }
                             completion:^(BOOL finished) {
                                 [self.myProgressView setProgress:0 animated:NO];
                             }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UIProgressView *)myProgressView {
    if (!_myProgressView) {
        _myProgressView = [[UIProgressView alloc] init];
        _myProgressView.tintColor = [UIColor redColor];
        _myProgressView.trackTintColor = [UIColor whiteColor];
        [self.navigationController.navigationBar addSubview:_myProgressView];
    }
    return _myProgressView;
}

@end
