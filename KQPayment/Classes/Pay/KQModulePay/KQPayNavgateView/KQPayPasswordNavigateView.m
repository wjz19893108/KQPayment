//
//  KQPayPasswordNavigateView.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/30.
//  Copyright © 2015年 program. All rights reserved.
//


#import "KQPayPasswordNavigateView.h"
#import "UIImage+KQProcessPay.h"
#import "KQPayStatisticsMacro.h"

@interface KQPayPasswordNavigateView () <KQBaseTextFieldDelegate, KQPayDetailLoadingTypeDelegate>
{
    UIImageView *dotImage[6];
}

@property (nonatomic, strong) UIView *payPasswordView;          //总体上的View，其他的密码输入框，小黑点什么第都加在这上面
@property (nonatomic, strong) UILabel *touchIdLabel;            //指纹支付有问题时，显示这个
@property (nonatomic, strong) UIImageView *payPasswordGrid;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) KQSecureTextField *passcodeTextField;
@property (nonatomic, strong) UIView *placeHolderView;          //用于计算keyboard弹出时，view向上移动多少

@end

@implementation KQPayPasswordNavigateView

- (instancetype __nullable)init
{
    self = [super initWithTitle:@"输入密码"];
    if (self) {
        CGFloat mainViewHeight = self.mainView.height;
        self.payPasswordView = [[UIView alloc] initWithFrame:CGRectMake(0, KQPAYSUBVIEW_START_Y_POS, KQC_SCREEN_WIDTH, mainViewHeight - KQPAYSUBVIEW_START_Y_POS)];
        [self.mainView addSubview:self.payPasswordView];
        
        self.touchIdLabel = [UILabel addLabel:@"" frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentLeft textColor:UIColorFromRGB(149, 149, 149) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self.payPasswordView];
        [self.touchIdLabel sizeToFit];
        self.touchIdLabel.numberOfLines = 0;
        self.touchIdLabel.hidden = YES;

        self.payPasswordGrid = [[UIImageView alloc] initWithImage:[UIImage kqppay_imageNamed:@"box_password"]];
        [self.payPasswordView addSubview:self.payPasswordGrid];
        
        __weak typeof(self) weakSelf = self;
        [self.payPasswordGrid mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(weakSelf.payPasswordView).with.offset(KQPAYPASSWORD_GRID_START_X_POS);
            make.right.equalTo(weakSelf.payPasswordView).with.offset(-KQPAYPASSWORD_GRID_START_X_POS);
            make.top.equalTo(weakSelf.touchIdLabel.mas_bottom).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.height.mas_equalTo(@((KQC_SCREEN_WIDTH - KQPAYPASSWORD_GRID_START_X_POS * 2)*38/246));
        }];
        
        for (int i = 0; i < 6; i++) {
            UIView *dotView = [[UIView alloc] init];
            [self.payPasswordView addSubview:dotView];
            CGFloat dotViewWidth = (KQC_SCREEN_WIDTH - KQPAYPASSWORD_GRID_START_X_POS * 2)/6;
            CGFloat dotViewHeight = (KQC_SCREEN_WIDTH - KQPAYPASSWORD_GRID_START_X_POS * 2)*38/246;
            [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(@(dotViewWidth));
                make.height.mas_equalTo(@(dotViewHeight));
                make.top.equalTo(weakSelf.payPasswordGrid.mas_top);
                make.left.equalTo(weakSelf.payPasswordGrid.mas_left).with.offset(dotViewWidth*i);
            }];

            dotImage[i] = [[UIImageView alloc] initWithImage:[UIImage kqppay_imageNamed:@"passworddot"]];
            [dotView addSubview:dotImage[i]];
            [dotImage[i] setHidden:YES];
            [dotImage[i] mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(@(13));
                make.height.mas_equalTo(@(13));
                make.centerX.equalTo(dotView);
                make.centerY.equalTo(dotView);
            }];
        }
        
        UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom
                                              title:@"忘记密码？"
                                              frame:CGRectMake(0, 0, 0, 0)
                                              image:nil
                                        tappedImage:nil
                                       disableImage:nil
                                             target:self
                                             action:@selector(forgetPWClicked)
                                                tag:0];
        [forgetBtn setTitleColor:UIColorFromRGB(41,139,235) forState:UIControlStateNormal];
        [forgetBtn.titleLabel setFont:[KQBFont fontWithType:12]];
        forgetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.mainView addSubview:forgetBtn];
        
        [forgetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf).with.offset(-8);
            make.top.equalTo(weakSelf.payPasswordGrid.mas_bottom).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.height.equalTo(@30);
        }];

        self.placeHolderView = [[UIView alloc] init];
        self.placeHolderView.backgroundColor = [UIColor clearColor];
        [self.mainView addSubview:self.placeHolderView];
        [self.placeHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.payPasswordView);
            make.right.equalTo(weakSelf.payPasswordView);
            make.top.equalTo(forgetBtn.mas_bottom).with.offset(10);
            make.bottom.equalTo(weakSelf.payPasswordView);
        }];
        
        self.passcodeTextField = [[KQSecureTextField alloc] initWithFrame:self.mainView.frame];
        self.passcodeTextField.hidden = YES;
        self.passcodeTextField.maxLength = 6;
        self.passcodeTextField.kqTextfieldDelegate =self;
        [self.mainView addSubview:self.passcodeTextField];
        [self.passcodeTextField keyborderSytleSet:KQKeyboardStylePayPassword];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reveiveTimeOutOfRangeNotication:) name:KQCDeviceTimeOutOfRangeNotification object:nil];
    }
    return self;
}

