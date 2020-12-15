//
//  KQPanGestureNavigationController.m
//  kuaiQianbao
//
//  Created by hao on 16/4/9.
//
//

#import "KQCPanGestureNavigationController.h"
#import "KQCAppBaseViewController.h"

#define AnimationTime     0.3f      //动画时间
#define OffsetScreenView  0.6f     //屏幕截图初始位置比例
#define OffetCritical     50.f      //是否pop滑动距离临界值

@interface KQCPanGestureNavigationController(){
    UIImageView *   _currentScreenView;
    UIView *        _bgScreenView;
    CGPoint         _startPoint;
    CGPoint         _touchPoint;
    BOOL            _isGestureBack;
    BOOL            _isMoving;
}
@end

@implementation KQCPanGestureNavigationController

- (id)init {
    self = [super init];
    if (self) {
        _isGestureBack = NO;
        self.screenViewArray = [NSMutableArray array];
        self.classNameArray = [NSMutableArray array];
        [self setDelegate:self];
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return self;
}

- (void)viewDidLoad{
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowRadius = 5.0;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

#pragma mark -UINavigationController delagate
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIViewController *currentVC = [super topViewController];
    BOOL isCanSave = YES;
    if ([currentVC isKindOfClass:[KQCAppBaseViewController class]] // 当前界面不需要保存
        && ![(KQCAppBaseViewController *)currentVC isCanSave]) {
        isCanSave = NO;
    }
//    KQBBaseViewController *currentVC = (KQBBaseViewController *)[KQC_Engine_UI topViewController];
    if (isCanSave) {
        [self.screenViewArray addObject:[self captureScreenView]];
        [self.classNameArray addObject:KQC_NON_NIL(NSStringFromClass([currentVC class]))];
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self.screenViewArray removeLastObject];
    [self.classNameArray removeLastObject];
    if (_isGestureBack) {
        return [super popViewControllerAnimated:NO];
    }else{
        return [super popViewControllerAnimated:animated];
    }
}

-(NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSString *strClassName = NSStringFromClass(viewController.class);
    for (int i = 0; i < self.classNameArray.count; i++) {
        NSString *str = self.classNameArray[i];
        if ([str isEqualToString:strClassName]) {
            [self.classNameArray removeObjectsInRange:NSMakeRange(i, self.classNameArray.count - i)];
            [self.screenViewArray removeObjectsInRange:NSMakeRange(i, self.screenViewArray.count - i)];
            break;
        }
    }
    if (_isGestureBack) {
        return [super popToViewController:viewController animated:NO];
    }else{
        return [super popToViewController:viewController animated:animated];
    }
}

#pragma mark -右滑Events
- (void)panGestureEvents:(UIPanGestureRecognizer *)recoginzer{
    CGPoint point = [recoginzer locationInView:[UIApplication sharedApplication].keyWindow];
    static CGFloat speedTmp = 0;
    CGFloat speed = speedTmp;
    if(recoginzer.state == UIGestureRecognizerStateChanged){
        speedTmp = point.x - _touchPoint.x;
    }
    _touchPoint = point;
    CGFloat offsetX = _touchPoint.x - _startPoint.x;
    if(recoginzer.state == UIGestureRecognizerStateBegan){
        [self showCurrentScreenView];
        self.navigationBar.userInteractionEnabled = NO;
        _isMoving = YES;
        _startPoint = _touchPoint;
        offsetX = 0;
    }
    if(recoginzer.state == UIGestureRecognizerStateEnded){
        if (speed > 15) {
            [self backAnimation:offsetX];
        }else if (speed < -5){
            [self notBackAnimation:offsetX];
        }else if (offsetX > OffetCritical){
            [self backAnimation:offsetX];
        }else{
            [self notBackAnimation:offsetX];
        }
        _isMoving = NO;
    }
    if (_isMoving && offsetX > 0) {
        [self moveScreenView:offsetX];
    }
}

#pragma mark -返回动画
- (void)backAnimation:(CGFloat)offsetX{
    CGFloat screenWidth = KQC_SCREEN_WIDTH;
    CGFloat time = ((screenWidth - offsetX)*AnimationTime)/screenWidth;
    [UIView animateWithDuration:time animations:^{
        [self moveScreenView:screenWidth];
    } completion:^(BOOL finished) {
        [self animationFinished];
        self.navigationBar.userInteractionEnabled = YES;
    }];
}

#pragma mark -不返回动画
- (void)notBackAnimation:(CGFloat)offsetX{
    CGFloat time = (offsetX*AnimationTime)/KQC_SCREEN_WIDTH;
    [UIView animateWithDuration:time animations:^{
        [self moveScreenView:0];
    } completion:^(BOOL finished) {
        _bgScreenView.hidden = YES;
        self.navigationBar.userInteractionEnabled = YES;
    }];
}

#pragma mark -获取ScreenView
- (UIImage *)captureScreenView {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -添加当前ScreenView
-(void)showCurrentScreenView{
    CGFloat screenWidth = KQC_SCREEN_WIDTH;
    if (!_bgScreenView) {
        _bgScreenView = [[UIView alloc]initWithFrame:self.view.bounds];
        _bgScreenView.backgroundColor = [UIColor clearColor];
        [self.view.superview insertSubview:_bgScreenView belowSubview:self.view];
    }
    if (!_currentScreenView) {
        _currentScreenView = [[UIImageView alloc] initWithFrame:CGRectMake(-OffsetScreenView*screenWidth, 0, screenWidth, KQC_SCREEN_HEIGHT)];
        [_bgScreenView addSubview:_currentScreenView];
    }
    _bgScreenView.hidden = NO;
    _currentScreenView.image = [self.screenViewArray lastObject];
    
}

#pragma mark -移动ScreenView
-(void)moveScreenView:(CGFloat)offsetX{
    CGFloat screenWidth = KQC_SCREEN_WIDTH;
    offsetX = offsetX>screenWidth?:offsetX;
    offsetX = offsetX<0?0:offsetX;
    CGRect frame = self.view.frame;
    frame.origin.x = offsetX;
    self.view.frame = frame;
    _currentScreenView.frame = (CGRect){OffsetScreenView*(offsetX - screenWidth), 0, screenWidth, KQC_SCREEN_HEIGHT};
}

#pragma mark -动画结束
-(void)animationFinished{
    _isGestureBack = YES;
    [self popViewControllerAnimated:YES];
//    [(KQBBaseViewController *)[KQC_Engine_UI topViewController] leftButtonClick:nil];
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    self.view.frame = frame;
    _bgScreenView.hidden = YES;
    _isGestureBack = NO;
}

@end
