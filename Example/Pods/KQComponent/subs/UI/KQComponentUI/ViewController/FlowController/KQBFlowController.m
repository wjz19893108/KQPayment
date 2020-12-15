//
//  KQBFlowController.m
//  kuaiQianbao
//
//  Created by xy on 16/3/31.
//
//

#import "KQBFlowController.h"
#import "KQBFlowBaseViewController.h"
#import "KQBStepsIndicatorView.h"

@interface KQBFlowController() <KQBFlowBaseViewControllerDelegate>

@property (nonatomic, weak) KQBFlowController *parent; // 如果为子流程，则该值不为空
@property (nonatomic, assign) NSInteger currentIndex; // 当前处于流程步骤
@property (nonatomic, copy) void (^endBlock)(NSDictionary *paramDic);

@end

@implementation KQBFlowController

+ (instancetype)flowControllerWithFlowArray:(NSArray *)flowArray
                                   flowType:(KQBFlowType)flowType
                                   endBlock:(void(^)(NSDictionary *paramDic))endBlock{
    KQBFlowController *flowController = [[KQBFlowController alloc] init];
    flowController.flowArray = flowArray;
    flowController.flowType = flowType;
    flowController.endBlock = endBlock;
    return flowController;
}

// 创建子流程对象
+ (instancetype)subFlowControllerWithFlowArray:(NSArray *)flowArray
                                      endBlock:(void (^)(NSDictionary *paramDic))endBlock
                          parentFlowController:(KQBFlowController *)parentFlowController{
    KQBFlowController *flowController = [KQBFlowController flowControllerWithFlowArray:flowArray flowType:parentFlowController.flowType endBlock:endBlock];
    flowController.parent = parentFlowController;
    return flowController;
}

- (void)dealloc{
    self.endBlock = NULL;
}

- (void)startFlow{
    [self judgeNextFlow:nil];
}

- (void)judgeNextFlow:(NSDictionary *)paramDic{
    if (self.currentIndex >= self.flowArray.count) {
        return;
    }
    
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:paramDic];
    resultDic[@"flowType"] = @(self.flowType);
    resultDic[@"flowDelegate"] = self;
    
    id target = self.flowArray[self.currentIndex];
    if ([target isKindOfClass:[KQBFlowDataModel class]]) {

        resultDic[@"flowTitle"] = ((KQBFlowDataModel *)target).title;
        [resultDic addEntriesFromDictionary:((KQBFlowDataModel *)target).paramDic];
        [KQC_Engine_UI showViewControllerWithName:((KQBFlowDataModel *)target).viewControllerName param:resultDic];
    } else if ([target isKindOfClass:[NSArray class]]) {
        KQBFlowController *subController = [KQBFlowController subFlowControllerWithFlowArray:target endBlock:^(NSDictionary *paramDic) {
            [self nextStep:nil param:paramDic];
        } parentFlowController:self];
        [subController startFlow];
    }
}

#pragma mark - KQBFlowBaseViewControllerDelegate

- (void)nextStep:(KQBFlowBaseViewController *)viewController param:(NSDictionary *)paramDic{
    if ((self.currentIndex + 1) == self.flowArray.count) { // 流程最后一步，索引不增加，防止后退索引异常
        self.endBlock(paramDic);
    } else {
        self.currentIndex++;
        [self judgeNextFlow:paramDic];
    }
}

- (void)backStep:(KQBFlowBaseViewController *)viewController{
    self.currentIndex--;
    if (self.currentIndex < 0) {
        if (self.parent) { // 子流程第一页后退，需要更新父流程索引
            self.parent.currentIndex--;
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFlowCanceled object:@(self.flowType)];
        }
    }
}

- (KQBStepsIndicatorView *)currentFlowIndicator:(KQBFlowBaseViewController *)viewController{
    KQBFlowController *flowController = self.parent ?: self;

    NSUInteger totalSteps = flowController.flowArray.count;
    if (self.totalStepsBlock) {
        totalSteps = self.totalStepsBlock();
    }
    
    KQBStepsIndicatorView *flowView = [[KQBStepsIndicatorView alloc] initWithCurrentStep:flowController.currentIndex totalSteps:totalSteps frame:CGRectMake(0, 1, KQC_SCREEN_WIDTH, 5)];
    return flowView;
}

@end
