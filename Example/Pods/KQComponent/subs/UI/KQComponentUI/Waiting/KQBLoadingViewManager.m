//
//  KQPayLoadingViewManager.m
//  KQProcess
//
//  Created by zouf on 17/2/10.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBLoadingViewManager.h"

@interface KQBLoadingViewManager ()

@property (nonatomic, strong) NSMutableArray * layerArray;

@end

@implementation KQBLoadingViewManager

SYNTHESIZE_SINGLETON_FOR_CLASS(KQBLoadingViewManager);

- (void)startLoading:(UIView *)parentView lineColor:(UIColor *)lineColor {
    [self clearOtherLayer];
    CALayer *backCover = [[CALayer alloc] init];
    backCover.frame = CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height);
    [parentView.layer addSublayer:backCover];
    [self.layerArray addObject:backCover];
    
    CGRect rect = parentView.bounds;
    if (parentView.frame.size.width > parentView.frame.size.height) {
        rect = CGRectInset(rect, (parentView.frame.size.width - parentView.frame.size.height)/2, 0);
    } else {
        rect = CGRectInset(rect, 0, (parentView.frame.size.height - parentView.frame.size.width)/2);
    }
    const int STROKE_WIDTH = (rect.size.width/20 <= 1)?1:rect.size.width/20;
    
    //透明圆
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)) radius:rect.size.width / 2 - STROKE_WIDTH startAngle:  0 * M_PI/180 endAngle: 360 * M_PI/180 clockwise: NO];
    CAShapeLayer *alphaLineLayer = [CAShapeLayer layer];
    alphaLineLayer.path = circlePath.CGPath;
    CGFloat r,g,b,a;
    [lineColor getRed:&r green:&g blue:&b alpha:&a];
    alphaLineLayer.strokeColor = [UIColor colorWithRed:r green:g blue:b alpha:a*0.3].CGColor;
    alphaLineLayer.lineWidth = STROKE_WIDTH;
    alphaLineLayer.fillColor = [UIColor clearColor].CGColor;
    [backCover addSublayer: alphaLineLayer];
    [self.layerArray addObject:alphaLineLayer];
    
    CAShapeLayer *drawLayer = [CAShapeLayer layer];
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    [progressPath addArcWithCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)) radius:rect.size.width / 2 - STROKE_WIDTH startAngle: 0 * M_PI / 180 endAngle: 360 * M_PI / 180 clockwise: YES];
    
    drawLayer.lineWidth = STROKE_WIDTH;
    drawLayer.fillColor = [UIColor clearColor].CGColor;
    drawLayer.path = progressPath.CGPath;
    drawLayer.frame = drawLayer.bounds;
    drawLayer.strokeColor = lineColor.CGColor;
    [backCover addSublayer:drawLayer];
    [self.layerArray addObject:drawLayer];
    
    // 开始划线的动画
    CABasicAnimation *progressLongAnimation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    progressLongAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
    progressLongAnimation.toValue = [NSNumber numberWithFloat: 1.0];
    progressLongAnimation.duration = 1;
    CAMediaTimingFunction *progressRotateTimingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 :0.80 :0.75 :1.00];
    progressLongAnimation.timingFunction = progressRotateTimingFunction;
    progressLongAnimation.repeatCount = 10000;
    
    // 线条逐渐变短收缩的动画
    CABasicAnimation *progressLongEndAnimation = [CABasicAnimation animationWithKeyPath: @"strokeStart"];
    progressLongEndAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
    progressLongEndAnimation.toValue = [NSNumber numberWithFloat: 1.0];
    progressLongEndAnimation.duration = 1;
    CAMediaTimingFunction *strokeStartTimingFunction = [[CAMediaTimingFunction alloc] initWithControlPoints: 0.65 : 0.0 :1.0 : 1.0];
    progressLongEndAnimation.timingFunction = strokeStartTimingFunction;
    progressLongEndAnimation.repeatCount = 10000;
    
    [drawLayer addAnimation:progressLongAnimation forKey: @"strokeEnd"];
    [drawLayer addAnimation:progressLongEndAnimation forKey: @"strokeStart"];
    
    //    backCover.transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI_2, 0, 0, 1), CATransform3DMakeRotation(M_PI, 0, 1, 0));
    backCover.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
}

