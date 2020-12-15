//
//  KQBFlowBaseViewController.m
//  kuaiQianbao
//
//  Created by xy on 16/3/31.
//
//

#import "KQBFlowBaseViewController.h"
#import "KQBStepsIndicatorView.h"

@implementation KQBFlowBaseViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setNavigationTitle:self.flowTitle];
    [self addLeftButton:@"" Action:@selector(leftButtonClick:)];
    
    if (self.flowDelegate && [self.flowDelegate respondsToSelector:@selector(currentFlowIndicator:)]) {
        self.flowIndicatorView = [self.flowDelegate currentFlowIndicator:self];
        [self.contentView addSubview:self.flowIndicatorView];
    }
}

- (void)leftButtonClick:(id)sender{
    [super leftButtonClick:sender];
    
    if (self.flowDelegate && [self.flowDelegate respondsToSelector:@selector(backStep:)]) {
        [self.flowDelegate backStep:self];
    }
}

- (void)showNextFlowViewController:(NSDictionary *)paramDic{
    if (self.flowDelegate && [self.flowDelegate respondsToSelector:@selector(nextStep:param:)]) {
        [self.flowDelegate nextStep:self param:paramDic];
    }
}

@end
