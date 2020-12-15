//
//  KQPaySmsNavigateView.m
//  kuaiQianbao
//
//  Created by zouf on 16/2/1.
//
//

#import "KQPaySmsNavigateView.h"
#import "KQPayStatisticsMacro.h"

@interface KQPaySmsNavigateView () <KQBaseTextFieldDelegate, KQPayDetailLoadingTypeDelegate>

@property (nonatomic, strong) UIView *paySmsView;                   //总体上的View，其他的Views都加在这上面
@property (nonatomic, strong) KQBaseTextField *verificationCodeTF;  //验证码输入框
@property (nonatomic, strong) UIButton *sendButton;                 //获取验证码按钮
@property (nonatomic, strong) UIButton *confirmBtn;                 //确认按钮按钮
@property (nonatomic, assign) BOOL hasGetSms;
@property (nonatomic, assign) BOOL hasSendSms;

@end

@implementation KQPaySmsNavigateView

- (instancetype __nullable)init
{
    self = [super initWithTitle:@"请输入短信验证码"];
    if (self) {
        CGFloat mainViewHeight = self.mainView.height;
        self.paySmsView = [[UIView alloc] initWithFrame:CGRectMake(0, KQPAYSUBVIEW_START_Y_POS, KQC_SCREEN_WIDTH, mainViewHeight - KQPAYSUBVIEW_START_Y_POS)];
        [self.mainView addSubview:self.paySmsView];
        
        self.verificationCodeTF = [[KQBaseTextField alloc] initWithFrame:CGRectZero];
        self.verificationCodeTF.placeholder = @"验证码";
        self.verificationCodeTF.keyboardType = UIKeyboardTypeNumberPad;
        self.verificationCodeTF.textColor = [KQBColor colorWithType:KQBColorTypeTextFieldMajor];
        self.verificationCodeTF.font = [KQBFont fontWithType:KQBFontTypeTextFieldMajor];
        [self.verificationCodeTF setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self.verificationCodeTF keyborderSytleSet:KQKeyboardStyleNormal];
        [self.verificationCodeTF setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self.verificationCodeTF setMaxLength:6];
        [self.verificationCodeTF setKqTextfieldDelegate:self];
        [self.paySmsView addSubview:self.verificationCodeTF];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sendButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.sendButton setBackgroundImage:[UIImage kqc_imageWithColor:[KQBColor colorWithType:KQBColorTypeButtonDisabled] size:CGSizeMake(1, 1)]  forState:UIControlStateDisabled];
        [self.sendButton setBackgroundImage:[UIImage kqc_imageWithColor:[KQBColor colorWithType:KQBColorTypeNavigationBarTint] size:CGSizeMake(1, 1)]  forState:UIControlStateNormal];
        [self.sendButton setBackgroundImage:[UIImage kqc_imageWithColor:UIColorFromRGB(196, 62, 63) size:CGSizeMake(1, 1)]  forState:UIControlStateHighlighted];
        self.sendButton.titleLabel.font = [KQBFont fontWithType:KQBFontTypeButtonNormal];
        [self.paySmsView addSubview:self.sendButton];
        
        self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom title:@"下一步" frame:CGRectZero target:self action:@selector(confirmClicked) tag:(int)(KQPAYSUBVIEW_LABEL_TAG)];
        self.confirmBtn.enabled = NO;
        [self.paySmsView addSubview:self.confirmBtn];
        
        [KQCStatisticsManager logEvent:KQ_TONGYIZHIFU_YANZHENGMA_XIAYIBU button:self.confirmBtn];
        
        [self.paySmsView addSeperatorLine:CGRectMake(0, KQPAYPASSWORD_GRID_START_Y_POS - 1, self.paySmsView.width, 1)];
        [self.paySmsView addSeperatorLine:CGRectMake(0, (KQPAYPASSWORD_GRID_START_Y_POS + (KQC_SCREEN_WIDTH - KQPAYPASSWORD_GRID_START_X_POS * 2)*38/246), self.paySmsView.width, 1)];
        __weak typeof(self) weakSelf = self;
        [self.verificationCodeTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.paySmsView).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.left.equalTo(weakSelf.paySmsView).with.offset(KQPAYPASSWORD_GRID_START_X_POS);
            make.width.equalTo(@(KQC_SCREEN_WIDTH*3/5 - KQPAYPASSWORD_GRID_START_X_POS));
            make.height.equalTo(@((KQC_SCREEN_WIDTH - KQPAYPASSWORD_GRID_START_X_POS * 2)*38/246));
        }];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.paySmsView).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.left.equalTo(weakSelf.verificationCodeTF.mas_right);
            make.right.equalTo(weakSelf.paySmsView);
            make.height.equalTo(@((KQC_SCREEN_WIDTH - KQPAYPASSWORD_GRID_START_X_POS * 2)*38/246));
        }];
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(weakSelf.paySmsView).with.offset(-30);
            make.centerX.equalTo(weakSelf.paySmsView);
            make.top.equalTo(weakSelf.verificationCodeTF.mas_bottom).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.height.equalTo(@44);
        }];
        
        self.hasGetSms = NO;
        self.hasSendSms = NO;
    }
    return self;
}

