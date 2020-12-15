//
//  KQPayNoneVoucherNavigateView.m
//  kuaiQianbao
//
//  Created by zouf on 16/4/21.
//
//

#import "KQPayNoneVoucherNavigateView.h"
#import "KQPayOrderData.h"
#import "UIImage+KQProcessPay.h"

@interface KQPayNoneVoucherNavigateView ()

@property (nonatomic, strong) UIImageView *noneVoucherImage;
@property (nonatomic, strong) UILabel *noneVoucherLabel;
@property (nonatomic, strong) UILabel *otherVoucherLabel;
@property (nonatomic, strong) UILabel *otherVoucherBlueLabel;
@property (nonatomic, strong) UIButton *otherVoucherButton;

@end

@implementation KQPayNoneVoucherNavigateView

- (instancetype __nullable)init
{
    self = [super initWithTitle:@"优惠券"];
    if (self) {
        self.noneVoucherImage = [[UIImageView alloc] init];
        self.noneVoucherImage.image = [UIImage kqppay_imageNamed:@"ic_empty_package"];
        [self.noneVoucherImage sizeToFit];
        [self.mainView addSubview:self.noneVoucherImage];
        [self.noneVoucherImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mainView);
            make.top.equalTo(self.mainView).with.offset(70 + KQPAYSUBVIEW_START_Y_POS);
        }];
        
        self.noneVoucherLabel = [UILabel addLabel:@"您暂无可用优惠券" frame:CGRectZero size:15 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(149, 149, 149) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self.mainView];
        [self.noneVoucherLabel sizeToFit];
        [self.noneVoucherLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(self.mainView);
            make.top.equalTo(self.noneVoucherImage.mas_bottom).with.offset(15);
        }];
    }
    return self;
}

- (void)viewDidShow {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(voucherAllCount)]) {
        if ([self.delegate voucherAllCount] > 0) {
            UIView *helper = [[UIView alloc] init];
            helper.backgroundColor = [UIColor clearColor];
            [self.mainView addSubview:helper];
            [helper mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mainView);
            }];
            
            self.otherVoucherLabel = [UILabel addLabel:@"您可查看其他优惠券，" frame:CGRectZero size:15 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(149, 149, 149) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self.mainView];
            [self.otherVoucherLabel sizeToFit];
            [self.otherVoucherLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(helper);
                make.bottom.equalTo(self.mainView).with.offset(-66);
            }];
            
            self.otherVoucherBlueLabel = [UILabel addLabel:@"点击查看" frame:CGRectZero size:15 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(84, 203, 216) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self.mainView];
            [self.otherVoucherBlueLabel sizeToFit];
            [self.otherVoucherBlueLabel mas_makeConstraints:^(MASConstraintMaker *make){
                make.right.equalTo(helper);
                make.left.equalTo(self.otherVoucherLabel.mas_right);
                make.centerY.equalTo(self.otherVoucherLabel);
            }];
            
            self.otherVoucherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.otherVoucherButton addTarget:self action:@selector(otherVoucherClick) forControlEvents:UIControlEventTouchUpInside];
            [self.mainView addSubview:self.otherVoucherButton];
            [self.otherVoucherButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.otherVoucherBlueLabel);
                make.right.equalTo(self.otherVoucherBlueLabel);
                make.centerY.equalTo(self.otherVoucherBlueLabel);
            }];
        }
    }
}

- (void)otherVoucherClick
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(otherVouchers)]) {
        [self.delegate otherVouchers];
    }
}


@end
