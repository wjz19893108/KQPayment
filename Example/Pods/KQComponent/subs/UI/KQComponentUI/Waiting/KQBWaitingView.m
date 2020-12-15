//
//  KQBWaitingView.m
//  KQBusiness
//
//  Created by xy on 2016/10/24.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBWaitingView.h"
#import "KQBTopView.h"

@implementation KQBWaitingView

//static UIView *WaitingBgView = nil;
//static UIImageView *CircleImageView = nil;
static NSInteger WaitingViewTag = 1209;
static CGFloat WidthRatio = 0.f;

// 全屏loading计数器
static NSInteger FullScreenWaitingCount = 0;
// 可返回loading计数器
static NSInteger TopScreenWaitingCount = 0;

static KQBTopView *indicatorView;

+ (void)initialize{
    WidthRatio = KQC_WIDTH_RATIO;
//    CGFloat ratio = KQC_WIDTH_RATIO;
//    
//    WaitingBgView = [[UIView alloc] init];
//    WaitingBgView.backgroundColor = [UIColor clearColor];
//    
//    UIView *indicatorBgView = [[UIView alloc] init];
//    CGFloat loadingViewWidth = 85.5f * ratio;
//    [indicatorBgView setFrame:CGRectMake((KQC_SCREEN_WIDTH - loadingViewWidth) / 2, 150.0f + (KQC_SCREEN_HEIGHT - 480.f) / 2, loadingViewWidth, loadingViewWidth)];
//    indicatorBgView.backgroundColor = UIColorFromRGB(0x2b, 0x2b, 0x2b);
//    [WaitingBgView addSubview:indicatorBgView];
//    
//    [indicatorBgView.layer setBorderWidth:2.0];//画线的宽度
//    [indicatorBgView.layer setBorderColor:[UIColor clearColor].CGColor];//颜色
//    [indicatorBgView.layer setCornerRadius:10.0];//圆角
//    [indicatorBgView.layer setMasksToBounds:YES];
//    
//    
//    CircleImageView = [[UIImageView alloc] init];
//    CGFloat circleWidth = 17 * ratio;
//    CircleImageView.frame = CGRectMake(indicatorBgView.x + circleWidth, indicatorBgView.y + circleWidth, loadingViewWidth - circleWidth * 2, loadingViewWidth - circleWidth * 2);
//    CircleImageView.image = [UIImage kqb_imageNamed:@"kq_loading_ring"];
//    [WaitingBgView addSubview:CircleImageView];
//    
////    [circleImageView.layer removeAnimationForKey:@"RotationAnimation"];
//    
//    
//    CGFloat logoWidth = 31 * ratio;
//    UIImageView *logoImageView = [[UIImageView alloc] init];
//    logoImageView.frame = CGRectMake(indicatorBgView.x + logoWidth, indicatorBgView.y + logoWidth, loadingViewWidth - logoWidth*2, loadingViewWidth - logoWidth*2);
//    logoImageView.image = [UIImage kqb_imageNamed:@"kq_loading_box"];
//    [WaitingBgView addSubview:logoImageView];
}

+ (void)show{
    FullScreenWaitingCount++;
    [KQBWaitingView showWithFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQC_SCREEN_HEIGHT)];
}

+ (void)showShort{
    FullScreenWaitingCount++;
    [KQBWaitingView showWithFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQC_SCREEN_HEIGHT - [KQC_Engine_UI tabBarHegiht])];
}

+ (void)showShortWithOutTop{
    TopScreenWaitingCount++;
    // 当全屏计数器不为零  不改变
    if (FullScreenWaitingCount != 0) {
        
        return;
    }
    [KQBWaitingView showWithFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQC_SCREEN_HEIGHT) isTop:YES];
}

// 全屏loading和短loading左上角区域都不可以返回
+ (void)showWithFrame:(CGRect)frame{
    [self showWithFrame:frame isTop:NO];
}