- (void)successLoading:(UIView *)parentView lineColor:(UIColor *)lineColor {
    [self clearOtherLayer];
    CGRect rect = parentView.bounds;
    if (parentView.frame.size.width > parentView.frame.size.height) {
        rect = CGRectInset(rect, (parentView.frame.size.width - parentView.frame.size.height)/2, 0);
    } else {
        rect = CGRectInset(rect, 0, (parentView.frame.size.height - parentView.frame.size.width)/2);
    }
    const int STROKE_WIDTH = (rect.size.width/20 <= 1)?1:rect.size.width/20;
    
    //外圈
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)) radius:rect.size.width / 2 - STROKE_WIDTH startAngle:  0 * M_PI/180 endAngle: 360 * M_PI/180 clockwise: NO];
    CAShapeLayer *alphaLineLayer = [CAShapeLayer layer];
    alphaLineLayer.path = circlePath.CGPath;
    alphaLineLayer.strokeColor = lineColor.CGColor;
    alphaLineLayer.lineWidth = STROKE_WIDTH;
    alphaLineLayer.fillColor = [UIColor clearColor].CGColor;
    [parentView.layer addSublayer: alphaLineLayer];
    [self.layerArray addObject:alphaLineLayer];
    
    CAShapeLayer *drawLayer = [CAShapeLayer layer];
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    // 起始点
    [progressPath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height * 0.35)];
    // 绘制对号第一笔
    [progressPath addLineToPoint: CGPointMake(rect.origin.x + rect.size.width * 0.42, rect.origin.y + rect.size.height * 0.68)];
    // 绘制对号第二笔
    [progressPath addLineToPoint: CGPointMake(rect.origin.x + rect.size.width * 0.75, rect.origin.y + rect.size.height * 0.35)];
    drawLayer.lineCap = kCALineCapRound;// 圆角画笔
    drawLayer.lineWidth = STROKE_WIDTH;
    drawLayer.fillColor = [UIColor clearColor].CGColor;
    drawLayer.path = progressPath.CGPath;
    drawLayer.frame = drawLayer.bounds;
    drawLayer.strokeColor = lineColor.CGColor;
    [parentView.layer addSublayer:drawLayer];
    [self.layerArray addObject:drawLayer];
    
    //勾号头部运动到路径末尾
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    animation.duration = 0.7;
    animation.fromValue = [NSNumber numberWithInt: 0.0];
    animation.toValue = [NSNumber numberWithInt: 1.0];
    //勾号尾部收缩一点
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath: @"strokeStart"];
    strokeStartAnimation.duration = 0.7;
    strokeStartAnimation.fromValue = [NSNumber numberWithFloat: 0.15];
    strokeStartAnimation.toValue = [NSNumber numberWithFloat: 0.3];
    strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.6 :0.8 :1.1];
    
    drawLayer.strokeStart = 0.3;
    drawLayer.strokeEnd = 1.0;
    
    [drawLayer addAnimation: animation forKey: @"strokeEnd"];
    [drawLayer addAnimation: strokeStartAnimation forKey: @"strokeStart"];
}

