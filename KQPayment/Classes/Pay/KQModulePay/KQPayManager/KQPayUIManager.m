//
//  KQPayUIManager.m
//  kuaiQianbao
//
//  Created by zouf on 16/1/15.
//
//

#import "KQPayUIManager.h"
#import "KQBasePayView.h"
#import "KQBasePayHalfView.h"


#define KQPAYMENT_VIEW_BOTTOM_POSITION      CGRectMake(0, KQC_SCREEN_HEIGHT, KQC_SCREEN_WIDTH, KQC_SCREEN_HEIGHT)
#define KQPAYMENT_VIEW_POSITION             CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQC_SCREEN_HEIGHT)
#define KQPAYMENT_SCROLL_BACK               CGPointMake(-KQC_SCREEN_WIDTH, 0)
#define KQPAYMENT_SCROLL_FORWARD            CGPointMake(KQC_SCREEN_WIDTH, 0)
#define KQPAYMENT_VIEW_Animation_TIME      0.3f


@interface KQPayUIManager ()

//第一页，只有可能会是KQPayDetailNavigateView
//第二页，可能是KQPayModeNavigateView或KQPayPasswordNavigateView或KQPayInstallmentNavigateView
//第三页，只可能会是KQPayResultView
//保存第几页对应的底部view，key从0开始
@property (nonatomic, strong) NSMutableDictionary *pageViewsDic;
@property (nonatomic, strong) NSMutableArray *payViewArray;     //模拟view堆栈
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) UIView *backGroundView;           //蒙版
@property (nonatomic, strong) UIScrollView *payScrollView;      //创建两个KQBasePayHalfView的宽度
@property (nonatomic, strong) NSDictionary * payViewClassDic;

@end

@implementation KQPayUIManager

