//
//  KQPanGestureNavigationController.h
//  kuaiQianbao
//
//  Created by hao on 16/4/9.
//
//

#import <UIKit/UIKit.h>

@interface KQCPanGestureNavigationController : UINavigationController <UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *screenViewArray;//保存VC截屏
@property (nonatomic, strong) NSMutableArray *classNameArray;//保存VC className
- (void)panGestureEvents:(UIPanGestureRecognizer *)recoginzer;
@end