+ (void)showWithFrame:(CGRect)frame isTop:(BOOL)isTop{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *window = [KQCApplication progressViewParentWindow];
        [KQBWaitingView showWithFrame:frame parentView:window isTop:isTop];
        if ([NSStringFromClass([KQC_TOP_WINDOW class]) isEqualToString:@"UIRemoteKeyboardWindow"]) {
            [KQBWaitingView showWithFrame:frame parentView:KQC_TOP_WINDOW isTop:isTop];
        }
    });
}

+ (void)showWithFrame:(CGRect)frame parentView:(UIView *)parentView isTop:(BOOL)isTop{
    if (indicatorView) {
        // 因为有可能短loading和全屏loading一起
        indicatorView.frame = frame;
        indicatorView.canLeftClick = isTop;
    } else {
        indicatorView = [[KQBTopView alloc] initWithFrame:frame];
        // 是否可以返回
        indicatorView.canLeftClick = isTop;
        [indicatorView setTag:WaitingViewTag];
        
        UIImageView* indicatorBgView = [[UIImageView alloc] init];
        CGFloat loadingViewWidth = 85.5f * WidthRatio;
        indicatorBgView.frame = CGRectMake((KQC_SCREEN_WIDTH - loadingViewWidth) / 2, 150.0f + (KQC_SCREEN_HEIGHT - 480.f) / 2, loadingViewWidth, loadingViewWidth);
        indicatorBgView.backgroundColor = UIColorFromRGB(0x2b, 0x2b, 0x2b);
        [indicatorView addSubview:indicatorBgView];
        [[indicatorBgView layer] setBorderWidth:2.0];//画线的宽度
        [[indicatorBgView layer] setBorderColor:[UIColor clearColor].CGColor];//颜色
        [[indicatorBgView layer] setCornerRadius:10.0];//圆角
        [indicatorBgView.layer setMasksToBounds:YES];
        [parentView addSubview: indicatorView];
        
        UIImageView *circleImageView = [[UIImageView alloc] init];
        CGFloat circleWidth = 17 * WidthRatio;
        circleImageView.frame = CGRectMake(indicatorBgView.x + circleWidth, indicatorBgView.y + circleWidth, loadingViewWidth - circleWidth * 2, loadingViewWidth - circleWidth * 2);
        circleImageView.image = [UIImage kqb_imageNamed:@"kq_loading_ring"];
        [indicatorView addSubview:circleImageView];
        
        [circleImageView.layer removeAnimationForKey:@"RotationAnimation"];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = @(0);
        animation.toValue = @(M_PI * 2);
        animation.repeatCount = MAXFLOAT;
        animation.duration = 1.1f;
        animation.fillMode = kCAFillModeForwards;
        [circleImageView.layer addAnimation:animation forKey:@"RotationAnimation"];
        
        CGFloat logoWidth = 31 * WidthRatio;
        UIImageView *logoImageView = [[UIImageView alloc] init];
        logoImageView.frame = CGRectMake(indicatorBgView.x + logoWidth, indicatorBgView.y + logoWidth, loadingViewWidth - logoWidth * 2, loadingViewWidth - logoWidth * 2);
        logoImageView.image = [UIImage kqb_imageNamed:@"kq_loading_box"];
        [indicatorView addSubview:logoImageView];
    }
}

+ (void)hideTopView{
    TopScreenWaitingCount--;
    [self hideLoadingView];
}

+ (void)hideShortView{
    FullScreenWaitingCount--;
    [self hideLoadingView];
}

+ (void)hideFullView{
    FullScreenWaitingCount--;
    [self hideLoadingView];
}

+ (void)hide{
    FullScreenWaitingCount = 0;
    TopScreenWaitingCount = 0;
    [self hideLoadingView];
}

+ (void)hideLoadingView{
    if ((FullScreenWaitingCount + TopScreenWaitingCount) == 0) {
        [indicatorView removeFromSuperview];
        indicatorView = nil;
    }
}

@end
