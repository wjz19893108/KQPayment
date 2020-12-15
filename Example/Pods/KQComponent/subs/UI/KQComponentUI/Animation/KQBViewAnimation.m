//
//  KQBaseViewAnimation.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/27.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQBViewAnimation.h"

/*
 view动画基类，只包含设置开始状态和结束状态两个方法
 */
@implementation KQBaseViewAction

- (void)setStartViewState:(UIView* __nonnull)antimateView
{
    
}

- (void)setEndViewState:(UIView* __nonnull)antimateView
{
    
}

@end

/*
 view动画：移动，设置view的frame
 */
@interface KQViewActionMove ()

@property (nonatomic, assign) CGRect startRect;
@property (nonatomic, assign) CGRect endRect;

@end

@implementation KQViewActionMove

- (instancetype __nullable)initWithRect:(CGRect)startRect endRect:(CGRect)endRect
{
    self = [super init];
    if (self) {
        self.startRect = startRect;
        self.endRect = endRect;
    }
    return self;
}

- (void)setStartViewState:(UIView* __nonnull)antimateView
{
    antimateView.frame = self.startRect;
}

- (void)setEndViewState:(UIView* __nonnull)antimateView
{
    antimateView.frame = self.endRect;
}

@end

/*
 view动画：alpha，设置view的alpha
 */
@interface KQViewActionAlpha ()

@property (nonatomic, assign) CGFloat startAlpha;
@property (nonatomic, assign) CGFloat endAlpha;

@end

@implementation KQViewActionAlpha

- (instancetype __nullable)initWithAlpha:(CGFloat)startAlpha endAlpha:(CGFloat)endAlpha
{
    self = [super init];
    if (self) {
        self.startAlpha = startAlpha;
        self.endAlpha = endAlpha;
    }
    return self;
}

- (void)setStartViewState:(UIView* __nonnull)antimateView
{
    antimateView.alpha = self.startAlpha;
}

- (void)setEndViewState:(UIView* __nonnull)antimateView
{
    antimateView.alpha = self.endAlpha;
}

@end

/*
 scrollview动画：contentoffset
 */

@interface KQScrollViewContentOffset ()

@property (nonatomic, assign) CGPoint offsetPoint;

@end

@implementation KQScrollViewContentOffset

- (instancetype __nullable)initWithOffset:(CGPoint)offsetPoint
{
    self = [super init];
    if (self) {
        self.offsetPoint = offsetPoint;
    }
    return self;
}

- (void)setEndViewState:(UIView* __nonnull)antimateView
{
    if ([antimateView isKindOfClass:[UIScrollView class]]) {
        CGPoint endPoint;
        endPoint.x = ((UIScrollView*)antimateView).contentOffset.x + self.offsetPoint.x;
        endPoint.y = ((UIScrollView*)antimateView).contentOffset.y + self.offsetPoint.y;
        ((UIScrollView*)antimateView).contentOffset = endPoint;
    }
}

@end

/*
 view动画执行
 */
@interface KQBaseViewAnimation ()

@property (nonatomic, weak) UIView *antimateView;
@property (nonatomic, assign) CGFloat antimateTime;
@property (nonatomic, strong) NSMutableArray *actionArray;

@end

@implementation KQBaseViewAnimation

- (instancetype __nullable)initWithView:(UIView* __nonnull)antimateView duration:(CGFloat)time
{
    self = [super init];
    if (self) {
        self.antimateView = antimateView;
        self.antimateTime = time;
        self.actionArray = [NSMutableArray array];
    }
    return self;
}

- (void)addAnimation:(KQBaseViewAction* __nonnull)action
{
    if ([action isKindOfClass:[KQBaseViewAction class]]) {
        [self.actionArray addObject:action];
    }
}

- (void)startAnimation:(void (^ __nullable)(BOOL finished))completion
{
    for (KQBaseViewAction * action in self.actionArray) {
        [action setStartViewState:self.antimateView];
    }
    [UIView animateWithDuration:self.antimateTime
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         for (KQBaseViewAction * action in self.actionArray) {
                             [action setEndViewState:self.antimateView];
                         }
                     }
                     completion:^(BOOL finished){
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

- (void)dealloc
{
    NSLog(@"%@：dealloc", self);
}

@end
