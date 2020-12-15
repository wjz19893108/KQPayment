//
//  KQPayCVV2NavigateView.m
//  kuaiQianbao
//
//  Created by zouf on 16/6/30.
//
//

#import "KQPayCVV2NavigateView.h"
#import "UIImage+KQProcessPay.h"


@interface KQPayCVV2NavigateView () <KQBaseTextFieldDelegate>

@property (nonatomic, strong) UIView *payCvv2View;                  //总体上的View，其他的Views都加在这上面
@property (nonatomic, strong) KQBaseTextField *cvv2CodeTF;          //cvv2输入框
@property (nonatomic, strong) UIButton *confirmBtn;                 //确认按钮
@property (nonatomic, strong) UIView *placeHolderView;              //用于计算keyboard弹出时，view向上移动多少

@end

@implementation KQPayCVV2NavigateView

- (instancetype __nullable)init {
    self = [super initWithTitle:@"CVV2码错误，请重新输入"];
    if (self) {
        CGFloat mainViewHeight = self.mainView.height;
        self.payCvv2View = [[UIView alloc] initWithFrame:CGRectMake(0, KQPAYSUBVIEW_START_Y_POS, KQC_SCREEN_WIDTH, mainViewHeight - KQPAYSUBVIEW_START_Y_POS)];
        [self.mainView addSubview:self.payCvv2View];
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor clearColor];
        backView.layer.borderWidth = 1;
        backView.layer.borderColor = [[KQBColor colorWithType:KQBColorTypeSeperator] CGColor];
        [self.payCvv2View addSubview:backView];
        
        self.cvv2CodeTF = [[KQBaseTextField alloc] initWithFrame:CGRectZero];
        self.cvv2CodeTF.placeholder = @"";
        self.cvv2CodeTF.keyboardType = UIKeyboardTypeNumberPad;
        self.cvv2CodeTF.textColor = [KQBColor colorWithType:KQBColorTypeTextFieldMajor];
        self.cvv2CodeTF.font = [KQBFont fontWithType:KQBFontTypeTextFieldMajor];
        [self.cvv2CodeTF setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [self.cvv2CodeTF keyborderSytleSet:KQKeyboardStyleNormal];
        [self.cvv2CodeTF setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self.cvv2CodeTF setMaxLength:3];
        [self.cvv2CodeTF setKqTextfieldDelegate:self];
        [backView addSubview:self.cvv2CodeTF];
        
        UIImage *cvv2image = [UIImage kqppay_imageNamed:@"ic_cvv"];
        UIImageView *cvv2ImageView = [[UIImageView alloc] init];
        [cvv2ImageView setImage:cvv2image];
        [backView addSubview:cvv2ImageView];
        cvv2ImageView.backgroundColor = [UIColor clearColor];
        
        __weak typeof(self) weakSelf = self;
        [backView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(weakSelf.payCvv2View).with.offset(KQPAYPASSWORD_GRID_START_X_POS);
            make.right.equalTo(weakSelf.payCvv2View).with.offset(-KQPAYPASSWORD_GRID_START_X_POS);
            make.top.equalTo(weakSelf.payCvv2View).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.height.mas_equalTo(@((KQC_SCREEN_WIDTH - KQPAYPASSWORD_GRID_START_X_POS * 2)*38/246));
        }];
        [self.cvv2CodeTF mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(backView).with.offset(KQPAYPASSWORD_GRID_START_X_POS);
            make.right.equalTo(cvv2ImageView.mas_left);
            make.top.equalTo(backView);
            make.bottom.equalTo(backView);
        }];
        [cvv2ImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(backView).with.offset(-12);
            make.width.equalTo(@86);
            make.top.equalTo(backView).with.offset(12);
            make.bottom.equalTo(backView).with.offset(-12);
        }];
        
        UILabel *infoLabel = [UILabel labelWithFrame:CGRectZero text:@"卡背面签名栏后三位数字" textColor:UIColorFromRGB(149, 149, 149) font:[KQBFont fontWithType:KQBFontTypeTextFieldDetail] tag:(int)KQPAYSUBVIEW_LABEL_TAG hasShadow:NO textAlignment:NSTextAlignmentCenter];
        [self.payCvv2View addSubview:infoLabel];
        [infoLabel sizeToFit];
        [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.cvv2CodeTF.mas_bottom).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.centerX.equalTo(weakSelf.payCvv2View);
        }];
        
        UIButton *cancelBtn = [KQSecondaryButton secondaryButtonWithType:UIButtonTypeCustom title:@"取消" frame:CGRectZero target:self action:@selector(cancelClicked) tag:0];
        [self.mainView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.payCvv2View).with.offset(KQPAYPASSWORD_GRID_START_X_POS);
            make.right.equalTo(weakSelf.payCvv2View.mas_centerX).with.offset(-8);
            make.top.equalTo(infoLabel.mas_bottom).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.height.equalTo(@44);
        }];
        
        self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom title:@"确定" frame:CGRectZero target:self action:@selector(confirmClicked) tag:0];
        [self.mainView addSubview:self.confirmBtn];
        self.confirmBtn.enabled = NO;
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.payCvv2View.mas_centerX).with.offset(8);
            make.right.equalTo(weakSelf.payCvv2View).with.offset(-KQPAYPASSWORD_GRID_START_X_POS);
            make.top.equalTo(infoLabel.mas_bottom).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.height.equalTo(@44);
        }];
        
        self.placeHolderView = [[UIView alloc] init];
        self.placeHolderView.backgroundColor = [UIColor clearColor];
        [self.mainView addSubview:self.placeHolderView];
        [self.placeHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.payCvv2View);
            make.right.equalTo(weakSelf.payCvv2View);
            make.top.equalTo(weakSelf.confirmBtn.mas_bottom).with.offset(10);
            make.bottom.equalTo(weakSelf.payCvv2View);
        }];
    }
    return self;
}

- (void)showKeyboard
{
    [self.cvv2CodeTF becomeFirstResponder];
}

- (void)hideKeyboard
{
    [self.cvv2CodeTF resignFirstResponder];
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
    self.confirmBtn.enabled = (self.cvv2CodeTF.text.length == 3);
}

- (void)cancelClicked
{
    [self willInvokeCloseBlock];
}

- (void)confirmClicked
{
    if ([self.cvv2CodeTF.text length] == 3) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(inputCvv2:)]) {
            [self.delegate inputCvv2:self.cvv2CodeTF.text];
            [self hideKeyboard];
        }
    }
}

- (CGSize)getMoveSizeWhenKeyboardShow:(CGSize)keyboardSize{
    if (self.placeHolderView.frame.size.height == 0) {
        //按照App-7358的描述，这里应该也有问题
        return CGSizeZero;
    }
    if (keyboardSize.height > self.placeHolderView.frame.size.height) {
        return CGSizeMake(keyboardSize.width, keyboardSize.height - self.placeHolderView.frame.size.height);
    }
    return CGSizeZero;
}

@end
