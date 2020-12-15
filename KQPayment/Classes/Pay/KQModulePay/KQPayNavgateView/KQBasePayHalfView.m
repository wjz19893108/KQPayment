//
//  KQBasePayHalfView.m
//  kuaiQianbao
//
//  Created by zouf on 15-11-26
//
//

#import "KQBasePayHalfView.h"
#import "UIImage+KQProcessPay.h"

@interface KQBasePayHalfView()

@property (nonatomic, strong, readwrite) UIView *mainView;
@property (nonatomic, strong) UIView *backGroudView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *smsTitleLabel;
@property (nonatomic, strong) UIView *fingerLoadingView;
@property (nonatomic, strong) UIView *fingerLoadingActionView;
@property (nonatomic, strong) UILabel *fingerLoadingLabel;
@property (nonatomic, strong) UIView *passwordOrSmsLoadingView;
@property (nonatomic, strong) UIView *passwordOrSmsLoadingActionView;
@property (nonatomic, strong) UILabel *passwordOrSmsLoadingLabel;

@end

@implementation KQBasePayHalfView

-(instancetype __nullable)initWithTitle:(NSString* __nonnull)title
{
    return [self initWithTitle:title isShowSmsPrompt:NO];
}

- (instancetype __nullable)initWithTitle:(NSString* __nonnull)title isShowSmsPrompt:(BOOL)isShowSmsPrompt{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        //创建背景蒙版
        self.backGroudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.backGroudView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backGroudView];
        
        //iPhone6/6p在高度上有一个余量
        CGFloat heightMargin = ((KQC_SCREEN_HEIGHT - 568) > 0)?(KQC_SCREEN_HEIGHT*0.1):0;
        CGRect mainRect = CGRectMake(0, KQC_SCREEN_HEIGHT - KQBASE_NAVIGATE_VIEW_HEIGHT - heightMargin, KQC_SCREEN_WIDTH, KQBASE_NAVIGATE_VIEW_HEIGHT + heightMargin);
        //创建主View
        self.mainView = [[UIView alloc] initWithFrame:mainRect];
        self.mainView.backgroundColor = UIColorFromRGB(248, 248, 248);
        [self addSubview:self.mainView];
        
        //标题部分
        self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQBASE_NAVIGATE_TITLE_HEIGHT)];
        [self.mainView addSubview:self.titleView];
        self.titleLabel = [UILabel addLabel:title frame:CGRectZero size:17 isBold:YES textAlignment:NSTextAlignmentCenter textColor:[KQBColor colorWithType:KQBColorTypeTextFieldMajor] tag:0 intoView:self.titleView];
        [self.titleLabel sizeToFit];
        
        if (isShowSmsPrompt) {
            NSString *starPhone = nil;
            if (KQB_Manager_UserInfo.userInfo.phoneNo.length == 11) {
                starPhone = KQC_FORMAT(@"已向您%@****%@发送", [KQB_Manager_UserInfo.userInfo.phoneNo substringToIndex:3], [KQB_Manager_UserInfo.userInfo.phoneNo substringFromIndex:7]);
            } else {
                starPhone = @"已向您发送";
            }
            
            self.smsTitleLabel = [UILabel addLabel:starPhone frame:CGRectZero size:12 isBold:YES textAlignment:NSTextAlignmentCenter textColor:[KQBColor colorWithType:KQBColorTypeTextFieldInfo] tag:0 intoView:self.titleView];
            [self.smsTitleLabel sizeToFit];
            
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.centerX.equalTo(self.titleView).with.offset(0);
                make.top.equalTo(self.titleView).offset(5);
            }];
            
            [self.smsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.centerX.equalTo(self.titleView).with.offset(0);
                make.top.equalTo(self.titleView).offset(30);
            }];
        } else {
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.centerX.equalTo(self.titleView).with.offset(0);
                make.centerY.equalTo(self.titleView);
            }];
        }

        //标题分隔线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, KQBASE_NAVIGATE_TITLE_HEIGHT, KQC_SCREEN_WIDTH, KQBASE_NAVIGATE_SEPARATOR_HEIGHT)];
        lineView.backgroundColor = UIColorFromRGB(195, 195, 195);
        [self.mainView addSubview:lineView];
        
        //关闭按钮
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom//btn
                                                title:nil
                                                frame:CGRectMake(0, 0, KQBASE_NAVIGATE_TITLE_HEIGHT, KQBASE_NAVIGATE_TITLE_HEIGHT)
                                                image:nil
                                          tappedImage:nil
                                         disableImage:nil
                                               target:self
                                               action:@selector(closeView:)
                                                  tag:12];
        self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.closeBtn setEnabled:YES];
        [self.closeBtn setImage:[UIImage kqppay_imageNamed:@"icon_fanhui"] forState:UIControlStateNormal];
        [self.mainView addSubview:self.closeBtn];
        
        //指纹支付loading界面
        self.fingerLoadingView = [[UIView alloc] initWithFrame:self.mainView.frame];
        self.fingerLoadingView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.fingerLoadingView];
        self.fingerLoadingView.hidden = YES;
        
        UIView *confirmView = [[UIView alloc] init];
        confirmView.backgroundColor = UIColorFromRGB(0xF5, 0x4D, 0x4F);
        [[confirmView layer] setCornerRadius:5.0f];
        [self.fingerLoadingView addSubview:confirmView];
        [confirmView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mainView).with.offset(15);
            make.right.equalTo(self.mainView).with.offset(-15);
            make.bottom.equalTo(self.mainView).with.offset(-30);
            make.height.equalTo(@44);
        }];
        
        UIView *fingerHelper = [[UIView alloc] init];
        fingerHelper.backgroundColor = [UIColor clearColor];
        [confirmView addSubview:fingerHelper];
        
        [fingerHelper mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(confirmView);
        }];
        
        self.fingerLoadingActionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
        self.fingerLoadingActionView.backgroundColor = [UIColor clearColor];
        [confirmView addSubview:self.fingerLoadingActionView];
        [self.fingerLoadingActionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@17);
            make.height.equalTo(@17);
            make.centerY.equalTo(confirmView);
            make.left.equalTo(fingerHelper);
        }];
        
        self.fingerLoadingLabel = [UILabel addLabel:@"" frame:CGRectZero size:16 isBold:NO textAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] tag:0 intoView:confirmView];
        [self.fingerLoadingLabel sizeToFit];
        [self.fingerLoadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.fingerLoadingActionView.mas_right).with.offset(4);
            make.right.equalTo(fingerHelper);
            make.centerY.equalTo(confirmView);
        }];
        
        //密码和验证码支付loading
        self.passwordOrSmsLoadingView = [[UIView alloc] initWithFrame:self.mainView.frame];
        self.passwordOrSmsLoadingView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.passwordOrSmsLoadingView];
        self.passwordOrSmsLoadingView.hidden = YES;
        
        UIView *passwordOrSmsView = [[UIView alloc] init];
        passwordOrSmsView.backgroundColor = UIColorFromRGB(248, 248, 248);
        [self.passwordOrSmsLoadingView addSubview:passwordOrSmsView];
        [passwordOrSmsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mainView);
            make.right.equalTo(self.mainView);
            make.top.equalTo(self.mainView).with.offset(KQPAYSUBVIEW_START_Y_POS);
            make.bottom.equalTo(self.mainView);
        }];
        
        self.passwordOrSmsLoadingActionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
        self.passwordOrSmsLoadingActionView.backgroundColor = [UIColor clearColor];
        [passwordOrSmsView addSubview:self.passwordOrSmsLoadingActionView];
        [self.passwordOrSmsLoadingActionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@55);
            make.height.equalTo(@55);
            make.centerX.equalTo(passwordOrSmsView);
            make.centerY.equalTo(passwordOrSmsView).with.offset(-80);
        }];
        
        self.passwordOrSmsLoadingLabel = [UILabel addLabel:@"" frame:CGRectZero size:16 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(149, 149, 149) tag:0 intoView:passwordOrSmsView];
        [self.passwordOrSmsLoadingLabel sizeToFit];
        self.passwordOrSmsLoadingLabel.numberOfLines = 0;
        [self.passwordOrSmsLoadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordOrSmsLoadingActionView.mas_bottom).with.offset(15);
            make.centerX.equalTo(passwordOrSmsView);
        }];
    }
    return self;
}

