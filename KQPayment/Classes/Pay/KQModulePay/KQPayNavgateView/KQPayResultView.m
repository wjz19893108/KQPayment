//
//  KQPayResultView.m
//  kuaiQianbao
//
//  Created by zouf on 16/1/4.
//
//

#import "KQPayResultView.h"
#import "KQBasePayHalfView.h"
#import "KQPaySetStatusBarStyle.h"
#import "UIImage+KQProcessPay.h"
#import "KQPayStatisticsMacro.h"
#import "KQPaymentMacro.h"
#import "KQPaymentController.h"


#define BannerViewHeight  (KQC_SCREEN_WIDTH*80/320)
#define ResultDetailLableHeight 26
#define KBankError @"[1005200]"
#define KBankErrorOther @"[1005000]"

@implementation KQPayResultLabelName

@end

//中间的支付信息View
@interface KQPayResultSubView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation KQPayResultSubView

- (instancetype __nullable)initWithTitle:(NSString* __nullable)title position:(KQPayResultSubTextPos)pos
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        __weak typeof(&*self) weakSelf = self;
        
        //左边标题
        self.titleLabel = [UILabel addLabel:title frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentCenter textColor:[UIColor blackColor] tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self];
        [self.titleLabel sizeToFit];
        if (pos == KQPayResultSubTextPosTop) {
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.equalTo(weakSelf).with.offset(1);
                make.left.equalTo(weakSelf).with.offset(15);
            }];
        }
        else if (pos == KQPayResultSubTextPosCenter) {
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.centerY.equalTo(weakSelf);
                make.left.equalTo(weakSelf).with.offset(15);
            }];
        }
        else {
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.bottom.equalTo(weakSelf).with.offset(-1);
                make.left.equalTo(weakSelf).with.offset(15);
            }];
        }
        
        //右边内容
        self.contentLabel = [UILabel addLabel:@"" frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentLeft textColor:UIColorFromRGB(149, 149, 149) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self];
        [self.contentLabel sizeToFit];
        self.contentLabel.numberOfLines = 0;
        if (pos == KQPayResultSubTextPosTop) {
            [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.equalTo(weakSelf).with.offset(1);
                make.right.equalTo(weakSelf).with.offset(-15);
                make.width.lessThanOrEqualTo(@(KQC_SCREEN_WIDTH*2/3));
            }];
        }
        else if (pos == KQPayResultSubTextPosCenter) {
            [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.centerY.equalTo(weakSelf);
                make.right.equalTo(weakSelf).with.offset(-15);
                make.width.lessThanOrEqualTo(@(KQC_SCREEN_WIDTH*2/3));
            }];
        }
        else {
            [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.bottom.equalTo(weakSelf);
                make.right.equalTo(weakSelf).with.offset(-15);
                make.width.lessThanOrEqualTo(@(KQC_SCREEN_WIDTH*2/3));
            }];
        }
    }
    return self;
}

- (void)setContentText:(NSString* __nullable)contentText
{
    self.contentLabel.text = contentText;
}

- (void)addSeparationView
{
    __weak typeof(&*self) weakSelf = self;
    //标题分隔线
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromRGB(235, 235, 235);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).with.offset(15);
        make.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf);
        make.height.equalTo(@1);
    }];
}

- (void)labelRightTextColor:(UIColor*)color
{
    [self.contentLabel setTextColor:color];
}

- (void)labelLeftText:(NSString * __nonnull)text
{
    [self.titleLabel setText:text];
}

@end
//中间的支付信息View

//支付结果整个页面
@interface KQPayResultView ()

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *parentContentView;
@property (nonatomic, strong) KQPaySetStatusBarStyle *statusBarStyle;
@property (nonatomic, weak) UILabel *payFailedLabel;
@property (nonatomic, weak) UILabel *payErrorInfoLabel;
@property (nonatomic, weak) KQPayResultSubView *paymodeview;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, assign) bool bankNumErrorFlag;
@property (nonatomic, strong) UIButton *rightBtn;
@end

@implementation KQPayResultView

