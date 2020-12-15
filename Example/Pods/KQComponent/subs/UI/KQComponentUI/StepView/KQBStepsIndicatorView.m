//
//  KQBStepsIndicatorView.m
//  kuaiQianbao
//
//  Created by 张蓓 on 15/10/16.
//
//

#import "KQBStepsIndicatorView.h"

static NSArray *sColorArray;
static NSArray *sSeparateImgArray;

@implementation KQBStepsIndicatorView

-(id) initWithCurrentStep:(NSInteger)currentStep totalSteps:(NSInteger)totalSteps frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!sColorArray) {
            //粉色，红色，灰色
            sColorArray = @[[UIColor colorWithRGB:0xf3b0b1], [KQBColor colorWithType:KQBColorTypeNavigationBarTint], [KQBColor colorWithType:KQBColorTypeSeperator]];
            sSeparateImgArray = @[@[@"pink-to-pink",@"pnk-to-red",@"f-h"],@[@"r-f",@"r-r",@"red-to-gray"],@[@"h-f",@"h-r",@"gray-to-gray"]];
        }
        self.currentStep = currentStep;
        self.totalSteps = totalSteps;
        if (totalSteps == 0) {
            return self;
        }
        NSMutableArray *mStepsColorArray = [NSMutableArray array];
        CGFloat width = KQC_SCREEN_WIDTH / ((CGFloat)totalSteps);
        for (NSInteger i = 0; i < totalSteps; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake((i==0)?0:3 + width*i, 0, width - ((i!=totalSteps-1)?3:0) - ((i!=0)?3:0), self.height)];
            
            if (i < currentStep) {
                [mStepsColorArray addObject:@(0)];
            } else if (i == currentStep) {
                [mStepsColorArray addObject:@(1)];
            } else {
                [mStepsColorArray addObject:@(2)];
            }
            view.backgroundColor = sColorArray[[mStepsColorArray[i] integerValue]];
            [self addSubview:view];
        }
        for (NSInteger i = 0; i < totalSteps-1; i++) {
            NSString *imgName = sSeparateImgArray[[mStepsColorArray[i] integerValue]][[mStepsColorArray[i+1] integerValue]];
            UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage kqb_imageNamed:imgName]];
            imgView.center = CGPointMake(width*(i+1), self.height/2);
            [self addSubview:imgView];
        }
    }
    return self;
}

@end
