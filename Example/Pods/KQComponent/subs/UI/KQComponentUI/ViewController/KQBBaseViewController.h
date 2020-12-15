//
//  KQBBaseViewController.h
//  KQBusiness
//
//  Created by pengkang on 2016/12/7.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "UIButton+KQNavgationButton.h"

typedef void(^cpResultBlockWithResCode)(NSDictionary *rsDic,NSString *respCode, NSString *respMsg,BOOL rsFlg);

@interface KQBBaseViewController : KQCAppBaseViewController<UITextFieldDelegate>{
//    float _offSet;
}

@property (nonatomic, strong) UIColor *currentNavgationBarColor; // 此颜色值会被hook（KQBBaseViewController+KQSCTheme）
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, weak) UITextField *activeField;
@property (nonatomic, assign) BOOL isLoaded;//是否加载过
@property (nonatomic, assign, getter=isShowCloseButton) BOOL showCloseButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *rightButton; // 导航栏右按钮
@property (nonatomic, assign) BOOL panGestureFlag;//是否允许侧滑返回标志
//导航栏控件配色，导航栏上受影响的按钮：返回、关闭、分享、更多、和所有只显示文字的按钮
@property (nonatomic, assign) KQNavgationStyle navigationBarStyle;

/*对话框*/
- (void)setNavigationWithView:(UIView *)view;

/*设置Navigation的title*/
- (void)setNavigationTitle:(NSString *)title;
- (void)setNavigationTitle:(NSString *)title color:(UIColor*)color;
- (void)setNavigationItems:(NSString *)title
         leftItemImageName:(NSString*)leftImageName
                  leftText:(NSString*)leftText
                leftAction:(SEL)leftAction
        rightItemImageName:(NSString*)rightImageName
                 rightText:(NSString*) rightText
               rightAction:(SEL)rightAction;
//- (void) showLeftMenu;
/*设置Navigation的颜色*/
- (void)setNavigationColor:(UIColor*)color;
- (void)setNavigationColor:(UIColor*)color duration:(CGFloat)time;

/*键盘处理*/
- (void)keyboardDidShow:(NSNotification *)notif;
- (void)keyboardDidHide:(NSNotification *)notif;

/*textField处理*/
- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)setTextFieldParentViewFrame:(CGRect)frame;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;
- (void)textFieldChanged:(NSNotification *)note;

/*添加navigationBar 左边按钮*/
- (void)addLeftButton:(NSString *)title Action:(SEL)action;

- (void)addLeftButton:(NSString *)title imageName:(NSString *)imageName Action:(SEL)action;
// 增加navigationBar右上角菜单，如果rightButton存在，放rightButton左边，如果rightButton不在，放在rightButton的位置
- (void)addCustomButton:(UIButton *)customButton;

/*为理财首页添加*/
- (void)addLeftBannerButton:(NSString *)title
                  imageName:(NSString *)imageName
                     Action:(SEL)action;

- (void)hideLeftBtn;
- (void)setRightButtonHidden:(BOOL)hidden;

- (void)addRightButtonWithTitle:(NSString *)title Action:(SEL)action;
- (void)addRightButtonWithImage:(NSString *)imageName Action:(SEL)action;
//-(void)addRightButtonTitleAndImage:(NSString *)title imageName:(NSString *)imageName action:(SEL)action;
-(void)addRightButtonWithEnabled:(NSString *)title imageName:(NSString *)imageName action:(SEL)action enabled:(BOOL)enabled;
// 右边按钮字数过长
- (void)addRightButtonWithTooLongTitle:(NSString *)title Action:(SEL)action;
- (void)addRightButtonWithView:(UIView*) view;
/*左边按钮事件*/
- (void)leftButtonClick:(id)sender;
/*右边按钮事件*/
- (void)rightButtonClick:(id)sender;

/**
 * 增加友盟统计事件
 * 子类覆写该方法增加自己的需要统计的事件
 */
- (void)setupStatisticsEvent;

/// 设置当前页面背景颜色
- (void)setCurrentPageBackgroundColor;

@end
