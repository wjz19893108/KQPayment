//
//  KQBBaseViewController.m
//  KQBusiness
//
//  Created by pengkang on 2016/12/7.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBColor.h"
#import "KQBFont.h"
#import "KQBToastView.h"
#import "KQBBaseViewController.h"
#import <UIButton+WebCache.h>
#import "KQSwipeCardHttpService.h"

#define kBarButtonWidth    70
#define kBarButtonTintColor UIColorFromRGB(33, 33, 33)
#define kTagBgImageView 1234
#define kBackButtonFrame    CGRectMake(0, 0, kBarButtonWidth, KQC_NAVIGATIONBAR_HEIGHT)

@interface KQBBaseViewController (){
    CGRect   textFieldParentViewframe;
    UIPanGestureRecognizer *_recognizer;
}

@property (nonatomic, strong) UIBarButtonItem *leftBarButton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) UIButton *customButton;  // 导航栏右边，靠近中间的按钮
@property (nonatomic, strong) UIButton *leftButton;    // 导航栏最左边按钮

@end

@implementation KQBBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.shadowImage = [UIImage kqc_imageWithColor:UIColorFromRGB(0xe0, 0xe2, 0xe8) size:CGSizeMake(KQC_SCREEN_WIDTH, 0.5f)];
    self.view.backgroundColor = [UIColor blackColor];
    self.showCloseButton = NO;
    [[UIApplication sharedApplication].windows[0] makeKeyWindow];
    [UIApplication sharedApplication].keyWindow.backgroundColor = [KQBColor colorWithType:KQBColorTypeNavigationBarBg] ;
    
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    DLog(@"DebugScreenLog: ----------------------------------------enter Class----( %@ )", NSStringFromClass(self.class));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self checkHasTabBar]) {
        self.tabBarController.navigationItem.titleView = self.titleLabel;
        self.tabBarController.navigationItem.leftBarButtonItem = self.leftBarButton;
        self.tabBarController.navigationItem.rightBarButtonItem = self.rightBarButton;
    }
    
    [KQC_Engine_UI clearGestureScreenView];
    
    [self setNavigationColor:self.currentNavgationBarColor];
    [UIApplication sharedApplication].statusBarStyle = (self.navigationBarStyle == KQNavgationStyleBlack)?UIStatusBarStyleDefault:UIStatusBarStyleLightContent;
    
    if (self.navigationBarStyle == KQNavgationStyleBlack) {
        if (@available(iOS 13.0, *)) {
               [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
        } else {
           [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    [KQCStatisticsManager beginLogPageView:self];
    if (!self.isLoaded) { // 放在这里，主要为了防止某些界面在viewDidLoad里面写布局
        [self setupStatisticsEvent];
    }
}

- (void)setCurrentPageBackgroundColor {
    _contentView.backgroundColor = [KQBColor colorWithType:KQBColorTypeViewBg];
    self.view.backgroundColor = [KQBColor colorWithType:KQBColorTypeViewBg];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isLoaded = YES;
    [KQCStatisticsManager endLogPageView:self];
}

- (void)setupStatisticsEvent{
    
}

- (void)loadView
{
    [super loadView];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationBarStyle = KQNavgationStyleBlack;
    self.currentNavgationBarColor = [KQBColor colorWithType:KQBColorTypeNavigationBarNew];
    
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.userInteractionEnabled = NO;
    self.bgImageView.backgroundColor = [KQBColor colorWithType:KQBColorTypeViewBg];
    self.bgImageView.frame = self.view.bounds;
    self.bgImageView.tag = kTagBgImageView;
    [self.view insertSubview:self.bgImageView atIndex:0];
    
    _contentView = [[UIScrollView alloc] init];
    CGFloat yOffset = 0;
    CGFloat height = [self calcContentViewHeight:&yOffset];
    _contentView.frame = CGRectMake(0, yOffset, KQC_SCREEN_WIDTH, height);
    _contentView.contentSize = CGSizeMake(_contentView.width, _contentView.height + 1);
    [self.view addSubview:_contentView];
    [self setCurrentPageBackgroundColor];
}

- (void)setNavigationBarStyle:(KQNavgationStyle)navigationBarStyle {
    _navigationBarStyle = navigationBarStyle;
    [UIApplication sharedApplication].statusBarStyle = (navigationBarStyle == KQNavgationStyleBlack)?UIStatusBarStyleDefault:UIStatusBarStyleLightContent;
    [self resetNavgationButtonStyle];
}

- (void)resetNavgationButtonStyle {
    [self.leftButton changeButtonStyle:self.navigationBarStyle];
    [self.closeButton changeButtonStyle:self.navigationBarStyle];
    [self.rightButton changeButtonStyle:self.navigationBarStyle];
    [self.customButton changeButtonStyle:self.navigationBarStyle];
}

- (CGFloat)calcContentViewHeight:(CGFloat *)yOffset{
    CGFloat contentViewHeight = KQC_SCREEN_HEIGHT;
    
    if (!self.navigationBarHidden) {
        contentViewHeight -= KQC_NAVIGATIONBAR_HEIGHT;
        contentViewHeight -= KQC_STATUSBAR_NEW_HEIGHT;
    }
    
    if (self.tabBarController) {
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        if ([systemVersion doubleValue] < [@"7.1" doubleValue]) {
            if (yOffset != NULL) {
                *yOffset = KQC_SCREEN_HEIGHT - contentViewHeight;
            }
        }
        contentViewHeight -= KQC_TABBAR_HEIGHT;
    }
    return contentViewHeight;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_activeField];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    _contentView = nil;
    //    _bgImage = nil;
    _activeField = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)checkHasTabBar{
    return (self.tabBarController != nil);
}

- (UINavigationItem *)currentNavigationItem{
    if ([self checkHasTabBar]) {
        return self.tabBarController.navigationItem;
    }
    return self.navigationItem;
}

#pragma mark - 导航栏右边按钮
-(void)addRightButton:(NSString *)title imageName:(NSString *)imageName action:(SEL)action{
    [self addRightButtonWithEnabled:title imageName:imageName action:action enabled:YES];
}
-(void)addRightButtonWithEnabled:(NSString *)title imageName:(NSString *)imageName action:(SEL)action enabled:(BOOL)enabled{
    if (!title && !imageName) {
        UINavigationItem *navigationItem = [self currentNavigationItem];
        navigationItem.rightBarButtonItem = nil;
        
        self.rightButton = nil;
        self.rightBarButton = nil;
        [self resetNavigationRightView];
        return;
    }
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.frame = CGRectMake(0, 0, kBarButtonWidth, KQC_NAVIGATIONBAR_HEIGHT);
    [self.rightButton addTarget:self action:action forControlEvents:UIControlEventTouchDown];
    
    self.rightButton.enabled = enabled;
    if (title) {
        if (enabled) {
            [self.rightButton setTitleColor:kBarButtonTintColor forState:UIControlStateNormal];
        } else  {
            [self.rightButton setTitleColor:[KQBColor colorWithType:KQBColorTypeButtonInfoLabelColor] forState:UIControlStateNormal];
        }
        [self.rightButton.titleLabel setFont:[KQBFont fontWithType:KQBFontTypeButtonNormal]];
        self.rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        //设置最小字体为12，虽然开启根据label大小自动缩放字体，但是设置最小字体保证不至于缩小的太少
        self.rightButton.titleLabel.minimumScaleFactor = 12/14.0;
        self.rightButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        //        rightButton.titleLabel.textAlignment = NSTextAlignmentRight;
        self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
        [self.rightButton setTitle:title forState:UIControlStateNormal];
    }else{
        if ([imageName hasPrefix:@"http://"]
            || [imageName hasPrefix:@"https://"]) {
            [self.rightButton sd_setImageWithURL:[NSURL URLWithString:imageName] forState:UIControlStateNormal];
        } else {
            self.rightButton.navgationImageName = imageName;
        }
    }
    
    [self resetNavigationRightView];
    [self resetNavgationButtonStyle];
    
    if (!title) {
        return;
    }
    if (enabled) {
        [self.rightButton setTitleColor:kBarButtonTintColor forState:UIControlStateNormal];
    } else  {
        [self.rightButton setTitleColor:[KQBColor colorWithType:KQBColorTypeTextFieldInfo] forState:UIControlStateNormal];
    }
}

#pragma mark - 导航栏右边按钮
//-(void)addRightButtonTitleAndImage:(NSString *)title imageName:(NSString *)imageName action:(SEL)action{
//    if (!title && !imageName) {
//        self.rightBarButton = nil;
//        return;
//    }
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightButton.frame = CGRectMake(0, 0, kBarButtonWidth, KQC_NAVIGATIONBAR_HEIGHT);
//    [rightButton addTarget:self action:action forControlEvents:UIControlEventTouchDown];
//
//
//    [rightButton setTitleColor:kBarButtonTintColor forState:UIControlStateNormal];
//    [rightButton.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17.0f]];
//    rightButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//
//    rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 25);
//    [rightButton setTitle:title forState:UIControlStateNormal];
//
//    [rightButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//    rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
//
//    UIBarButtonItem* tempButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    self.rightBarButton = tempButton;
//    UINavigationItem *navigationItem = [self currentNavigationItem];
//    navigationItem.rightBarButtonItem = tempButton;
//}

- (void)addRightButtonWithView:(UIView *)view{
    if (!view ) {
        self.rightBarButton = nil;
        return;
    }
    UIBarButtonItem* tempButton = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.rightBarButton = tempButton;
    UINavigationItem *navigationItem = [self currentNavigationItem];
    navigationItem.rightBarButtonItem = tempButton;
}

- (void)addRightButtonWithTitle:(NSString *)title Action:(SEL)action{
    [self addRightButton:title imageName:nil action:action];
}

- (void)addRightButtonWithImage:(NSString *)imageName Action:(SEL)action{
    [self addRightButton:nil imageName:imageName action:action];
}

- (void)addRightButtonWithTooLongTitle:(NSString *)title Action:(SEL)action{
    if (!title) {
        self.rightBarButton = nil;
        return;
    }
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, kBarButtonWidth+10, KQC_NAVIGATIONBAR_HEIGHT);
    [rightButton addTarget:self action:action forControlEvents:UIControlEventTouchDown];
    [rightButton setTitleColor:kBarButtonTintColor forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    rightButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    //    rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 25);
    [rightButton setTitle:title forState:UIControlStateNormal];
    
    UIBarButtonItem* tempButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.rightBarButton = tempButton;
    UINavigationItem *navigationItem = [self currentNavigationItem];
    navigationItem.rightBarButtonItem = tempButton;
    
    [self resetNavgationButtonStyle];
}

#pragma mark - 设置自定义的导航栏标题
// 这个方法会被（KQBBaseViewController+KQSCTheme）勾
- (void)setNavigationTitle:(NSString *)title{
    if (self.navigationBarStyle == KQNavgationStyleBlack) {
        [self setNavigationTitle:title color:kBarButtonTintColor];
    } else {
        [self setNavigationTitle:title color:[UIColor whiteColor]];
    }
}

- (void)setNavigationTitle:(NSString *)title color:(UIColor*)color {
    UILabel *titleLabel = [[UILabel alloc] init];
    //设置x为KQC_SCREEN_WIDTH的原因是当打开VC时由于设置titleLabel的原因，titleLabel的原有frame变成居中过程能看到切换frame的效果，所以会有瞬移的过程，直接设置x为屏幕宽度，这样加载时titleLabel的初始位置在屏幕外，就不会看到瞬移的过程了
    titleLabel.frame = CGRectMake(KQC_SCREEN_WIDTH, 0, KQC_SCREEN_WIDTH - (kBarButtonWidth + 10) * 2, KQC_NAVIGATIONBAR_HEIGHT);
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    titleLabel.textColor = color;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 15/17.0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if (KQC_IS_IPHONE6P) {
        [titleLabel sizeToFit];
    }
    self.titleLabel = titleLabel;
    //master 无此问题，原因未知
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    UINavigationItem *navigationItem = [self currentNavigationItem];
    navigationItem.titleView = titleLabel;
}

#pragma mark - 设置Navigation的颜色
- (void)setNavigationColor:(UIColor*)color {
    [self setNavigationColor:color duration:0.0f];
}

- (void)setNavigationColor:(UIColor*)color duration:(CGFloat)time {
    self.currentNavgationBarColor = color;
    if (time > 0.01f) {
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.duration = time;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.navigationController.navigationBar.layer addAnimation:transition forKey:nil];
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage kqc_imageWithColor:color size:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - 设置自定义的导航栏样式
- (void)setNavigationWithView:(UIView *)view{
    UINavigationItem *navigationItem = [self currentNavigationItem];
    self.titleLabel = (UILabel *)view;
    navigationItem.titleView = view;
}
#pragma mark - 导航栏左边按钮
-(void)addLeftButton:(NSString *)title Action:(SEL)action{
    [self addLeftButton:title imageName:@"ic_navigationBtn" Action:action];
}

#pragma mark - 添加手势返回
- (void)addPanGesture{
    self.panGestureFlag = YES;
    if (_recognizer) {
        return;
    }
    _recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureEvents:)];
    [self.view addGestureRecognizer:_recognizer];
}

#pragma mark - 手势响应事件 TO DO
- (void)panGestureEvents:(UIPanGestureRecognizer *)recoginzer{
    KQCPanGestureNavigationController *nav = (KQCPanGestureNavigationController *)self.navigationController;
    [nav panGestureEvents:recoginzer];
}

- (void)setPanGestureFlag:(BOOL)panGestureFlag{
    _panGestureFlag = panGestureFlag;
    _recognizer.enabled = panGestureFlag;
}

- (void)addLeftButton:(NSString *)title
            imageName:(NSString *)imageName
               Action:(SEL)action{
    [self addPanGesture];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBarButtonWidth, KQC_NAVIGATIONBAR_HEIGHT)];
    
    self.leftButton = nil;
    if (![NSString kqc_isBlank:title]
        || ![NSString kqc_isBlank:imageName]) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftButton.frame = kBackButtonFrame;
        [self.leftButton addTarget:self action:action forControlEvents:UIControlEventTouchDown];
        if ([NSString kqc_isBlank:title]) {
            self.leftButton.navgationImageName = imageName;
            self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -17.5, 0, 17.5);
        } else {
            [self.leftButton setTitle:title forState:UIControlStateNormal];
            [self.leftButton.titleLabel setFont:[KQBFont fontWithType:KQBFontTypeButtonNormal]];
            self.leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [self.leftButton setTitleColor:[KQBColor colorWithType:KQBColorTypeTextFieldMajor] forState:UIControlStateNormal];
        }
        [leftView addSubview:self.leftButton];
    }
    
    if (self.isShowCloseButton) {
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.navgationImageName = @"ic_navigation_close";
        [self.closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.leftButton) {
            self.closeButton.frame = CGRectMake(35, 0, kBarButtonWidth, KQC_NAVIGATIONBAR_HEIGHT);
            self.closeButton.hidden = YES;
        } else {
            self.closeButton.frame = kBackButtonFrame;
        }
        
        self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
        
        [leftView addSubview:self.closeButton];
    }
    
    UIBarButtonItem* tempButton = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.leftBarButton = tempButton;
    UINavigationItem *navigationItem = [self currentNavigationItem];
    navigationItem.leftBarButtonItem = tempButton;
    
    [self resetNavgationButtonStyle];
}

