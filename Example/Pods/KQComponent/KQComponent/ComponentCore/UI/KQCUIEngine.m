//
//  KQCUIManager.m
//  KQCore
//
//  Created by xy on 2016/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCUIEngine.h"
#import "KQCBufferedNavigationController.h"
#import "KQCAppBaseViewController.h"
#import "UIView+LayoutMethods.h"
#import "KQCTabBarDataModel.h"

@interface KQCUIEngine() <UITabBarControllerDelegate>

@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation KQCUIEngine

NSNotificationName const KQCTabBarSelectedIndexChangedNotification = @"TabBarSelectedIndexChangedNotification";

SYNTHESIZE_SINGLETON_FOR_CLASS(KQCUIEngine);

- (instancetype)init{
    self = [super init];
    if (self) {
        self.appNavController = [[KQCBufferedNavigationController alloc] init];
        self.appNavController.navigationBar.translucent = NO;
        [UIApplication sharedApplication].keyWindow.rootViewController = self.appNavController;
        
        self.tabBarController = [[UITabBarController alloc] init];
        self.tabBarController.delegate = self;
        self.tabBarController.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)showRootViewController{
    if (![self.appNavController.viewControllers containsObject:self.tabBarController]) {
        [self.appNavController setViewControllers:@[self.tabBarController] animated:YES];
    } else {
        if (![[self.appNavController topViewController] isEqual:self.tabBarController]) {
            [self.appNavController popToViewController:self.tabBarController animated:YES];
        }
    }
}

- (void)setNavigationBarTintColor:(UIColor *)navigationBarTintColor{
    _navigationBarTintColor = navigationBarTintColor;
    [[UINavigationBar appearance] setBarTintColor:_navigationBarTintColor];
}

- (void)setTabBarData:(KQCTabBarDataModel *)tabBarData{
    [[UITabBar appearance] setBackgroundColor:tabBarData.backgroundColor];
    [[UITabBar appearance] setBackgroundImage:tabBarData.backgroundImage];
    [[UITabBar appearance] setTintColor:tabBarData.tintColor];
    [[UITabBar appearance] setSelectionIndicatorImage:tabBarData.selectionIndicatorImage];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:tabBarData.normalTitleColor} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:tabBarData.selectedTitleColor} forState:UIControlStateSelected];
    
    NSMutableArray *screenArray = [NSMutableArray array];
    [tabBarData.itemArray enumerateObjectsUsingBlock:^(KQCTabBarItemDataModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:obj.title image:nil tag:0];
        tabBarItem.image = [obj.imageUnselected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem.selectedImage = [obj.imageSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [tabBarItem setTitlePositionAdjustment:UIOffsetMake(0.f, -3.f)];
        
        UIViewController *targetViewController = [KQC_Engine_UI createAppBaseViewController:obj.screenName param:nil];
        targetViewController.tabBarItem = tabBarItem;
        [screenArray addObject:targetViewController];
    }];
    
    self.tabBarController.viewControllers = screenArray;
    [self.tabBarController setSelectedIndex:tabBarData.selectedIndex];
}

- (KQCAppBaseViewController *)popViewController{
    return [self popViewControllerWithAnimated:YES];
}