- (void)setTouchIdInfo:(NSString *)touchIdInfo
{
    _touchIdInfo = touchIdInfo;
    self.touchIdLabel.text = touchIdInfo;
    if (![NSString kqc_isBlank:touchIdInfo]) {
        self.touchIdLabel.hidden = NO;
        __weak typeof(self) weakSelf = self;
        [self.touchIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.payPasswordView).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.centerX.equalTo(weakSelf.payPasswordView);
            make.width.lessThanOrEqualTo(@(KQC_SCREEN_WIDTH - KQPAYPASSWORD_GRID_START_X_POS*2));
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //防止点击其他地方让键盘收起来
    [self showKeyboard];
}

- (void)showKeyboard
{
    [self.passcodeTextField becomeFirstResponder];
}

- (void)hideKeyboard
{
    [self.passcodeTextField resignFirstResponder];
}

- (void)viewDidShow {
    [self showKeyboard];
}

- (void)willInvokeCloseBlock
{
    [self hideKeyboard];
    [super willInvokeCloseBlock];
}

#pragma  mark- KQCustomTextFieldDelegate
-(void)addNumber:(KQBaseTextField*)textFiled number:(NSString *)number
{
    [self numberChanged];
}

-(void)deleteNumber:(KQBaseTextField*)textFiled
{
    [self numberChanged];
}

- (void)numberChanged
{
    for (int i = 0; i < 6; i++) {
        dotImage[i].hidden = (i >= [self.passcodeTextField.text length]);
    }
    if (([self.passcodeTextField.text length] == 6)) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(inputPayPassword:loadingTypeDelegate:)]) {
            [KQCStatisticsManager logEvent:KQ_TONGYIZHIFU_ZHIFUMIMA_QUEDING];
            [self hideKeyboard];
            [self.delegate inputPayPassword:self.passcodeTextField.cipherText loadingTypeDelegate:self];
            [self clearAllText];
        }
    }
}

- (void)payDetailLoadingType:(KQPayDetailLoadingType)loadingType {
    [self passwordOrSmsLoading:loadingType];
}

// 忘记密码
- (void)forgetPWClicked{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(forgetPayPassword)]) {
        [self.delegate forgetPayPassword];
    }
}

- (void)clearAllText
{
    [self.passcodeTextField allTextClear];
    [self numberChanged];
}

- (CGSize)getMoveSizeWhenKeyboardShow:(CGSize)keyboardSize{
    if (self.placeHolderView.frame.size.height == 0) {
        //App-7358无法复现，预估是高度为0的情况
        return CGSizeZero;
    }
    if (keyboardSize.height > self.placeHolderView.frame.size.height) {
        return CGSizeMake(keyboardSize.width, keyboardSize.height - self.placeHolderView.frame.size.height);
    }
    return CGSizeZero;
}

- (void)reveiveTimeOutOfRangeNotication:(NSNotification *)notification{
    [self clearAllText];
    [self showKeyboard];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
