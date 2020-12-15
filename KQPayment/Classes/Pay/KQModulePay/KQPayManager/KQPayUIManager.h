//
//  KQPayUIManager.h
//  kuaiQianbao
//
//  Created by zouf on 16/1/15.
//
//

#import <Foundation/Foundation.h>
#import "KQPayViewStepDelegate.h"


@interface KQPayUIManager : NSObject

/**
 初始化
 
 @param parentView 通常在新的KQPaymentInfoBaseVC的view中显示
 */
- (instancetype __nullable)initAllView:(UIView* __nonnull)parentView;


/**
 显示支付view

 @param payViewStep 显示哪一个view
 @param paramDic 显示view所带的参数
 @param completion 完成后要执行的block
 */
- (void)pushPayViewWithStep:(KQPayViewStep)payViewStep delegate:(id __nonnull)delegate withParam:(NSDictionary* __nullable)paramDic completion:(void (^ __nullable)(BOOL finished))completion;

/**
 同上，显示支付view
 
 @param payView 显示的view
 @param paramDic 显示view所带的参数
 @param completion 完成后要执行的block
 */
- (void)pushPayViewWithView:(UIView * __nonnull)payView withParam:(NSDictionary* __nullable)paramDic completion:(void (^ __nullable)(BOOL finished))completion;

/**
 同上，显示支付view

 @param payViewClassName 显示哪一个view(类名称)
 @param paramDic 显示view所带的参数
 @param completion 完成后要执行的block
 */
- (void)pushPayViewWithClassName:(NSString * __nonnull)payViewClassName withParam:(NSDictionary* __nullable)paramDic completion:(void (^ __nullable)(BOOL finished))completion;


/**
 支付步骤回退到上一步

 @param completion 完成后要执行的block
 */
- (void)popPayView:(void (^ __nullable)(void))completion;


/**
 支付步骤会退到第一步，支付详情页

 @param completion 完成后要执行的block
 */
- (void)popToFirstPayView:(void (^ __nullable)(void))completion;


/**
 关闭所有支付页面

 @param completion 完成后要执行的block
 */
- (void)popAllPayView:(void (^ __nullable)(void))completion;


/**
 返回当前的支付view

 @return 返回当前的支付view
 */
- (UIView* __nullable)topPayView;


/**
 支付流程不动，主要用于再次显示当前的输入键盘

 @return 返回YES表示已经初始化，返回NO表示还没有初始化，如果还没有初始化，则要退出支付流程
 */
- (BOOL)stayHere;

@end
