//
//  KQBasePayHalfView.h
//  kuaiQianbao
//
//  Created by zouf on 15-11-26
//
//

/*
 快钱支付采用底部弹出View的显示方式，并且也可以像navgation一样左右导航
 这个类模拟了半个页面，包含
 1.从底部、左边(后退)、右边(前进)移入等显示方式
 2.从底部、左边(前进)、右边(后退)移出等显示方式
 */

/*
 左上角关闭按钮有叉和返回两种样式
 */
typedef NS_ENUM(NSInteger, KQBaseCloseImageType)
{
    KQBaseCloseImageClose = 0,
    KQBaseCloseImageBack,
};


#define KQBASE_NAVIGATE_VIEW_HEIGHT             430                         //弹出view高度+一个余量(见init方法)
#define KQBASE_NAVIGATE_TITLE_HEIGHT            49                          //标题栏高度
#define KQBASE_NAVIGATE_SEPARATOR_HEIGHT        1                           //分隔线高度
#define KQPAYSUBVIEW_START_Y_POS                (KQBASE_NAVIGATE_TITLE_HEIGHT+KQBASE_NAVIGATE_SEPARATOR_HEIGHT)          //tableview的y坐标起始点
#define KQPAYTABLE_CELL_HEIGHT                  44                          //tableview每个cell的高度
#define KQPAY_METHOD_TABLE_CELL_HEIGHT          49                          //支付方式tableview每个cell的高度
#define KQPAY_INSTALLMENT_TABLE_CELL_HEIGHT     70                          //分期tableview每个cell的高度
#define KQPAY_VOUCHER_TABLE_CELL_HEIGHT         78                          //优惠券tableview每个cell的高度
#define KQPAYDETAIL_PAYMENT_HEIGHT              56                          //需付款高度，放到tableview的footview中
#define KQPAYSUBVIEW_LABEL_TAG                  1199                        //label起始tag
#define KQPAYACTIVITYSUBVIEW_LABEL_TAG          1198                        //label起始tag
#define KQPAYPASSWORD_GRID_START_Y_POS          15              //密码输入框从底部view的这个y坐标开始
#define KQPAYPASSWORD_GRID_START_X_POS          15              //密码输入框从底部view的这个x坐标开始
#define KQPAY_MORE_VOUCHER_FOOTER_HEIGHT        65              //更多的优惠券footerView高度

#define RIGHT_INFO_BLACK_STYLE  ([UIColor blackColor])
#define RIGHT_INFO_GRAY_STYLE   (UIColorFromRGB(149, 149, 149))
#define RIGHT_INFO_RED_STYLE   (UIColorFromRGB(245, 77, 79))

#import <UIKit/UIKit.h>
#import "KQBasePayView.h"
#import "KQPayViewStepDelegate.h"

@interface KQBasePayHalfView : KQBasePayView

@property (nonatomic, strong, readonly, nonnull) UIView *mainView;

- (instancetype __nullable)initWithTitle:(NSString* __nonnull)title;

- (instancetype __nullable)initWithTitle:(NSString* __nonnull)title isShowSmsPrompt:(BOOL)isShowSmsPrompt;

- (void)closeBtnImage:(KQBaseCloseImageType)closeImageType;

- (void)titleImage:(UIImage* __nullable)image;

- (void)titleText:(NSString* __nullable)text;

- (void)fingerLoading:(KQPayDetailLoadingType)loadingType;

- (void)passwordOrSmsLoading:(KQPayDetailLoadingType)loadingType;

@end
