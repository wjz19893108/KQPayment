//
//  KQPaymentInfoBaseVC.m
//  kuaiQianbao
//
//  Created by zouf on 15/12/8.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQPaymentInfoBaseVC.h"
#import "UIImage+KQProcessPay.h"
#import "KQPaymentController.h"

#define KQPAYMENT_INFO_WIDTH            KQC_SCREEN_WIDTH
#define KQPAYMENT_INFO_HEIGHT           KQC_SCREEN_HEIGHT
#define KQPAYMENT_INFO_START_POS        CGRectMake(0, (KQPAYMENT_INFO_HEIGHT - 20)/2 - 108, KQPAYMENT_INFO_WIDTH, 108)
#define KQPAYMENT_INFO_END_POS          CGRectMake(0, 50, KQPAYMENT_INFO_WIDTH, 108)
#define KQPAYMENT_INFO_HEAD_HEIGHT      65
#define KQPAYMENT_INFO_LABEL_TAG        1199        //label起始tag

@interface KQPaymentInfoBaseVC ()

@property (nonatomic, assign) BOOL internalCall;            //第三方调用和App内部调用，背景不同
@property (nonatomic, strong) UIImage *backImage;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UILabel *appName;
@property (nonatomic, strong) UIImageView *userHeadImage;       //头像
@property (nonatomic, strong) UILabel *userRealName;            //实名
@property (nonatomic, assign) NSInteger showTimes;             //第一次viewDidAppear不调delegate
@property (nonatomic, assign) NSInteger tapTimes;              //空白页点击次数

@end

/*
 显示顺序
 1.应用名称“快钱刷”，在顶部，水平居中
 2.中部创建UIView
 3.用户头像，在UIView上方
 4.用户实名，在UIView下方
 5.创建这个View向上移动的动画
 */
@implementation KQPaymentInfoBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    self.showTimes = 0;
    self.tapTimes = 0;
    [self changeBackGround:self.internalCall];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)imageTapped:(UIGestureRecognizer *)gesture{
    if (self.tapTimes > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(KQPaymentInfoBaseVCTaped)]) {
            [self.delegate KQPaymentInfoBaseVCTaped];
        } else {
            [KQC_Engine_UI popViewControllerWithAnimated:NO];
        }
    }
    self.tapTimes++;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.showTimes > 0 && !self.isBackFromHelp) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(KQPaymentInfoBaseVCDidShow)]) {
            [self.delegate KQPaymentInfoBaseVCDidShow];
        }
    }
    self.isBackFromHelp = NO;
    self.showTimes++;
}

- (void)changeBackGround:(BOOL)internalCall {
    [self.backImageView removeFromSuperview];
    [self.appName removeFromSuperview];
    [self.backGroundView removeFromSuperview];
    self.internalCall = internalCall;
    if (self.internalCall) {
        [self inAppBackGround];
    } else {
        [self outAppBackGround];
    }
}

- (void)inAppBackGround {
    self.view.backgroundColor = [UIColor clearColor];
    self.backImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.backImageView.image = self.backImage;
    self.backImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.backImageView addGestureRecognizer:gesture];
    [self.view addSubview:self.backImageView];
}

- (void)outAppBackGround {
    self.view.backgroundColor = [UIColor clearColor];
    self.backImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.backImageView.backgroundColor = UIColorFromRGB(4, 69, 100);
    self.backImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.backImageView addGestureRecognizer:gesture];
    [self.view addSubview:self.backImageView];
    self.backGroundView = [[UIView alloc] initWithFrame:KQPAYMENT_INFO_END_POS];
    self.backGroundView.backgroundColor = [UIColor clearColor];
    [self.backImageView addSubview:self.backGroundView];
    
    self.appName = [UILabel addLabel:@"快钱刷" frame:CGRectZero size:16 isBold:YES textAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] tag:KQPAYMENT_INFO_LABEL_TAG intoView:self.view];
    [self.appName sizeToFit];
    
    self.userHeadImage = [[UIImageView alloc] initWithImage:[UIImage kqppay_imageNamed:@"default_head"]];
    self.userHeadImage.frame = CGRectMake(0, 0, KQPAYMENT_INFO_HEAD_HEIGHT, KQPAYMENT_INFO_HEAD_HEIGHT);
    self.userHeadImage.layer.masksToBounds = YES;                           //圆形
    self.userHeadImage.layer.cornerRadius = KQPAYMENT_INFO_HEAD_HEIGHT/2.0; //圆形
    [self.backGroundView addSubview:self.userHeadImage];
    
    self.userRealName = [UILabel addLabel:KQB_CurrentUser.userName frame:CGRectZero size:15 isBold:YES textAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] tag:KQPAYMENT_INFO_LABEL_TAG intoView:self.backGroundView];
    [self.userRealName sizeToFit];
    
    __weak typeof(&*self) weakSelf = self;
    //在iPhone6/6p的间距不同
    CGFloat heightMargin = ((KQPAYMENT_INFO_HEIGHT - 568) > 0)?(KQPAYMENT_INFO_HEIGHT*0.01):0;
    [self.appName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).with.offset(25);
    }];
    [self.userHeadImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.backGroundView).with.offset(heightMargin);
        make.centerX.equalTo(weakSelf.backGroundView);
        make.width.equalTo([NSNumber numberWithInt:KQPAYMENT_INFO_HEAD_HEIGHT]);
        make.height.equalTo([NSNumber numberWithInt:KQPAYMENT_INFO_HEAD_HEIGHT]);
    }];
    [self.userRealName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.backGroundView);
        make.bottom.equalTo(weakSelf.backGroundView).with.offset(-25+heightMargin*2);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%@：dealloc", self);
}

@end