- (void)addCustomButton:(UIButton *)customButton{
    self.customButton = customButton;
    [self resetNavigationRightView];
    [self resetNavgationButtonStyle];
}

- (void)addLeftBannerButton:(NSString *)title
                  imageName:(NSString *)imageName
                     Action:(SEL)action {
    [self addPanGesture];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBarButtonWidth, KQC_NAVIGATIONBAR_HEIGHT)];
    
    self.leftButton = nil;
    if (![NSString kqc_isBlank:title]
        || ![NSString kqc_isBlank:imageName]) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftButton.frame = kBackButtonFrame;
        [self.leftButton addTarget:self action:action forControlEvents:UIControlEventTouchDown];
        if (![NSString kqc_isBlank:imageName]) {
            if ([imageName hasPrefix:@"http://"]
                || [imageName hasPrefix:@"https://"]) {
                [self.leftButton sd_setImageWithURL:[NSURL URLWithString:imageName] forState:UIControlStateNormal];
            } else {
                self.leftButton.navgationImageName = imageName;
            }
            self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -17.5, 0, 17.5);
        } else {
            [self.leftButton setTitle:title forState:UIControlStateNormal];
            [self.leftButton.titleLabel setFont:[KQBFont fontWithType:KQBFontTypeButtonNormal]];
            self.leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            [self.leftButton setTitleColor:[KQBColor colorWithType:KQBColorTypeTextFieldMajor] forState:UIControlStateNormal];
        }
        [leftView addSubview:self.leftButton];
    }
    
    UIBarButtonItem* tempButton = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.leftBarButton = tempButton;
    UINavigationItem *navigationItem = [self currentNavigationItem];
    navigationItem.leftBarButtonItem = tempButton;
    
    [self resetNavgationButtonStyle];
}