- (instancetype __nullable)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initWithTitleBarHeight:64];
    }
    return self;
}

- (instancetype __nullable)initWithoutTitleBar
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initWithTitleBarHeight:0];
    }
    return self;
}

- (void)initWithTitleBarHeight:(NSInteger)height
{
    self.backgroundColor = UIColorFromRGB(242, 242, 242);
    __weak typeof(&*self) weakSelf = self;
    
    //顶部底色
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = UIColorFromRGB(245, 77, 79);
    [self addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf);
        make.height.equalTo(@(height));
    }];
    
    //顶部标题
    UILabel *titleLabel = [UILabel addLabel:@"支付结果" frame:CGRectZero size:17 isBold:YES textAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self.titleView];
    [titleLabel sizeToFit];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.titleView);
        make.bottom.equalTo(self.titleView).with.offset(-10);
    }];
    
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom title:@"完成" frame:CGRectZero target:self action:@selector(rightBtnClick:) tag:(int)KQPAYSUBVIEW_LABEL_TAG];
    [self.rightBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.titleView addSubview:self.rightBtn];
    self.rightBtn.hidden = YES;
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel).offset(3);
        make.width.equalTo(@40);
        make.left.equalTo(@(KQC_SCREEN_WIDTH - 60));
        make.height.equalTo(@15);
    }];
    