- (instancetype __nullable)initAllView:(UIView* __nonnull)parentView {
    self = [super init];
    if (self) {
        if (!parentView) {
            return nil;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        self.parentView = parentView;
        //再初始化界面相关
        self.pageViewsDic = [NSMutableDictionary dictionary];
        
        self.payViewArray = [NSMutableArray array];
        
        self.backGroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.backGroundView.backgroundColor = [UIColor blackColor];
        self.backGroundView.alpha = 0.6f;
        
        self.payScrollView = [[UIScrollView alloc] initWithFrame:KQPAYMENT_VIEW_BOTTOM_POSITION];
        self.payScrollView.backgroundColor = [UIColor clearColor];
        
        self.payScrollView.bounces = NO;
        self.payScrollView.showsHorizontalScrollIndicator = NO;
        self.payScrollView.showsVerticalScrollIndicator = NO;
        self.payScrollView.pagingEnabled = YES;
        self.payScrollView.scrollEnabled = NO;
        
        self.payViewClassDic = @{@(KQPayViewStepDetail):@"KQPayDetailNavigateView",
                                 @(KQPayViewStepMode):@"KQPayModeNavigateView",
                                 @(KQPayViewStepInstallment):@"KQPayInstallmentNavigateView",
                                 @(KQPayViewStepNoneVoucher):@"KQPayNoneVoucherNavigateView",
                                 @(KQPayViewStepVoucher):@"KQPayVoucherNavigateView",
                                 @(KQPayViewStepAllVoucher):@"KQPayVoucherNavigateView",
                                 @(KQPayViewStepPassword):@"KQPayPasswordNavigateView",
                                 @(KQPayViewStepSms):@"KQPaySmsNavigateView",
                                 @(KQPayViewStepCvv2):@"KQPayCVV2NavigateView",
                                 @(KQPayViewStepResult):@"KQPayResultView"};
    }
    return self;
}

- (void)keyboardDidShow:(NSNotification *)notif {
    CGSize keyboardSize = [(NSValue *)[[notif userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size;
    UIView *payView = [self.payViewArray lastObject];
    CGSize moveSize = CGSizeZero;
    if (payView && [payView isKindOfClass:[KQBasePayView class]]) {
        moveSize = [(KQBasePayView *)payView getMoveSizeWhenKeyboardShow:keyboardSize];
    }
    [self moveUpScrollView:moveSize];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self moveDownScrollView];
}

- (void)pushPayViewWithStep:(KQPayViewStep)payViewStep delegate:(id __nonnull)delegate withParam:(NSDictionary* __nullable)paramDic completion:(void (^ __nullable)(BOOL finished))completion {
    NSMutableDictionary * paramMutDic = [@{@"delegate":delegate,
                                           @"payViewStep":@(payViewStep)} mutableCopy];
    [paramMutDic addEntriesFromDictionary:paramDic];
    
    UIView * payView = [self createPayView:[self.payViewClassDic objectForKey:@(payViewStep)]];
    if (!payView) {
        return;
    }
    [self parseParam:payView withParam:paramMutDic];
    [self pushPayView:payView completion:completion];
}

- (void)pushPayViewWithView:(UIView * __nonnull)payView withParam:(NSDictionary* __nullable)paramDic completion:(void (^ __nullable)(BOOL finished))completion {
    if (!payView) {
        return;
    }
    [self parseParam:payView withParam:paramDic];
    [self pushPayView:payView completion:completion];
}

- (void)pushPayViewWithClassName:(NSString * __nonnull)payViewClassName withParam:(NSDictionary* __nullable)paramDic completion:(void (^ __nullable)(BOOL finished))completion {
    UIView * payView = [self createPayView:payViewClassName];
    if (!payView) {
        return;
    }
    [self parseParam:payView withParam:paramDic];
    [self pushPayView:payView completion:completion];
}

- (void)pushPayView:(UIView * __nonnull)payView completion:(void (^ __nullable)(BOOL finished))completion {
    if ([self.payViewArray count] == 0) {
        [self.parentView addSubview:self.backGroundView];
        [self.parentView addSubview:self.payScrollView];
        self.payScrollView.frame = KQPAYMENT_VIEW_BOTTOM_POSITION;
        [self attachView:payView];
        if ([payView isKindOfClass:[KQBasePayHalfView class]]) {
            [(KQBasePayHalfView*)payView closeBtnImage:KQBaseCloseImageClose];
        }
        [self showScrollView:^(BOOL finished) {
            if ([payView isKindOfClass:[KQBasePayView class]]) {
                [(KQBasePayView*)payView viewDidShow];
            }
            if (completion) {
                completion(finished);
            }
        }];
    }
    else {
        [self attachView:payView];
        [self pushScrollView:^(BOOL finished) {
            if ([payView isKindOfClass:[KQBasePayView class]]) {
                [(KQBasePayView*)payView viewDidShow];
            }
            if (completion) {
                completion(finished);
            }
        }];
    }
}

- (void)popPayView:(void (^ __nullable)(void))completion {
    [self internalPopPayView:completion duration:KQPAYMENT_VIEW_Animation_TIME];
}

- (void)quickPopPayView:(void (^ __nullable)(void))completion {
    [self internalPopPayView:completion duration:0];
}

- (void)internalPopPayView:(void (^ __nullable)(void))completion duration:(CGFloat)time {
    if (self.payViewArray.count >= 2) {
        __block UIView *lastView = [self.payViewArray lastObject];
        [self.payViewArray removeLastObject];
        [self popScrollView:^(BOOL finished) {
            [lastView removeFromSuperview];
            if (completion) {
                completion();
            }
        } duration:time];
        UIView *payView = [self.payViewArray lastObject];
        if ([payView isKindOfClass:[KQBasePayView class]]) {
            [(KQBasePayView*)payView viewDidShow];
        }
    }
    else {
        [self popAllPayView:completion];
    }
}

- (void)popToFirstPayView:(void (^ __nullable)(void))completion {
    if (self.payViewArray.count >= 2) {
        [self recursivePop:completion];
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)recursivePop:(void (^ __nullable)(void))completion {
    if (self.payViewArray.count == 2) {
        [self quickPopPayView:completion];
    } else {
        [self quickPopPayView:^{
            [self recursivePop:completion];
        }];
    }
}

- (void)popAllPayView:(void (^ __nullable)(void))completion
{
    __weak typeof(self) weakSelf = self;
    [self hideScrollView:^(BOOL finished) {
        [weakSelf resetAllView];
        if (completion) {
            completion();
        }
    }];
}

- (UIView* __nullable)topPayView {
    UIView *payView = [self.payViewArray lastObject];
    if (!payView) {
        return nil;
    }
    return payView;
}

- (BOOL)stayHere {
    if (!self.parentView) {
        return NO;
    }
    UIView *payView = [self.payViewArray lastObject];
    if ([payView isKindOfClass:[KQBasePayView class]]) {
        [(KQBasePayView*)payView viewDidShow];
    }
    return YES;
}

- (KQBasePayView*)createPayView:(NSString* __nonnull)payViewClass
{
    if ([NSString kqc_isBlank:payViewClass]) {
        return nil;
    }
    
    Class targetClass = NSClassFromString(payViewClass);
    if (!targetClass) {
        return nil;
    }
    
    KQBasePayView *payView = [[targetClass alloc] init];
    if (!payView || ![payView isKindOfClass:[KQBasePayView class]]) {
        return nil;
    }

    return payView;
}

- (void)parseParam:(UIView * __nullable)payView withParam:(NSDictionary* __nullable)paramDic {
    [paramDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]]) {
            return;
        }
        
        NSString *upperKey = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]];
        
        SEL setMethod = NSSelectorFromString([NSString stringWithFormat:@"set%@:", upperKey]);
        if (![payView respondsToSelector:setMethod]) {
            return;
        }
        
        [payView setValue:obj forKeyPath:key];
    }];
}

