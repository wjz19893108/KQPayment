//
//  KQBFlowController.h
//  kuaiQianbao
//
//  Created by xy on 16/3/31.
//
//

#import <Foundation/Foundation.h>
#import "KQBFlowDataModel.h"

#define kNotificationFlowCanceled                       @"flowCanceled"    // 流程取消通知

@interface KQBFlowController : NSObject

/**
 *  存放KQBFlowDataModel以及KQBFlowController对象，如果为KQBFlowController，则说明有子对象
 */
@property (nonatomic, strong) NSArray *flowArray;
@property (nonatomic, assign) KQBFlowType flowType;

@property (nonatomic, copy) NSUInteger (^totalStepsBlock)(void);

+ (instancetype)flowControllerWithFlowArray:(NSArray *)flowArray flowType:(KQBFlowType)flowType endBlock:(void(^)(NSDictionary *paramDic))endBlock;

// 开始启动流程
- (void)startFlow;

@end
