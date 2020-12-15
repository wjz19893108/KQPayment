//
//  KQPayResultView.h
//  kuaiQianbao
//
//  Created by zouf on 16/1/4.
//
//


typedef NS_ENUM(NSInteger, KQPayResultSubTextPos)
{
    KQPayResultSubTextPosTop,
    KQPayResultSubTextPosCenter,
    KQPayResultSubTextPosBottom
};

//针对B扫C免密情况下，直接弹出结果页面，而增加的按钮响应
typedef void(^PayClosed)(BOOL);
typedef void(^PayAgain)(void);


#import <UIKit/UIKit.h>
#import "KQBasePayView.h"


@interface KQPayResultLabelName : NSObject

@property (nonatomic, copy, nonnull) NSString *payResultName;               //"支付成功"
@property (nonatomic, copy, nonnull) NSString *paymentName;                 //"成功付款多少元"
@property (nonatomic, copy, nonnull) NSString *payMethodName;               //"付款方式"

@end

@interface KQPayResultSubView : UIView

- (instancetype __nullable)initWithTitle:(NSString* __nullable)title position:(KQPayResultSubTextPos)pos;       //左边的标题
- (void)setContentText:(NSString* __nullable)contentText;                   //右边的内容
- (void)addSeparationView;
- (void)labelRightTextColor:(UIColor* __nonnull)color;
- (void)labelLeftText:(NSString * __nonnull)text;

@end

@interface KQPayResultView : KQBasePayView

@property (nonatomic, strong, nonnull) KQPayResultInfo *payResultInfo;
@property (nonatomic, copy, nullable) PayClosed payClosedBlock;
@property (nonatomic, copy, nullable) PayAgain payAgainBlock;
@property (nonatomic, strong, nonnull) KQPayResultLabelName *payResultName;

- (instancetype __nullable)init;

// =是否为ApplePay支付
@property (nonatomic, assign) BOOL isApplePay;

//单独使用该页面的情况下，用这个初始化，不显示标题
- (instancetype __nullable)initWithoutTitleBar;

- (void)setPayResultInfo:(KQPayResultInfo * _Nonnull)payResultInfo;
- (void)setPayResultName:(KQPayResultLabelName * _Nonnull)payResultName;

//resetBanner
- (void)resetBanner;

@end