- (void)closeBtnImage:(KQBaseCloseImageType)closeImageType {
    if (closeImageType == KQBaseCloseImageClose) {
        [self.closeBtn setImage:[UIImage kqppay_imageNamed:@"icon_guanbi"] forState:UIControlStateNormal];
    }
    else{
        [self.closeBtn setImage:[UIImage kqppay_imageNamed:@"icon_fanhui"] forState:UIControlStateNormal];
    }
}

- (void)titleImage:(UIImage* __nullable)image {
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.titleView).with.offset(image?8:0);
    }];
    [self.smsTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.titleView).with.offset(image?8:0);
    }];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [[imageView layer] setCornerRadius:4];//圆角
        [imageView.layer setMasksToBounds:YES];
        
        [self.titleView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.mas_equalTo(self.titleLabel.mas_left).with.offset(-5);
            make.width.mas_equalTo(@20);
            make.height.mas_equalTo(@20);
            make.centerY.equalTo(self.titleView);
        }];
    }
}

- (void)titleText:(NSString* __nullable)text {
    [self.titleLabel setText:text];
}

- (void)fingerLoading:(KQPayDetailLoadingType)loadingType {
    if (loadingType == KQPayDetailLoadingTypeStart) {
        [LoadingViewManager startLoading:self.fingerLoadingActionView lineColor:[UIColor whiteColor]];
        [self.fingerLoadingLabel setText:BiometryPaymentDealingInfo];
        self.fingerLoadingView.hidden = NO;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])    //禁止交互
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    } else if (loadingType == KQPayDetailLoadingTypeSuccess) {
        [LoadingViewManager successLoading:self.fingerLoadingActionView lineColor:[UIColor whiteColor]];
        [self.fingerLoadingLabel setText:@"支付成功"];
        self.fingerLoadingView.hidden = NO;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])    //禁止交互
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    } else if (loadingType == KQPayDetailLoadingTypeFailed) {
        [LoadingViewManager failLoading:self.fingerLoadingActionView lineColor:[UIColor whiteColor]];
        [self.fingerLoadingLabel setText:@"支付失败"];
        self.fingerLoadingView.hidden = NO;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])    //禁止交互
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    } else if (loadingType == KQPayDetailLoadingTypeClose) {
        self.fingerLoadingView.hidden = YES;
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];   //启用交互
    }
}