#pragma  mark- KQCustomTextFieldDelegate
- (void)addNumber:(KQBaseTextField*)textFiled number:(NSString *)number
{
    [self numberChanged];
}

- (void)deleteNumber:(KQBaseTextField*)textFiled
{
    [self numberChanged];
}

- (void)numberChanged
{
    self.confirmBtn.enabled = (self.verificationCodeTF.text.length == 6);
}

- (void)sendButtonClick
{
    __weak typeof(self) weakSelf = self;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(getPaySms:)]) {
        [self.delegate getPaySms:^{
            weakSelf.hasGetSms = YES;
            __block int timeout = 59; //倒计时时间
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
            dispatch_source_set_event_handler(_timer, ^{
                if(timeout <= 0){ //倒计时结束，关闭
                    dispatch_source_cancel(_timer);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //设置界面的按钮显示 根据自己需求设置
                        [weakSelf.sendButton setTitle:@"重新发送" forState:UIControlStateNormal];
                        weakSelf.sendButton.enabled = YES;
                    });
                }else{
                    NSInteger seconds = timeout % 60;
                    NSString *strTime = [NSString stringWithFormat:@"%.2ld", (long)seconds];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //设置界面的按钮显示 根据自己需求设置
                        [weakSelf.sendButton setTitle:[NSString stringWithFormat:@"%@秒后重新发送", strTime] forState:UIControlStateDisabled];
                        weakSelf.sendButton.enabled = NO;
                    });
                    timeout--;
                }
            });
            dispatch_resume(_timer);
        }];
    }
}

- (void)confirmClicked
{
    if (self.hasGetSms) {
        if (self.verificationCodeTF.text.length != 6) {
            [KQBToastView show:@"请输入正确的验证码"];
        }
        else {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(inputSms:loadingTypeDelegate:)]) {
                [self.delegate inputSms:self.verificationCodeTF.text loadingTypeDelegate:self];
                [self hideKeyboard];
                [self clearAllText];
            }
        }
    }
    else {
        [KQBToastView show:@"您尚未成功获取验证码，请稍后点击重试"];
    }
}

- (void)payDetailLoadingType:(KQPayDetailLoadingType)loadingType {
    [self passwordOrSmsLoading:loadingType];
}

- (void)showKeyboard
{
    [self.verificationCodeTF becomeFirstResponder];
}

- (void)hideKeyboard
{
    [self.verificationCodeTF resignFirstResponder];
}

- (void)viewDidShow {
    [self showKeyboard];
    if (!self.hasSendSms) {
        self.hasSendSms = YES;
        [self sendButtonClick];
    }
}

- (void)willInvokeCloseBlock
{
    [self hideKeyboard];
    [super willInvokeCloseBlock];
}

- (void)clearAllText
{
    [self.verificationCodeTF allTextClear];
    self.verificationCodeTF.text = @"";
    [self numberChanged];
}

@end