- (void)failLoading:(UIView *)parentView lineColor:(UIColor *)lineColor {
    [self clearOtherLayer];
    CGRect rect = parentView.bounds;
    if (parentView.frame.size.width > parentView.frame.size.height) {
        rect = CGRectInset(rect, (parentView.frame.size.width - parentView.frame.size.height)/2, 0);
    } else {
        rect = CGRectInset(rect, 0, (parentView.frame.size.height - parentView.frame.size.width)/2);
    }
    const int STROKE_WIDTH = (rect.size.width/20 <= 1)?1:rect.size.width/20;
    
    //外圈
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)) radius:rect.size.width / 2 - STROKE_WIDTH startAngle:  0 * M_PI/180 endAngle: 360 * M_PI/180 clockwise: NO];
    CAShapeLayer *alphaLineLayer = [CAShapeLayer layer];
    alphaLineLayer.path = circlePath.CGPath;
    alphaLineLayer.strokeColor = lineColor.CGColor;
    alphaLineLayer.lineWidth = STROKE_WIDTH;
    alphaLineLayer.fillColor = [UIColor clearColor].CGColor;
    [parentView.layer addSublayer: alphaLineLayer];
    [self.layerArray addObject:alphaLineLayer];
    
    //左叉叉图层
    CAShapeLayer *leftLayer = [CAShapeLayer layer];
    leftLayer.frame = leftLayer.bounds;
    leftLayer.fillColor = [UIColor clearColor].CGColor;
    leftLayer.lineCap = kCALineCapRound;// 圆角画笔
    leftLayer.lineWidth = STROKE_WIDTH;
    leftLayer.strokeColor = lineColor.CGColor;
    
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath moveToPoint: CGPointMake(rect.origin.x + rect.size.width * 0.2, rect.origin.y + rect.size.height * 0.2)];
    [leftPath addLineToPoint: CGPointMake(rect.origin.x + rect.size.width * 0.7, rect.origin.y + rect.size.height * 0.7)];
    leftLayer.path = leftPath.CGPath;
    [parentView.layer addSublayer: leftLayer];
    [self.layerArray addObject:leftLayer];
    
    //头部运动到路径末尾
    CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.3 :0.6 :0.8 :1.1];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    animation.duration = 0.35;
    animation.fromValue = [NSNumber numberWithInt: 0.0];
    animation.toValue = [NSNumber numberWithInt: 1.0];
    //尾部收缩一点
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath: @"strokeStart"];
    strokeStartAnimation.duration = 0.35;
    strokeStartAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
    strokeStartAnimation.toValue = [NSNumber numberWithFloat: 0.2];
    strokeStartAnimation.timingFunction = timing;
    
    leftLayer.strokeStart = 0.2;
    leftLayer.strokeEnd = 1.0;
    
    [leftLayer addAnimation: animation forKey: @"strokeEnd"];
    [leftLayer addAnimation: strokeStartAnimation forKey: @"strokeStart"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //右叉叉图层
        CAShapeLayer *rightLayer = [CAShapeLayer layer];
        rightLayer.frame = rightLayer.bounds;
        rightLayer.fillColor = [UIColor clearColor].CGColor;
        rightLayer.lineCap = kCALineCapRound;// 圆角画笔
        rightLayer.lineWidth = STROKE_WIDTH;
        rightLayer.strokeColor = lineColor.CGColor;
        
        UIBezierPath *rightPath = [UIBezierPath bezierPath];
        [rightPath moveToPoint: CGPointMake(rect.origin.x + rect.size.width * 0.8, rect.origin.y + rect.size.height * 0.2)];
        [rightPath addLineToPoint: CGPointMake(rect.origin.x + rect.size.width * 0.3, rect.origin.y + rect.size.height * 0.7)];
        rightLayer.path = rightPath.CGPath;
        [parentView.layer addSublayer: rightLayer];
        [self.layerArray addObject:rightLayer];
        
        rightLayer.strokeStart = 0.2;
        rightLayer.strokeEnd = 1.0;
        
        [rightLayer addAnimation: animation forKey: @"strokeEnd"];
        [rightLayer addAnimation: strokeStartAnimation forKey: @"strokeStart"];
    });
}

- (void)clearOtherLayer {
    if (!self.layerArray) {
        self.layerArray = [@[] mutableCopy];
    }
    [self.layerArray enumerateObjectsUsingBlock:^(CAShapeLayer *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self.layerArray removeAllObjects];
}

@end
