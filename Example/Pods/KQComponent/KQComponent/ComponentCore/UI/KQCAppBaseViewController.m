//
//  KQAppBaseViewController.m
//  kuaishua
//
//  Created by xy on 15/1/4.
//
//

#import "KQCAppBaseViewController.h"

@interface KQCAppBaseViewController()

@end

@implementation KQCAppBaseViewController

- (id)init{
    self = [super init];
    if (self) {
        [self appBaseViewControllerInitialize];
    }
    return self;
}

- (void)appBaseViewControllerInitialize{
    self.lifeCycle = KQAppBaseViewControllerLifeCycleInit;
    self.isCanSave = YES;
}

- (void)loadView{
    [super loadView];
    
    self.lifeCycle = KQAppBaseViewControllerLifeCycleLoadView;
    [self parseViewControllerParamDic];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.lifeCycle = KQAppBaseViewControllerLifeCycleViewDidLoad;
}

- (void)parseViewControllerParamDic{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.lifeCycle = KQAppBaseViewControllerLifeCycleViewWillAppear;
//    [KQBStatisticsManager beginLogPageView:self];
    if (!self.isTabbarWillChanged) { // tabbar切换的时候，不设置
        [KQC_Engine_UI setNavigationBarHidden:self.navigationBarHidden];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.lifeCycle = KQAppBaseViewControllerLifeCycleViewDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.lifeCycle = KQAppBaseViewControllerLifeCycleViewWillDisappear;
//    [KQBStatisticsManager endLogPageView:self];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    self.lifeCycle = KQAppBaseViewControllerLifeCycleViewDidDisappear;
}

- (void)dealloc{
    self.lifeCycle = KQAppBaseViewControllerLifeCycleDealloc;
}

@end
