//
//  KQCUIManager.h
//  KQCore
//
//  Created by xy on 2016/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KQC_Engine_UI    [KQCUIEngine sharedKQCUIEngine]

@class KQCAppBaseViewController;
@class KQCBufferedNavigationController;
@class KQCTabBarDataModel;

@protocol KQCUIEngineDelegate <NSObject>

@optional
/**
 是否可以选择该tab

 @param tabBarController 目标UITabBarController
 @param index 待选中的索引
 @return YES:允许选择 NO:不允许选择
 */
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectIndex:(NSInteger)index;

/**
 已选中索引

 @param tabBarController 目标UITabBarController
 @param index 已选中的索引
 */
- (void)tabBarController:(UITabBarController *)tabBarController didSelectIndex:(NSInteger)index;

@end

@interface KQCUIEngine : NSObject

@property (nonatomic, strong) UIColor *navigationBarTintColor;
@property (nonatomic, strong) KQCBufferedNavigationController *appNavController; // 程序全局的nav
@property (nonatomic, strong) KQCTabBarDataModel *tabBarData;
@property (nonatomic, weak) id<KQCUIEngineDelegate> delegate;

+ (KQCUIEngine *)sharedKQCUIEngine;

/**
 显示根控制器
 */
- (void)showRootViewController;

/**
 *  返回上一界面
 *
 *  @return 当前界面
 */
- (KQCAppBaseViewController *)popViewController;

/**
 *  返回上一界面
 *
 *  @param animated 是否需要动画
 *
 *  @return 当前界面
 */
- (KQCAppBaseViewController *)popViewControllerWithAnimated:(BOOL)animated;

/**
 *  返回到指定的界面
 *
 *  @param viewController  指定的界面对象
 *
 *  @return pop出的数组
 */
- (NSArray *)popToViewController:(UIViewController *)viewController;

/**
 *  返回到指定的界面
 *
 *  @param viewController  指定的界面对象
 *  @param notFoundBlock   未找到指定的对象，执行该block
 *
 *  @return pop出的数组
 */
- (NSArray *)popToViewController:(UIViewController *)viewController notFoundBlock:(void(^)(void))notFoundBlock;

/**
 *  返回到指定的界面
 *
 *  @param viewControllerName  指定的界面
 *
 *  @return pop出的数组
 */
- (NSArray *)popToViewControllerWithName:(NSString *)viewControllerName;

/**
 *  返回到指定的界面
 *
 *  @param viewControllerName 指定的界面
 *  @param notFoundBlock      未知道指定的界面，执行该block
 *
 *  @return pop出的数组
 */
- (NSArray *)popToViewControllerWithName:(NSString *)viewControllerName notFoundBlock:(void(^)(void))notFoundBlock;

/**
 *  获取最上层界面
 *
 *  @return 顶部界面
 */
- (KQCAppBaseViewController *)topViewController;

/**
 *  返回tabController当前选中的viewController
 *
 *  @return KQCAppBaseViewController
 */
- (KQCAppBaseViewController *)currentSelectedViewControllerInTab;

/**
 *  返回tabController当前选中的viewController的类名
 */
- (NSString *)currentSelectedViewControllerClassInTab;

/**
 *  切换TAB
 *
 *  @index 指定跳转的Index
 *  @paramDic 指定跳转的参数
 *
 */
- (void)switchTabAtIndex:(NSUInteger)index;

- (void)switchTabAtIndex:(NSUInteger)index param:(NSDictionary *)paramDic;

/**
 *  切换TAB并返回至首页
 *
 *  @index 指定跳转的Index
 *  @paramDic 指定跳转的参数
 *
 */
- (void)switchTabAndPop2RootAtIndex:(NSUInteger)index param:(NSDictionary *)paramDic;

- (UIViewController *)showViewControllerWithName:(NSString *)viewControllerName;

- (UIViewController *)showViewControllerWithName:(NSString *)viewControllerName param:(NSDictionary *)dic;

- (UIViewController *)showViewControllerWithName:(NSString *)viewControllerName animated:(BOOL)animated;

/**
 *  根据类进行界面跳转
 *
 *  @param viewControllerName 目标类名字符串
 *  @param dic                传递的参数
 *  @param animated           是否显示动画
 *
 *  @return UIViewController 要显示的VC对象
 */
- (UIViewController *)showViewControllerWithName:(NSString *)viewControllerName param:(NSDictionary *)dic animated:(BOOL)animated;

- (void)showViewControllerWithNameArray:(NSArray *)nameArray param:(NSArray *)paramArray;

- (void)showViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 创建界面

 @param viewControllerName 界面名称
 @param dic                界面参数

 @return 界面对象
 */
- (KQCAppBaseViewController *)createAppBaseViewController:(NSString *)viewControllerName param:(NSDictionary *)dic;

/**
 移除最后一个不需要保存的控制器

 @param topViewController 待移除的控制器
 */
- (void)removeLastNotSaveViewController:(UIViewController *)topViewController;

/**
 *  获取已经加载的VC
 */
- (NSArray *)getAPPAccessLoaded;

/**
 *  隐藏导航栏
 */
- (void)setNavigationBarHidden:(BOOL)hidden;

/*
 tabBar当前选中item
 */
- (NSInteger)tabBarSelectIndex;

/*
 tabBar高度
 */
- (CGFloat)tabBarHegiht;

/*
 navgationBar高度
 */
- (CGFloat)navigationBarHeight;

/*
 statusBar高度
 */
- (CGFloat)statusBarHeight;

/**
 移除指定的界面

 @param viewController 目标界面
 */
- (void)removeViewController:(UIViewController *)viewController;

/**
 移除指定数组的界面

 @param viewControllerArray 界面数组
 */
- (void)removeViewControllerArray:(NSArray *)viewControllerArray;

/**
 *  设置返回主界面的screenView
 */
- (void)setGestureHomeScreenView;
/**
 *  清空screenView
 */
- (void)clearGestureScreenView;

FOUNDATION_EXTERN NSNotificationName const KQCTabBarSelectedIndexChangedNotification;

@end