- (void)resetAllView
{
    for (UIView *payView in self.payViewArray) {
        [payView removeFromSuperview];
    }
    [self.payViewArray removeAllObjects];
    
    for (NSNumber *num in self.pageViewsDic) {
        UIView *view = self.pageViewsDic[num];
        [view removeFromSuperview];
    }
    [self.pageViewsDic removeAllObjects];
    
    self.payScrollView.contentOffset = CGPointMake(0, 0);
    
    [self.payScrollView removeFromSuperview];
    [self.backGroundView removeFromSuperview];
    
    self.parentView = nil;
}

- (void)attachView:(UIView*)payView
{
    //先调整scrollview的contentSize，为self.payViewArray+1的数量
    self.payScrollView.contentSize = CGSizeMake(KQC_SCREEN_WIDTH * (self.payViewArray.count + 1), KQC_SCREEN_HEIGHT);
    //找到对应的page是否有view
    NSNumber *num = [NSNumber numberWithUnsignedInteger:self.payViewArray.count];
    UIView *pageView = [self.pageViewsDic objectForKey:num];
    if (!pageView) {
        pageView = [[UIView alloc] initWithFrame:CGRectMake(KQC_SCREEN_WIDTH * self.payViewArray.count, 0, KQC_SCREEN_WIDTH, KQC_SCREEN_HEIGHT)];
        pageView.backgroundColor = [UIColor clearColor];
        [self.pageViewsDic setObject:pageView forKey:num];
    }
    [self.payScrollView addSubview:pageView];
    [pageView addSubview:payView];
    //加完了添加到模拟堆栈
    [self.payViewArray addObject:payView];
}

/*
 scrollview刚开始显示时，从屏幕底部出来
 */
- (void)showScrollView:(void (^ __nullable)(BOOL finished))completion
{
    //首次显示支付页面时，从底部弹出
    KQBaseViewAnimation *viewAnimation = [[KQBaseViewAnimation alloc] initWithView:self.payScrollView duration:KQPAYMENT_VIEW_Animation_TIME];
    [viewAnimation addAnimation:[[KQViewActionMove alloc] initWithRect:KQPAYMENT_VIEW_BOTTOM_POSITION endRect:KQPAYMENT_VIEW_POSITION]];
    [viewAnimation startAnimation:completion];
}

/*
 scrollview刚结束时，回到屏幕底部
 */
- (void)hideScrollView:(void (^ __nullable)(BOOL finished))completion
{
    //关闭时，回到底部
    KQBaseViewAnimation *viewAnimation = [[KQBaseViewAnimation alloc] initWithView:self.payScrollView duration:KQPAYMENT_VIEW_Animation_TIME];
    [viewAnimation addAnimation:[[KQViewActionMove alloc] initWithRect:KQPAYMENT_VIEW_POSITION endRect:KQPAYMENT_VIEW_BOTTOM_POSITION]];
    [viewAnimation startAnimation:completion];
}

/*
 scrollview向左滚动，即前进
 */
- (void)pushScrollView:(void (^ __nullable)(BOOL finished))completion
{
    KQBaseViewAnimation *viewAnimation = [[KQBaseViewAnimation alloc] initWithView:self.payScrollView duration:KQPAYMENT_VIEW_Animation_TIME];
    [viewAnimation addAnimation:[[KQScrollViewContentOffset alloc] initWithOffset:KQPAYMENT_SCROLL_FORWARD]];
    [viewAnimation startAnimation:completion];
}

/*
 scrollview向右滚动，即后退
 */
- (void)popScrollView:(void (^ __nullable)(BOOL finished))completion duration:(CGFloat)time
{
    KQBaseViewAnimation *viewAnimation = [[KQBaseViewAnimation alloc] initWithView:self.payScrollView duration:time];
    [viewAnimation addAnimation:[[KQScrollViewContentOffset alloc] initWithOffset:KQPAYMENT_SCROLL_BACK]];
    [viewAnimation startAnimation:completion];
}

/*
 scrollview要显示键盘，向上移动一点
 */
- (void)moveUpScrollView:(CGSize)moveSize {
    KQBaseViewAnimation *viewAnimation = [[KQBaseViewAnimation alloc] initWithView:self.payScrollView duration:KQPAYMENT_VIEW_Animation_TIME];
    CGRect endRect = self.payScrollView.frame;
    endRect.origin.y = -moveSize.height;
    [viewAnimation addAnimation:[[KQViewActionMove alloc] initWithRect:self.payScrollView.frame endRect:endRect]];
    [viewAnimation startAnimation:nil];
}

/*
 scrollview要隐藏键盘，回到原位
 */
- (void)moveDownScrollView {
    KQBaseViewAnimation *viewAnimation = [[KQBaseViewAnimation alloc] initWithView:self.payScrollView duration:KQPAYMENT_VIEW_Animation_TIME];
    [viewAnimation addAnimation:[[KQViewActionMove alloc] initWithRect:self.payScrollView.frame endRect:KQPAYMENT_VIEW_POSITION]];
    [viewAnimation startAnimation:nil];
}

- (void)dealloc
{
    [self resetAllView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