- (void)resetNavigationRightView{
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBarButtonWidth, KQC_NAVIGATIONBAR_HEIGHT)];
    if (self.rightButton && !self.rightButton.hidden) {
        [self.rightButton removeFromSuperview];
        
        [rightView addSubview:self.rightButton];
        if (self.customButton && !self.customButton.hidden) {
            [self.customButton removeFromSuperview];
            self.customButton.frame = CGRectMake(0, 0, kBarButtonWidth / 2, KQC_NAVIGATIONBAR_HEIGHT);
            self.customButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
            [rightView addSubview:self.customButton];
            
            if (![NSString kqc_isBlank:self.rightButton.titleLabel.text]) {
                self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            } else {
                self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, -12);
            }
        } else {
            if (![NSString kqc_isBlank:self.rightButton.titleLabel.text]) {
                self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
            } else {
                self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, -12);
            }
        }
    } else {
        if (self.customButton && !self.customButton.hidden) {
            [self.customButton removeFromSuperview];
            self.customButton.frame = rightView.bounds;
            self.customButton.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, -12);
            [rightView addSubview:self.customButton];
        }
    }
    
    UIBarButtonItem* tempButton = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.rightBarButton = tempButton;
    UINavigationItem *navigationItem = [self currentNavigationItem];
    navigationItem.rightBarButtonItem = tempButton;
}

