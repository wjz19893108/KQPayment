//
//  KQRightBarButtonItemPopView.h
//  kuaiQianbao
//
//  Created by building wang on 16/1/14.
//
//

#import <UIKit/UIKit.h>

@interface KQBRightBarButtonItemPopView : UIView

- (instancetype)initWithPoint:(CGPoint)point popViewArray:(NSArray *)popViewArray;
- (void)show;
- (void)dismiss;
- (void)dismiss:(BOOL)animated;

@property (nonatomic, copy) UIColor *borderColor;   //边框颜色
@property (nonatomic, copy) UIColor *fillColor;     //边框和cell的内部填充色
@property (nonatomic, copy) UIColor *fontColor;     //cell里面的文字颜色
@property (nonatomic, assign) NSTextAlignment textAlignment;    //cell里面的文字对齐
@property (nonatomic, copy) UIColor *maskColor;     //蒙版颜色
@property (nonatomic, assign) CGFloat maskAlpha;    //蒙版透明度
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);

@end
