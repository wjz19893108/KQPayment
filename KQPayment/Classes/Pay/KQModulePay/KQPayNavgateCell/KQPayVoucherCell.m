//
//  KQPayVoucherCell.m
//  kuaiQianbao
//
//  Created by zouf on 16/4/16.
//
//

#import "KQPayVoucherCell.h"
#import "KQBasePayHalfView.h"
#import "UIImage+KQProcessPay.h"
#import <CoreText/CoreText.h>
#import "KQPayOrderDataProcess.h"

#define VOUCHER_DELTA_1     30/375.0f
#define VOUCHER_DELTA_2     105/375.0f
#define VOUCHER_DELTA_3     240/375.0f

@interface KQPayVoucherCell ()

@property (nonatomic, strong) UIImageView *voucherInfoImage;    //绿色灰色背景
@property (nonatomic, strong) UILabel *voucherInfo;             //优惠额度
@property (nonatomic, strong) UILabel *voucherName;             //优惠券名称
@property (nonatomic, strong) UILabel *voucherExpDate;          //失效日期
@property (nonatomic, strong) UIImageView *selectedImage;       //是否选中

@end

@implementation KQPayVoucherCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        __weak typeof(self) weakSelf = self;
        
        //红色灰色背景
        self.voucherInfoImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.voucherInfoImage];
        [self.voucherInfoImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.contentView).with.offset(15);
            make.right.equalTo(weakSelf.contentView).with.offset(-15);
            make.top.equalTo(weakSelf.contentView).with.offset(10);
            make.bottom.equalTo(weakSelf.contentView);
        }];
        
        //名称
        self.voucherName = [UILabel addLabel:@"" frame:CGRectZero size:17 isBold:NO textAlignment:NSTextAlignmentLeft textColor:UIColorFromRGB(0x33, 0x33, 0x33) tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.voucherInfoImage];
        [self.voucherName sizeToFit];
        [self.voucherName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.voucherInfoImage).with.offset(VOUCHER_DELTA_2*KQC_SCREEN_WIDTH);
            make.top.equalTo(weakSelf.voucherInfoImage).with.offset(15);
            make.width.lessThanOrEqualTo(@(VOUCHER_DELTA_3*KQC_SCREEN_WIDTH));
        }];
        
        //优惠额度
        self.voucherInfo = [UILabel addLabel:@"" frame:CGRectZero size:23 isBold:NO textAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.voucherInfoImage];
        [self.voucherInfo sizeToFit];
        [self.voucherInfo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.voucherInfoImage).with.offset(5);
            make.centerY.equalTo(weakSelf.voucherInfoImage);
            make.right.equalTo(weakSelf.voucherName.mas_left).offset (-18);
        }];
        
        //失效日期
        self.voucherExpDate = [UILabel addLabel:@"" frame:CGRectZero size:12 isBold:NO textAlignment:NSTextAlignmentLeft textColor:UIColorFromRGB(0x8f, 0x8f, 0x8f) tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.voucherInfoImage];
        [self.voucherExpDate sizeToFit];
        [self.voucherExpDate mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.voucherName);
            make.bottom.equalTo(weakSelf.voucherInfoImage).with.offset(-10);
            make.width.lessThanOrEqualTo(@(VOUCHER_DELTA_3*KQC_SCREEN_WIDTH));
        }];
        
        //选中图片
        self.selectedImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.voucherInfoImage addSubview:self.selectedImage];
        [self.selectedImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@16);
            make.height.mas_equalTo(@16);
            make.right.equalTo(weakSelf.voucherInfoImage).with.offset(-10);
            make.centerY.equalTo(weakSelf.voucherInfoImage);
        }];
    }
    return self;
}