- (void)closeButtonClick:(UIButton *)button{
    // 当点击返回按钮    取消掉可以返回的网络请求
    [KQHttpService cancelRequsetWithMode:KQHttpServiceCancelRequsetMode];
    [self cancelSwipeCardNetwork];
    
    [KQC_Engine_UI popViewController];
}

- (void)leftButtonClick:(id)sender {
    // 当点击返回按钮    取消掉可以返回的网络请求
    [KQHttpService cancelRequsetWithMode:KQHttpServiceCancelRequsetMode];
    [self cancelSwipeCardNetwork];
    
    self.leftBarButton.enabled = NO;
    [_activeField resignFirstResponder];
    _activeField = nil;
    [KQC_Engine_UI popViewController];
}

#pragma mark - 取消刷卡相关网络请求
- (void)cancelSwipeCardNetwork {
    [KQSwipeCardHttpService cancelRequsetWithMode:KQHttpServiceCancelRequsetMode];
}

-(void)setNavigationItems:(NSString *)title leftItemImageName:(NSString*)leftImageName leftText:(NSString*)leftText leftAction:(SEL)leftAction rightItemImageName:(NSString*)rightImageName rightText:(NSString*) rightText rightAction:(SEL)rightAction {
    [self setNavigationTitle:title];
    [self addLeftButton:leftText imageName:leftImageName Action:leftAction];
    [self addRightButton:rightText imageName:rightImageName action:rightAction];
}

