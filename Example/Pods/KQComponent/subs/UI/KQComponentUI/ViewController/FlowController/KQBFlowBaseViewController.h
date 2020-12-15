//
//  KQBFlowBaseViewController.h
//  kuaiQianbao
//
//  Created by xy on 16/3/31.
//
//

#import "KQBBaseViewController.h"
#import "KQBFlowDataModel.h"

@class KQBFlowBaseViewController;
@class KQBStepsIndicatorView;
@protocol KQBFlowBaseViewControllerDelegate <NSObject>

/*
 * 跳转下一个界面使用此方法
 */
- (void)nextStep:(KQBFlowBaseViewController *)viewController param:(NSDictionary *)paramDic;

/*
 * 返回上一个界面使用此方法
 */
- (void)backStep:(KQBFlowBaseViewController *)viewController;

/*
 * 获取当前界面的流程指示器
 */
- (KQBStepsIndicatorView *)currentFlowIndicator:(KQBFlowBaseViewController *)viewController;

@end

@interface KQBFlowBaseViewController : KQBBaseViewController

@property (nonatomic, weak) id<KQBFlowBaseViewControllerDelegate> flowDelegate;
@property (nonatomic, assign) KQBFlowType flowType; // 流程类型
@property (nonatomic, strong) NSString *flowTitle; // 标题

@property (nonatomic, strong) KQBStepsIndicatorView *flowIndicatorView;

- (void)showNextFlowViewController:(NSDictionary *)paramDic;

@end