- (KQCAppBaseViewController *)popViewControllerWithAnimated:(BOOL)animated{
    if (self.appNavController.viewControllers.count == 0) {
        return nil;
    }
    
    UIViewController *viewController = [self.appNavController popViewControllerAnimated:animated];
    if (![viewController isKindOfClass:[KQCAppBaseViewController class]]) {
        return nil;
    }
    
    return (KQCAppBaseViewController *)viewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController {
    return [self popToViewController:viewController notFoundBlock:NULL];
}

- (NSArray *)popToViewController:(UIViewController *)viewController notFoundBlock:(void(^)(void))notFoundBlock {
    if ((!viewController)||(![viewController isKindOfClass:UIViewController.self])) {
        return nil;
    }
    
    NSArray *viewControllers = self.appNavController.viewControllers;
    for (UIViewController *vc in [viewControllers reverseObjectEnumerator]) {
        if (vc == viewController) {
            return [self.appNavController popToViewController:viewController animated:YES];
        } else if ([vc isEqual:self.tabBarController]) {
            NSArray *views = self.tabBarController.viewControllers;
            for (UIViewController* tabVC in views) {
                if (tabVC == viewController) {
                    return [self.appNavController popToViewController:self.tabBarController animated:YES];
                }
            }
        }
    }
    
    if (notFoundBlock) {
        notFoundBlock();
    }
    
    return nil;
}

- (NSArray *)popToViewControllerWithName:(NSString *)viewControllerName{
    return [self popToViewControllerWithName:viewControllerName notFoundBlock:NULL];
}

- (NSArray *)popToViewControllerWithName:(NSString *)viewControllerName notFoundBlock:(void(^)(void))notFoundBlock{
    if ([NSString kqc_isBlank:viewControllerName]) {
        return nil;
    }
    
    NSArray *viewControllers = self.appNavController.viewControllers;
    for (UIViewController *viewController in [viewControllers reverseObjectEnumerator]) {
        NSString *tempName = NSStringFromClass([viewController class]);
        if ([tempName isEqualToString:viewControllerName]) {
            return [self.appNavController popToViewController:viewController animated:YES];
        } else if ([viewController isEqual:self.tabBarController]) {
            NSArray *views = self.tabBarController.viewControllers;
            for (UIViewController* tabView in views) {
                if ([viewControllerName isEqualToString:NSStringFromClass([tabView class])]) {
                    return [self.appNavController popToViewController:self.tabBarController animated:YES];
                }
            }
        }
    }
    
    if (notFoundBlock) {
        notFoundBlock();
    }
    
    return nil;
}

- (KQCAppBaseViewController *)topViewController{
    UIViewController *topViewController = self.appNavController.topViewController;
    if ([topViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tempTabBarController = (UITabBarController *)topViewController;
        UIViewController *viewController = tempTabBarController.selectedViewController;
        if (![viewController isKindOfClass:[KQCAppBaseViewController class]]) {
            return nil;
        }
        return (KQCAppBaseViewController *)viewController;
    }
    
    if (![topViewController isKindOfClass:[KQCAppBaseViewController class]]) {
        return nil;
    }
    
    return (KQCAppBaseViewController *)topViewController;
}

- (KQCAppBaseViewController *)currentSelectedViewControllerInTab{
    if (!self.tabBarController) {
        return nil;
    }
    
    UIViewController *viewController = self.tabBarController.selectedViewController;
    if (![viewController isKindOfClass:[KQCAppBaseViewController class]]) {
        return nil;
    }
    return (KQCAppBaseViewController *)viewController;
}

- (NSString *)currentSelectedViewControllerClassInTab{
    KQCAppBaseViewController *viewController = [self currentSelectedViewControllerInTab];
    if (!viewController) {
        return nil;
    }
    
    return NSStringFromClass([viewController class]);
}

- (void)switchTabAtIndex:(NSUInteger)index{
    [self switchTabAtIndex:index param:nil];
}

- (void)switchTabAtIndex:(NSUInteger)index param:(NSDictionary *)paramDic{
    if (self.tabBarController) {
        [self.tabBarController setSelectedIndex:index];
    }
    
    if (paramDic) {
        KQCAppBaseViewController *viewController = self.tabBarController.viewControllers[index];
        viewController.paramDic = paramDic;
        [viewController parseViewControllerParamDic];
    }
}

- (void)switchTabAndPop2RootAtIndex:(NSUInteger)index param:(NSDictionary *)paramDic{
    [self switchTabAtIndex:index param:paramDic];
    if (self.tabBarController) {
        [self.appNavController popToViewController:self.tabBarController animated:YES];
    }
}

- (UIViewController *)showViewControllerWithName:(NSString *)viewControllerName{
    return [self showViewControllerWithName:viewControllerName animated:YES];
}

- (UIViewController *)showViewControllerWithName:(NSString *)viewControllerName param:(NSDictionary *)dic{
    return [self showViewControllerWithName:viewControllerName param:dic animated:YES];
}

- (UIViewController *)showViewControllerWithName:(NSString *)viewControllerName animated:(BOOL)animated{
    return [self showViewControllerWithName:viewControllerName param:nil animated:animated];
}

- (UIViewController *)showViewControllerWithName:(NSString *)viewControllerName param:(NSDictionary *)dic animated:(BOOL)animated{
    KQCAppBaseViewController *viewController = [self createAppBaseViewController:viewControllerName param:dic];
    if (!viewController) {
        return nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showViewController:viewController animated:animated];
    });
    
    return viewController;
}

- (void)showViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIViewController *topViewController = [self.appNavController topViewController];
    [self.appNavController pushViewController:viewController animated:animated];
    if ([viewController isKindOfClass:[KQCAppBaseViewController class]]
        && ((KQCAppBaseViewController *)viewController).isPushedByNotification) {
        return;
    }
    [self removeLastNotSaveViewController:topViewController];
}

- (void)removeLastNotSaveViewController:(UIViewController *)topViewController{
    if ([topViewController isKindOfClass:[KQCAppBaseViewController class]]) {
        KQCAppBaseViewController *tempViewController = (KQCAppBaseViewController *)topViewController;
        if (!tempViewController.isCanSave) { // 不保存，从当前栈里面移除出去
            [self removeViewController:tempViewController];
        }
    }
}