//    UIButton *titleLabel = [UILabel addLabel:@"支付结果" frame:CGRectZero size:17 isBold:YES textAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self.titleView];
//    [titleLabel sizeToFit];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.titleView);
        make.bottom.equalTo(self.titleView).with.offset(-10);
    }];
    
    self.statusBarStyle = [[KQPaySetStatusBarStyle alloc] initWithStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)setPayResultInfo:(KQPayResultInfo * _Nonnull)payResultInfo
{
    _payResultInfo = payResultInfo;
    [self.contentView removeFromSuperview];
    
    __weak typeof(&*self) weakSelf = self;
    //在3.5寸手机上显示不全，底部位置最后确定
    self.parentContentView = [[UIScrollView alloc] init];
    self.parentContentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.parentContentView];
    [self.parentContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        make.top.equalTo(self.titleView.mas_bottom);
        make.bottom.equalTo(weakSelf.mas_bottom);
    }];
    //支付结果显示的内容都显示在这个View里面，底部位置最后确定
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.parentContentView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.parentContentView);
        make.width.equalTo(weakSelf.parentContentView);
    }];
    
    NSString *resultImage = @"pic_shibai";          //支付结果图标
    NSString *resultDes = @"支付失败";               //支付结果文字
    NSString *resultInfo = @"您的支付没有成功";       //支付结果描述
    if (payResultInfo.result) {//todo delete
        resultImage = @"ic_right";
        resultDes = @"支付成功";
        resultInfo = [NSString stringWithFormat:@"成功付款%@元", [KQCAmount getDecimalAmount:payResultInfo.payAmount]];
    }
    
    UIView * headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView);
        make.right.equalTo(weakSelf.contentView);
        make.top.equalTo(weakSelf.contentView);
        make.height.equalTo(@184);
    }];
    
    //支付结果图标
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage kqppay_imageNamed:resultImage]];
    [headView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@55);
        make.height.equalTo(@55);
        make.centerX.equalTo(headView);
        make.top.equalTo(headView).with.offset(40);
    }];
    
    //支付结果
    UILabel *payFailedLabel = [UILabel addLabel:[NSString kqc_isBlank:self.payResultName.payResultName]?resultDes:self.payResultName.payResultName frame:CGRectZero size:15 isBold:NO textAlignment:NSTextAlignmentCenter textColor:(payResultInfo.result ? UIColorFromRGB(41,139,234):[UIColor blackColor]) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:headView];
    [payFailedLabel sizeToFit];
    [payFailedLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(headView);
        make.top.equalTo(headView).with.offset(105);
    }];
    self.payFailedLabel = payFailedLabel;
    
    //结果信息
    UILabel *payErrorInfoLabel = [UILabel addLabel:[NSString kqc_isBlank:self.payResultName.paymentName]?resultInfo:self.payResultName.paymentName frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(149, 149, 149) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:headView];
    payErrorInfoLabel.numberOfLines = 2;
    [payErrorInfoLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.equalTo(@233);
        make.centerX.equalTo(headView);
        make.top.equalTo(headView).with.offset(129);
    }];
    self.payErrorInfoLabel = payErrorInfoLabel;
    
    if (self.isApplePay) {
        self.payFailedLabel.hidden = YES;
        
        UIImageView *unionPayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [unionPayImageView setImage:[UIImage imageNamed:@"trade_UnionPay"]];
        [headView addSubview:unionPayImageView];
        
        CGSize size = [self sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:233 mode:NSLineBreakByWordWrapping content:payErrorInfoLabel.text];
        
        [unionPayImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.mas_equalTo([UIImage imageNamed:@"trade_UnionPay"].size.width);
            make.height.mas_equalTo([UIImage imageNamed:@"trade_UnionPay"].size.height);
            make.centerX.equalTo(headView).offset(- size.width/2  - 10);
            make.top.equalTo(headView).with.offset(126);
        }];
        
        [payErrorInfoLabel mas_remakeConstraints:^(MASConstraintMaker *make){
            make.width.equalTo(@233);
            make.centerX.equalTo(headView).offset([UIImage imageNamed:@"trade_UnionPay"].size.width/2 + 5);
            make.top.equalTo(headView).with.offset(129);
        }];
    }
    
    //占位view，支付详情，占位符的底部位置未确定，在所有子view确定后，再update底部位置
    UIView *resultDetailView = [[UIView alloc] init];
    resultDetailView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:resultDetailView];
    [resultDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.contentView);
        make.centerX.equalTo(weakSelf.contentView);
        make.top.equalTo(weakSelf.contentView).with.offset(185);
    }];

    //错误原因，为空或nil就隐藏
    KQPayResultSubView *payerrorinfoview;
    if (!payResultInfo.result) {
        BOOL hidePayerrorinfoview = [NSString kqc_isBlank:payResultInfo.errorInfo];
        payerrorinfoview = [[KQPayResultSubView alloc] initWithTitle:@"失败原因" position:KQPayResultSubTextPosBottom];
        [payerrorinfoview setContentText:payResultInfo.errorInfo];
        [resultDetailView addSubview:payerrorinfoview];
        [payerrorinfoview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf);
            make.right.equalTo(weakSelf);
            make.top.equalTo(resultDetailView.mas_top).with.offset(11);
            make.height.equalTo(hidePayerrorinfoview?@0:@26);
        }];
        if (hidePayerrorinfoview) {
            payerrorinfoview.hidden = YES;
        }
    }
    
    //商户名称
    BOOL hideMerchantNameView = ([NSString kqc_isBlank:payResultInfo.merchantName] || !payResultInfo.result);
    KQPayResultSubView *merchantNameView = [[KQPayResultSubView alloc] initWithTitle:@"商户名称" position:KQPayResultSubTextPosCenter];
    [merchantNameView setContentText:payResultInfo.merchantName];
    [resultDetailView addSubview:merchantNameView];
    [merchantNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        if (payResultInfo.result) {
            make.top.equalTo(resultDetailView.mas_top).with.offset(11.0f);
        }
        else {
            make.top.equalTo(payerrorinfoview.mas_bottom).with.offset(4.0f);
        }
        make.height.equalTo(hideMerchantNameView?@0:@26);
    }];
    merchantNameView.hidden = hideMerchantNameView;
    
    //付款方式
    BOOL hidePayModeView = [NSString kqc_isBlank:payResultInfo.payMethod];
    KQPayResultSubView *paymodeview = [[KQPayResultSubView alloc] initWithTitle:@"付款方式" position:KQPayResultSubTextPosCenter];
    [paymodeview setContentText:payResultInfo.payMethod];
    [resultDetailView addSubview:paymodeview];
    [paymodeview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        if (!hideMerchantNameView) {
            make.top.equalTo(merchantNameView.mas_bottom).with.offset(4.0f);
        }else {
            if (payResultInfo.result) {
                make.top.equalTo(resultDetailView.mas_top).with.offset(11.0f);
            }
            else {
                make.top.equalTo(payerrorinfoview.mas_bottom).with.offset(4.0f);
            }
        }
        make.height.equalTo(hidePayModeView?@0:@26);
    }];
    paymodeview.hidden = hidePayModeView;
    self.paymodeview = paymodeview;
    
    //订单金额，为空或nil就隐藏
    BOOL hidePayorderAmount = ([NSString kqc_isBlank:payResultInfo.orderAmount] || [[KQCAmount getDecimalAmount:payResultInfo.orderAmount] isEqualToString:@"0.00"]);
    KQPayResultSubView *payorderAmount = [[KQPayResultSubView alloc] initWithTitle:@"订单金额(元)" position:KQPayResultSubTextPosCenter];
    [payorderAmount setContentText:[KQCAmount getDecimalAmount:payResultInfo.orderAmount]];
    [resultDetailView addSubview:payorderAmount];
    [payorderAmount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        if (hidePayModeView) {
            make.top.equalTo(merchantNameView.mas_bottom).with.offset(4.0f);
        }else {
            make.top.equalTo(paymodeview.mas_bottom).with.offset(4.0f);
        }
        make.height.equalTo(hidePayorderAmount?@0:@26);
    }];
    payorderAmount.hidden = hidePayorderAmount;
    
    //优惠金额，为空或nil就隐藏
    
    KQPayResultSubView *payvoucherLast = [KQPayResultSubView new];
    BOOL hidePayvoucherView = NO;
    if (payResultInfo.equityInfo.count > 0) {
        for (int i = 0 ; i < payResultInfo.equityInfo.count ; i ++ ) {
            KQPayResultVoucherArr * VoucherArr = payResultInfo.equityInfo[i];
            for (int k = 0 ; k < VoucherArr.payVoucherArr.count ; k ++ ) {
                NSString * title = @"";
                if (k == 0) {
                    title = VoucherArr.payVoucherSource;
                }
                KQPayResultVoucherInfo * VoucherInfo = VoucherArr.payVoucherArr[k];
                KQPayResultSubView *payvoucher = [[KQPayResultSubView alloc] initWithTitle:title position:KQPayResultSubTextPosCenter];
                NSString * ContentTitle = VoucherInfo.payVoucherData;
                [payvoucher setContentText:ContentTitle];
                [payvoucher labelRightTextColor:RIGHT_INFO_RED_STYLE];
                [resultDetailView addSubview:payvoucher];
                [payvoucher mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(weakSelf);
                    make.right.equalTo(weakSelf);
                    if (k == 0 && i == 0) {
                        make.top.equalTo(payorderAmount.mas_bottom).with.offset(4.0f);
                    }else{
                        make.top.equalTo(payvoucherLast.mas_bottom).with.offset(4.0f);
                    }
                    make.height.equalTo(@26);
                }];
                
                CGFloat weidth = [NSString kqc_calcStrSize:VoucherInfo.payVoucherTitle font:[UIFont systemFontOfSize:14.0]].width;
                UILabel * midleLabel = [UILabel addLabel:VoucherInfo.payVoucherTitle frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentLeft textColor:RIGHT_INFO_RED_STYLE tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self];
                midleLabel.textColor = UIColorFromRGB(204, 204, 204);
                [midleLabel sizeToFit];
                midleLabel.numberOfLines = 0;
                [midleLabel mas_makeConstraints:^(MASConstraintMaker *make){
                    make.centerY.equalTo(payvoucher);
                    make.right.equalTo(payvoucher.contentLabel.mas_left);
                    make.width.mas_equalTo(weidth+5);
                }];
                payvoucherLast = payvoucher;
            }
        }
    }else{
        if ([NSString kqc_isBlank:payResultInfo.payVoucherData]) {
            hidePayvoucherView = YES;
        }
        if ([[KQCAmount getDecimalAmount:payResultInfo.payVoucherData] isEqualToString:@"0.00"]) {
            hidePayvoucherView = YES;
        }
        KQPayResultSubView *payvoucher = [[KQPayResultSubView alloc] initWithTitle:@"优惠金额(元)" position:KQPayResultSubTextPosCenter];
        [payvoucher setContentText:[KQCAmount getDecimalAmount:payResultInfo.payVoucherData]];
        [payvoucher labelRightTextColor:RIGHT_INFO_RED_STYLE];
        [resultDetailView addSubview:payvoucher];
        [payvoucher mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf);
            make.right.equalTo(weakSelf);
            make.top.equalTo(payorderAmount.mas_bottom);
            make.height.equalTo(hidePayvoucherView?@0:@26);
        }];
        payvoucherLast = payvoucher;
        
        if (hidePayvoucherView) {
            payvoucher.hidden = YES;
        }
    }
    //付款时间
    BOOL hidePaymentTime = [NSString kqc_isBlank:payResultInfo.txnTimeStart];
    KQPayResultSubView *paymenttimeview = [[KQPayResultSubView alloc] initWithTitle:@"付款时间" position:KQPayResultSubTextPosCenter];
    [paymenttimeview setContentText:payResultInfo.txnTimeStart];
    [resultDetailView addSubview:paymenttimeview];
    [paymenttimeview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        if (!hidePayvoucherView) {
            make.top.equalTo(payvoucherLast.mas_bottom).with.offset(4.0f);
        }else{
            make.top.equalTo(payorderAmount.mas_bottom).with.offset(4.0f);
        }
        
        make.height.equalTo(hidePaymentTime?@0:@26);
    }];
    paymenttimeview.hidden = hidePaymentTime;
    
    //交易单号（内部订单号）
    BOOL hideOrderId = [NSString kqc_isBlank:payResultInfo.orderId];
    KQPayResultSubView *orderIdView = [[KQPayResultSubView alloc] initWithTitle:@"交易单号" position:KQPayResultSubTextPosCenter];
    [orderIdView setContentText:payResultInfo.orderId];
    [resultDetailView addSubview:orderIdView];
    [orderIdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        if ([NSString kqc_isBlank:payResultInfo.txnTimeStart]) {
            if (!hidePayvoucherView) {
                make.top.equalTo(payvoucherLast.mas_bottom).with.offset(4.0f);
            }else{
                make.top.equalTo(payorderAmount.mas_bottom).with.offset(4.0f);
            }
        }else{
            make.top.equalTo(paymenttimeview.mas_bottom).with.offset(4.0f);
        }
        
        make.height.equalTo(hideOrderId?@0:@26);
    }];
    orderIdView.hidden = hideOrderId;
    
    //商户订单号（外部订单号）
    BOOL hideOrigOrderId = [NSString kqc_isBlank:payResultInfo.origOrderId];
    KQPayResultSubView *origOrderIdView = [[KQPayResultSubView alloc] initWithTitle:@"商户订单号" position:KQPayResultSubTextPosCenter];
    [origOrderIdView setContentText:payResultInfo.origOrderId];
    [resultDetailView addSubview:origOrderIdView];
    [origOrderIdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        if (hideOrderId) {
            make.top.equalTo(paymenttimeview.mas_bottom).with.offset(4.0f);
        }else{
            make.top.equalTo(orderIdView.mas_bottom).with.offset(4.0f);
        }
        
        make.height.equalTo(hideOrigOrderId?@0:@26);
    }];
    origOrderIdView.hidden = hideOrigOrderId;
    
    //update底部视图位置
    [resultDetailView mas_updateConstraints:^(MASConstraintMaker *make) {
        BOOL hideDetailView = (payerrorinfoview.hidden && hideMerchantNameView && hidePayModeView && hidePayorderAmount && hidePayvoucherView && hidePaymentTime && hideOrderId && hideOrigOrderId);
        if (hideDetailView) {
            make.height.equalTo(@0);
        }else {
            make.bottom.equalTo(origOrderIdView.mas_bottom).with.offset(14.6f);
        }
    }];
    
    //完成
    if (payResultInfo.result) {
        [KQCStatisticsManager logEvent:KQ_TONGYIZHIFU_ZHIFUCHENGGONG];
        
        UILabel *tipsLabel = nil;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(customDescription)]) {
            NSString *tips = [self.delegate customDescription];
            if (![NSString kqc_isBlank:tips]) {
                tipsLabel = [UILabel addLabel:tips frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentLeft textColor:UIColorFromRGB(149, 149, 149) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
                tipsLabel.numberOfLines = 0;
                [tipsLabel sizeToFit];
                [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make){
                    make.top.equalTo(resultDetailView.mas_bottom).with.offset(15);
                    make.left.equalTo(weakSelf.contentView).with.offset(20);
                    make.width.lessThanOrEqualTo(weakSelf.contentView).with.offset(-40);
                }];
            }
        }

        self.finishBtn = [UIButton buttonWithType:UIButtonTypeCustom title:@"完成" frame:CGRectZero target:self action:@selector(closeView:) tag:(int)KQPAYSUBVIEW_LABEL_TAG];
        [self.contentView addSubview:self.finishBtn];
        [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(weakSelf.contentView).with.offset(-30);
            make.centerX.equalTo(weakSelf.contentView);
            if (tipsLabel) {
                make.top.equalTo(tipsLabel.mas_bottom).with.offset(20);
            }
            else {
                make.top.equalTo(resultDetailView.mas_bottom).with.offset(10);
            }
            make.height.equalTo(@44);
        }];
    } else {
        NSString *btnTitleStr = (_payResultInfo.errorBtnType == KQPayResultErrorBtnTypeUnionPayCScanB) ? @"放弃付款" : @"放弃付款";
        self.finishBtn = [KQSecondaryButton secondaryButtonWithType:UIButtonTypeCustom title:btnTitleStr frame:CGRectZero target:self action:@selector(closeView:) tag:(int)KQPAYSUBVIEW_LABEL_TAG];
        [self.contentView addSubview:self.finishBtn];
        [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.contentView).with.offset(15);
            make.width.equalTo([NSNumber numberWithDouble:(KQC_SCREEN_WIDTH - 15*2-10)/2]);
            make.top.equalTo(resultDetailView.mas_bottom).with.offset(20);
            make.height.equalTo(@44);
        }];
        
        NSString *strErrorInfo = @"";
        if (payResultInfo.errorBtnType == KQPayResultErrorBtnTypeModifyPayCard) {
            strErrorInfo = @"修改卡信息";
        } else if (payResultInfo.errorBtnType == KQPayResultErrorBtnTypeUnionPayCScanB) {
            strErrorInfo = @"重新付款";
        } else {
            strErrorInfo = @"重新付款";
        }
        UIButton *payAgainBtn = [UIButton buttonWithType:UIButtonTypeCustom title:strErrorInfo frame:CGRectZero target:self action:@selector(payAgainClicked) tag:(int)KQPAYSUBVIEW_LABEL_TAG];
        [self.contentView addSubview:payAgainBtn];
        [payAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.contentView).with.offset(-15);
            make.width.equalTo([NSNumber numberWithDouble:(KQC_SCREEN_WIDTH - 15*2-10)/2]);
            make.top.equalTo(resultDetailView.mas_bottom).with.offset(20);
            make.height.equalTo(@44);
        }];
    }
}