- (void)voucherInfo:(NSString *)voucherInfo name:(NSString *)name expDate:(NSString *)expDate voucherType:(NSInteger)voucherType sourceFrom:(KQPayVoucherSourceFrom)sourceFrom{
    self.voucherName.text = name;
    self.voucherExpDate.text = expDate;
    
    __weak typeof(self) weakSelf = self;
    //    if (voucherType == KQPayVoucherTypeActive) {
    self.voucherInfo.hidden = NO;
    self.voucherName.textColor = UIColorFromRGB(0x33, 0x33, 0x33);
    [self.voucherName mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.voucherInfoImage).with.offset(VOUCHER_DELTA_2*KQC_SCREEN_WIDTH);
        make.top.equalTo(weakSelf.voucherInfoImage).with.offset(11);
        make.width.lessThanOrEqualTo(@(VOUCHER_DELTA_3*KQC_SCREEN_WIDTH));
    }];
    [self.voucherExpDate mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.voucherInfoImage).with.offset(VOUCHER_DELTA_2*KQC_SCREEN_WIDTH);
        make.bottom.equalTo(weakSelf.voucherInfoImage).with.offset(-10);
        make.width.lessThanOrEqualTo(@(VOUCHER_DELTA_3*KQC_SCREEN_WIDTH));
    }];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:voucherInfo];
    if(sourceFrom == KQPayVoucherFromMSXF){
        [self.voucherInfo setLineBreakMode:NSLineBreakByWordWrapping];
        [self.voucherInfo setNumberOfLines:0];
        self.voucherInfo.font = [UIFont systemFontOfSize:15];
        CGSize size = [NSString kqc_calcStrSize:voucherInfo font:[UIFont systemFontOfSize:15] maxWidth:self.voucherInfo.width];
        self.voucherInfo.height = size.height;
    }else{
        if ([attrStr length] > 1) {
            [attrStr addAttribute:(NSString *)kCTFontAttributeName
                            value:[UIFont systemFontOfSize:11]
                            range:NSMakeRange([attrStr length] - 1, 1)];
        }
        self.voucherInfo.font = [UIFont systemFontOfSize:23];
        //        self.voucherInfo.height = 23;
    }
    self.voucherInfo.attributedText = attrStr;
    //    } else if (voucherType == KQPayVoucherTypePassive){
    //        self.voucherInfo.hidden = YES;
    //        self.voucherName.textColor = [UIColor redColor];
    //        [self.voucherName mas_updateConstraints:^(MASConstraintMaker *make) {
    //            make.left.equalTo(weakSelf.voucherInfoImage).with.offset(VOUCHER_DELTA_1*KQC_SCREEN_WIDTH);
    //            make.top.equalTo(weakSelf.voucherInfoImage).with.offset(11);
    //            make.right.equalTo(weakSelf.voucherInfoImage).offset(-10);
    //        }];
    //        [self.voucherExpDate mas_updateConstraints:^(MASConstraintMaker *make) {
    //            make.left.equalTo(weakSelf.voucherInfoImage).with.offset(VOUCHER_DELTA_1*KQC_SCREEN_WIDTH);
    //            make.bottom.equalTo(weakSelf.voucherInfoImage).with.offset(-10);
    //            make.right.equalTo(weakSelf.voucherInfoImage).offset(-10);
    //        }];
    //    }
}

- (void)setPayVoucherEnable:(BOOL)payVoucherEnable
{
    _payVoucherEnable = payVoucherEnable;
    if (payVoucherEnable) {
        NSString *iconName;
        //        if (self.payVoucherType == KQPayVoucherTypeActive) {
        iconName = @"list_Coupon_red";
        //        } else if (self.payVoucherType == KQPayVoucherTypePassive) {
        //            iconName = @"youhuiquan_suijilijian";
        //        } else {
        //            iconName = @"";
        //        }
        self.voucherInfoImage.image = [UIImage kqppay_imageNamed:iconName];
        self.voucherInfo.textColor = UIColorFromRGB(0xf5, 0x4d, 0x4f);
        self.voucherName.textColor = UIColorFromRGB(0x33, 0x33, 0x33);

    }
    else {
        self.voucherInfoImage.image = [UIImage kqppay_imageNamed:@"list_Coupon_gred"];
        //        self.voucherInfo.textColor = UIColorFromRGB(0x66, 0x66, 0x66);
        self.voucherName.textColor = UIColorFromRGB(0x8f, 0x8f, 0x8f);
        self.voucherInfo.textColor = UIColorFromRGB(0x8f, 0x8f, 0x8f);
    }
}

- (void)setPayVoucherSelected:(BOOL)payVoucherSelected
{
    _payVoucherSelected = payVoucherSelected;
    if (payVoucherSelected) {
        self.selectedImage.image = [UIImage kqppay_imageNamed:@"ic_xuanzhong"];
    }
    else {
        self.selectedImage.image = [UIImage kqppay_imageNamed:@"ic_weixuan"];
    }
}

@end