- (void)showViewControllerWithNameArray:(NSArray *)nameArray param:(NSArray *)paramArray{
    if (!nameArray || nameArray.count == 0) {
        return;
    }
    
    // 两个数组数量不相等
    if (paramArray && paramArray.count != nameArray.count) {
        return;
    }
    
    UIViewController *topViewController = [self.appNavController topViewController];
    NSMutableArray *viewControllerArray = [NSMutableArray array];
    [nameArray enumerateObjectsUsingBlock:^(NSString *viewControllerName, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = paramArray[idx];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            dic = nil;
        }
        KQCAppBaseViewController *viewController = [self createAppBaseViewController:viewControllerName param:dic];
        [viewControllerArray addObject:viewController];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.appNavController setViewControllers:viewControllerArray animated:YES];
        
        if ([viewControllerArray.lastObject isKindOfClass:[KQCAppBaseViewController class]]
            && ((KQCAppBaseViewController *)viewControllerArray.lastObject).isPushedByNotification) {
            return;
        }
        [self removeLastNotSaveViewController:topViewController];
    });
    
    //    [self removeLastNotSaveViewController:topViewController];
}

- (KQCAppBaseViewController *)createAppBaseViewController:(NSString *)viewControllerName param:(NSDictionary *)dic{
    if ([NSString kqc_isBlank:viewControllerName]) {
        return nil;
    }
    
    Class targetClass = NSClassFromString(viewControllerName);
    if (!targetClass) {
        return nil;
    }
    
    KQCAppBaseViewController *viewController = [[targetClass alloc] init];
    if (!viewController || ![viewController isKindOfClass:[KQCAppBaseViewController class]]) {
        return nil;
    }
    
    viewController.paramDic = dic;
    [self checkParseParam:viewController];
    return viewController;
}

- (void)checkParseParam:(KQCAppBaseViewController *)targetViewController{
    if (!targetViewController.paramDic) {
        return;
    }
    
    [targetViewController.paramDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]]) {
            return;
        }
        
        NSString *upperKey = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]];
        
        SEL setMethod = NSSelectorFromString([NSString stringWithFormat:@"set%@:", upperKey]);
        if (![targetViewController respondsToSelector:setMethod]) {
            return;
        }
        
        [targetViewController setValue:obj forKeyPath:key];
    }];
}

- (void)removeViewController:(UIViewController *)viewController{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *subViewControllers = [self.appNavController.viewControllers mutableCopy];
        [subViewControllers removeObject:viewController];
        self.appNavController.viewControllers = subViewControllers;
    });
}

- (void)removeViewControllerArray:(NSArray *)viewControllerArray{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *subViewControllers = [self.appNavController.viewControllers mutableCopy];
        [subViewControllers removeObjectsInArray:viewControllerArray];
        self.appNavController.viewControllers = subViewControllers;
    });
}

- (NSArray *)getAPPAccessLoaded{
    return self.appNavController.viewControllers;
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (!self.delegate) {
        return YES;
    }
    
    if (![self.delegate respondsToSelector:@selector(tabBarController:shouldSelectIndex:)]){
        return YES;
    }
    
    NSArray *viewControllerArray = tabBarController.viewControllers;
    NSInteger index = [viewControllerArray indexOfObject:viewController];
    if (index < 0 || index >= viewControllerArray.count) {
        return YES;
    }
    return [self.delegate tabBarController:tabBarController shouldSelectIndex:index];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    KQCAppBaseViewController *appViewController = (KQCAppBaseViewController *)viewController;
    appViewController.isTabbarWillChanged = NO;
    [self setNavigationBarHidden:appViewController.navigationBarHidden];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(tabBarController:didSelectIndex:)]) {
        [self.delegate tabBarController:tabBarController shouldSelectIndex:tabBarController.selectedIndex];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KQCTabBarSelectedIndexChangedNotification object:@(tabBarController.selectedIndex)];
}

- (void)setNavigationBarHidden:(BOOL)hidden{
    if (hidden != self.appNavController.navigationBarHidden) {
        self.appNavController.navigationBarHidden = hidden;
    }
}

- (NSInteger)tabBarSelectIndex{
    return self.tabBarController.selectedIndex;
}

- (CGFloat)tabBarHegiht{
    return self.tabBarController.tabBar.height;
}

- (CGFloat)navigationBarHeight{
    return self.appNavController.navigationBar.height;
}

- (CGFloat)statusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

#pragma mark - 设置返回主界面的screenView
- (void)setGestureHomeScreenView{
    KQCPanGestureNavigationController *panNav = (KQCPanGestureNavigationController *)self.appNavController;
    if (panNav.screenViewArray.count > 0 && panNav.classNameArray.count > 0) {
        UIImage *image = panNav.screenViewArray[0];
        NSString *strClassName = panNav.classNameArray[0];
        [panNav.screenViewArray removeAllObjects];
        [panNav.classNameArray removeAllObjects];
        [panNav.screenViewArray addObject:image];
        [panNav.classNameArray addObject:strClassName];
    }
}

#pragma mark - 清空screenView
- (void)clearGestureScreenView{
    KQCPanGestureNavigationController *panNav = (KQCPanGestureNavigationController *)self.appNavController;
    if ([[panNav.viewControllers lastObject] isKindOfClass:[UITabBarController class]]) {
        if (panNav.screenViewArray.count > 0) {
            [panNav.screenViewArray removeAllObjects];
            [panNav.classNameArray removeAllObjects];
        }
    }
}

-(UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