- (void)initSubView {
    UIView *bannerView = nil;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(bannerView)]) {
        bannerView = [self.delegate bannerView];
        [self.contentView addSubview:bannerView];
        [bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@KQC_SCREEN_WIDTH);
            make.height.equalTo(@BannerViewHeight);
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.finishBtn.mas_bottom).with.offset(20);
        }];
    }
    
    //最后确定容器的底部位置，适当扩大一点
    if (bannerView) {
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(bannerView.mas_bottom).with.offset(16);
        }];
    } else {
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.finishBtn.mas_bottom).with.offset(16);
        }];
    }
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(resultViewDidAppear:isSuccess:)]) {
        [self.delegate resultViewDidAppear:self.contentView isSuccess:self.payResultInfo.result];
    }
}

- (void)setPayResultName:(KQPayResultLabelName * _Nonnull)payResultName
{
    _payResultName = payResultName;
    if (![NSString kqc_isBlank:payResultName.payResultName]) {
        self.payFailedLabel.text = payResultName.payResultName;
    }
    if (![NSString kqc_isBlank:payResultName.paymentName]) {
        
        self.payErrorInfoLabel.text = payResultName.paymentName;
        if(!_payResultInfo.result &&
           ([payResultName.paymentName containsString:KBankError] ||
            [payResultName.paymentName containsString:KBankErrorOther])){//todo delete
            self.bankNumErrorFlag = true;
            [self bankError];
        }
    }
    if (![NSString kqc_isBlank:payResultName.payMethodName]) {
        [self.paymodeview labelLeftText:payResultName.payMethodName];
    }
}