- (void)passwordOrSmsLoading:(KQPayDetailLoadingType)loadingType {
    if (loadingType == KQPayDetailLoadingTypeStart) {
        [LoadingViewManager startLoading:self.passwordOrSmsLoadingActionView lineColor:UIColorFromRGB(41, 139, 235)];
        [self.passwordOrSmsLoadingLabel setText:@"订单正在支付\n请稍后..."];
        self.passwordOrSmsLoadingView.hidden = NO;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])    //禁止交互
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    } else if (loadingType == KQPayDetailLoadingTypeSuccess) {
        [LoadingViewManager successLoading:self.passwordOrSmsLoadingActionView lineColor:UIColorFromRGB(41, 139, 235)];
        [self.passwordOrSmsLoadingLabel setText:@"支付成功"];
        self.passwordOrSmsLoadingView.hidden = NO;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])    //禁止交互
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    } else if (loadingType == KQPayDetailLoadingTypeFailed) {
        [LoadingViewManager failLoading:self.passwordOrSmsLoadingActionView lineColor:UIColorFromRGB(41, 139, 235)];
        [self.passwordOrSmsLoadingLabel setText:@"支付失败"];
        self.passwordOrSmsLoadingView.hidden = NO;
        if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])    //禁止交互
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    } else if (loadingType == KQPayDetailLoadingTypeClose) {
        self.passwordOrSmsLoadingView.hidden = YES;
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];   //启用交互
    }
}

- (void)dealloc
{
    NSLog(@"%@：dealloc", self);
}

@end
