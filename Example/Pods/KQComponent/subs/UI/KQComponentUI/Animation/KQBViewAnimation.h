//
//  KQBaseViewAnimation.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/27.
//  Copyright © 2015年 program. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KQBaseViewAction : NSObject

@end

@interface KQViewActionMove : KQBaseViewAction

- (instancetype __nullable)initWithRect:(CGRect)startRect endRect:(CGRect)endRect;

@end

@interface KQViewActionAlpha : KQBaseViewAction

- (instancetype __nullable)initWithAlpha:(CGFloat)startAlpha endAlpha:(CGFloat)endAlpha;

@end

@interface KQScrollViewContentOffset : KQBaseViewAction

- (instancetype __nullable)initWithOffset:(CGPoint)offsetPoint;

@end

@interface KQBaseViewAnimation : NSObject

- (instancetype __nullable)initWithView:(UIView* __nonnull)antimateView duration:(CGFloat)time;
- (void)addAnimation:(KQBaseViewAction* __nonnull)action;
- (void)startAnimation:(void (^ __nullable)(BOOL finished))completion;

@end
