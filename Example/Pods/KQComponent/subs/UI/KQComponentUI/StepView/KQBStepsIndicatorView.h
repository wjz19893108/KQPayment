//
//  KQBStepsIndicatorView.h
//  kuaiQianbao
//
//  Created by 张蓓 on 15/10/16.
//
//

#import <UIKit/UIKit.h>

@interface KQBStepsIndicatorView : UIView

@property (nonatomic,assign) NSInteger totalSteps;
@property (nonatomic,assign) NSInteger currentStep;
-(id) initWithCurrentStep:(NSInteger)currentStep totalSteps:(NSInteger)totalSteps frame:(CGRect)frame;
@end
