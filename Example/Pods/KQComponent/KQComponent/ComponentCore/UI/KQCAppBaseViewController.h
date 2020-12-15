//
//  KQAppBaseViewController.h
//  kuaishua
//
//  Created by xy on 15/1/4.
//
//

#import "KQCUIEngine.h"
//#import "KQScreenMacro.h"
//

typedef NS_ENUM(NSInteger, KQAppBaseViewControllerLifeCycle) {
    KQAppBaseViewControllerLifeCycleInit = 1,
    KQAppBaseViewControllerLifeCycleLoadView,
    KQAppBaseViewControllerLifeCycleViewDidLoad,
    KQAppBaseViewControllerLifeCycleViewWillAppear,
    KQAppBaseViewControllerLifeCycleViewDidAppear,
    KQAppBaseViewControllerLifeCycleViewWillDisappear,
    KQAppBaseViewControllerLifeCycleViewDidDisappear,
    KQAppBaseViewControllerLifeCycleDealloc,
};

@interface KQCAppBaseViewController : UIViewController

@property (nonatomic, strong) NSDictionary *paramDic; // 传递参数用
@property (nonatomic, assign) BOOL isCanSave; // 销毁标志，显示下个界面是否要销毁当前界面
@property (nonatomic, assign) BOOL navigationBarHidden;  // 是否隐藏导航栏
@property (nonatomic, assign) BOOL isTabbarWillChanged;  // 是否正处在tabbar切换中
@property (nonatomic, strong) id statisKey;       // 友盟统计的界面业务区别Key,如果界面没有共用，则不需要设置此值
@property (nonatomic, assign) BOOL isPushedByNotification;  // 是否由推送通知调起
@property (nonatomic, assign) KQAppBaseViewControllerLifeCycle lifeCycle; // 生命周期状态

/**
 * 解析参数
 * 子类覆写该方法解析出自己需要的参数
 */
- (void)parseViewControllerParamDic;

@end
