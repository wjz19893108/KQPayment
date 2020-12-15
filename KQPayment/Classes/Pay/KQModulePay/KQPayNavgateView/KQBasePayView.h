//
//  KQBasePayView.h
//  kuaiQianbao
//
//  Created by zouf on 16/1/18.
//
//

#import <UIKit/UIKit.h>
//#import "KQPaymentManager.h"
#import "KQPayOrderData.h"
#import "KQPayViewStepDelegate.h"


@interface KQBasePayView : UIView

@property (nonatomic, assign) KQPayViewStep payViewStep;

/*
 界面上要取数据都通过这个delegate
 */
@property (nonatomic, weak) id delegate;

/*
 用于子类继承，view显示后调用
 */
- (void)viewDidShow;

/*
 用于子类继承，关闭view事件
 */
-(void)closeView:(id)sender;

/*
 用于子类继承，在调用关闭view前做一些操作
 */
- (void)willInvokeCloseBlock;

/*
 当弹出键盘时，需要移动view的size
 */
- (CGSize)getMoveSizeWhenKeyboardShow:(CGSize)keyboardSize;

@end