- (void)hideLeftBtn{
    [self addLeftButton:@"" imageName:@"" Action:nil];
}

- (void)setRightButtonHidden:(BOOL)hidden{
    self.rightButton.hidden = hidden;
    [self resetNavigationRightView];
}

#pragma mark - 导航栏右按钮
- (IBAction)rightButtonClick:(id)sender {
    [_activeField resignFirstResponder];
    _activeField = nil;
}

////////////////* add by lbn 05-29 */////////////////////
- (void)setTextFieldParentViewFrame:(CGRect)frame
{
    textFieldParentViewframe = frame;
}

#pragma  mark - 键盘事件
- (void)keyboardDidShow:(NSNotification *)notif
{
    CGSize keyboardSize = [(NSValue *)[[notif userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size;
    CGRect viewFrame = _contentView.frame;
    viewFrame.size.height = KQC_SCREEN_HEIGHT - _contentView.frame.origin.y - keyboardSize.height;
    _contentView.frame = viewFrame;
    
    CGRect textFieldRect = CGRectMake(_activeField.frame.origin.x+textFieldParentViewframe.origin.x, _activeField.frame.origin.y+textFieldParentViewframe.origin.y, _activeField.frame.size.width,_activeField.frame.size.height);
    textFieldRect.origin.y += 20;
    
    [_contentView scrollRectToVisible:textFieldRect animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notif{
    _contentView.height = [self calcContentViewHeight:NULL];
}

- (void)keyboardDidHide:(NSNotification *)notif
{
    _contentView.height = [self calcContentViewHeight:NULL];
}

#pragma  mark - textField委托
- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    _activeField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_activeField resignFirstResponder];
    _activeField = nil;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(textFieldChanged:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:textField];
}
- (void)textFieldChanged:(NSNotification *)note
{
    //    DLog(@"text changed");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UITextFieldTextDidChangeNotification
                                                 object:textField];
}


#pragma mark applicationDidEnterBackground
-(void)applicationEnterBackground:(NSNotification *)notif {
    [_activeField resignFirstResponder];
    _activeField = nil;
}

@end