- (void)bankError{
    NSString *btnTitleStr;
    if (self.bankNumErrorFlag) {
        btnTitleStr = @"解绑并重新绑卡";
        self.rightBtn.hidden = NO;
    }else{
        btnTitleStr = (_payResultInfo.errorBtnType == KQPayResultErrorBtnTypeUnionPayCScanB) ? @"放弃付款" : @"放弃付款";
        self.rightBtn.hidden = YES;
    }
    [self.finishBtn setTitle:btnTitleStr forState:UIControlStateNormal];
}

- (void)viewDidShow {
    [self initSubView];
    [self resetBanner];
}

- (void)rightBtnClick:(id)sender{
    [super closeView:sender];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(getCurrentProductCode)]) {
        if ([[self.delegate getCurrentProductCode] isEqualToString:KQPaymentProductCodeTransfer]) {
            //转账确认埋点
            [KQCStatisticsManager logEvent:KQ_ZHUANZHANG_WANCHENGYEMIAN];
        }
    }
    if (self.payClosedBlock) {
        self.payClosedBlock(self.payResultInfo.result);
    }
}

-(void)closeView:(id)sender
{
    if(self.bankNumErrorFlag){
        [KQC_Engine_UI showViewControllerWithName:@"KQTiedCardViewController"];
    }else{
        [super closeView:sender];
        if (self.delegate&&[self.delegate respondsToSelector:@selector(getCurrentProductCode)]) {
            if ([[self.delegate getCurrentProductCode] isEqualToString:KQPaymentProductCodeTransfer]) {
                //转账确认埋点
                [KQCStatisticsManager logEvent:KQ_ZHUANZHANG_WANCHENGYEMIAN];
            }
        }
        if (self.payClosedBlock) {
            self.payClosedBlock(self.payResultInfo.result);
        }
    }
}

- (void)payAgainClicked
{
    if (self.payResultInfo.errorBtnType == KQPayResultErrorBtnTypeModifyPayCard) {
        //进入修改卡信息流程
        if (self.delegate&&[self.delegate respondsToSelector:@selector(modifyCardInfo)]) {
            [self.delegate modifyCardInfo];
        }
    } else {
        //经过确认，支付失败重新支付时直接回到第一页，并重新调用M251
        if (self.delegate&&[self.delegate respondsToSelector:@selector(rePay)]) {
            [self.delegate rePay];
        }
        if (self.payAgainBlock) {
            self.payAgainBlock();
        }
    }
}

- (void)resetBanner {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetBanner" object:nil];
}

//支付结果整个页面
- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth mode:(NSLineBreakMode)lineBreakMode content:(NSString *)content {
    
    CGSize maxSize = CGSizeMake(maxWidth, 3000);
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [content boundingRectWithSize:maxSize
                                            options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:attr
                                            context:nil];
        return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    CGSize size = [content sizeWithFont:font constrainedToSize:maxSize lineBreakMode:lineBreakMode];
    return CGSizeMake(ceil(size.width), ceil(size.height));
#pragma clang diagnostic pop
}
@end


