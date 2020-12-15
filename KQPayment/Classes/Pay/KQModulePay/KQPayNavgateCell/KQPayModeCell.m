//
//  KQPayModeCell.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/30.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQPayModeCell.h"
#import "KQBasePayHalfView.h"
#import "UIImage+KQProcessPay.h"
#import "KQPaymentMacro.h"
#import "KQInstallmentAdapter.h"

@interface KQPayModeCell ()

@property (nonatomic, strong, readwrite) UIImageView *payModeImage;
@property (nonatomic, strong, readwrite) UILabel *payModeName;
@property (nonatomic, strong, readwrite) UILabel *payModeDesc;
@property (nonatomic, strong, readwrite) UIImageView *selectedImage;
@property (nonatomic, strong, readwrite) UIView *lineView;
@property (nonatomic, strong, readwrite) UIView *maskView;

@property (nonatomic, strong, readwrite) UIImageView *activityImage;
@property (nonatomic, strong, readwrite) UILabel *activityName;
@property (nonatomic, strong) KQInstallmentAdapter *adapter;

@end

@implementation KQPayModeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //标题分隔线
        self.lineView = [[UIView alloc] initWithFrame:CGRectZero];
        self.lineView.backgroundColor = UIColorFromRGB(235, 235, 235);
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.width.equalTo(self);
            make.height.equalTo(@(KQBASE_NAVIGATE_SEPARATOR_HEIGHT));
            make.bottom.equalTo(self.contentView);
        }];
        
        //支付方式图片
        self.payModeImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.payModeImage];
        [self.payModeImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@30);
            make.height.mas_equalTo(@30);
            make.left.equalTo(self.contentView).with.offset(13);
            make.top.equalTo(self.contentView).with.offset(14);
        }];
        
        //支付方式名称
        self.payModeName = [UILabel addLabel:@"" frame:CGRectZero size:17 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(51, 51, 51) tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.payModeName sizeToFit];
        [self.payModeName mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.payModeImage.mas_right).with.offset(12);
            make.top.equalTo(self.contentView).with.offset(12);
            make.right.lessThanOrEqualTo(self.contentView).with.offset(-32);
        }];
        
        // 活动信息背景框
        self.activityImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.activityImage];
        
        //活动信息描述
        self.activityName = [UILabel addLabel:@"" frame:CGRectZero size:11 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(0xfd, 0x61, 0x54) tag:KQPAYACTIVITYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.activityName sizeToFit];
        [self.activityName mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.payModeName.mas_right).with.offset(12);
            make.centerY.equalTo(self.payModeName);
            make.right.lessThanOrEqualTo(self.contentView).with.offset(-32);
        }];
        
        [self.activityImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.activityName).with.insets(UIEdgeInsetsMake(1, -10, 1, -2));
        }];
        
        //支付方式描述
        self.payModeDesc = [UILabel addLabel:@"" frame:CGRectZero size:12 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(149, 149, 149) tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.payModeDesc sizeToFit];
        [self.payModeDesc mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.payModeImage.mas_right).with.offset(12);
            make.top.equalTo(self.payModeName.mas_bottom).with.offset(1);
            make.right.lessThanOrEqualTo(self.contentView).with.offset(-32);
        }];
        
        //选中图片
        self.selectedImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.selectedImage.image = [UIImage kqppay_imageNamed:@"ic_bank_choose"];
        [self.contentView addSubview:self.selectedImage];
        [self.selectedImage mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.mas_equalTo(@13);
            make.height.mas_equalTo(@10.5);
            make.right.equalTo(self.contentView).with.offset(-15);
            make.top.equalTo(self.contentView).with.offset(24);
        }];
        
        //不可用支付方式蒙版
        self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
        self.maskView.backgroundColor = UIColorFromRGB(248, 248, 248);
        self.maskView.alpha = 0.8;
        [self.contentView addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
        
        self.adapter = [[KQInstallmentAdapter alloc] initInstallmentOffY:60];
        self.adapter.adapterView.hidden = YES;
        [self addSubview:self.adapter.adapterView];
    }
    return self;
}

- (void)hiddeInstallment:(BOOL)flag{
    self.adapter.adapterView.hidden = flag;
}

- (void)installmentInfo:(NSArray*)installemnts defaultInstallment:defaultInfo clickDone:(void(^)(NSInteger  choiceInstal,BOOL popFlag))stalmentClickBlock{
    [self.adapter updateByInfo:installemnts defaultInstallment:defaultInfo clickDone:stalmentClickBlock];
}

- (void)cellTypeAddOtherBankCard {
    self.payModeImage.hidden = NO;
    self.payModeImage.image = [UIImage kqppay_imageNamed:@"ic_add_bank_card"];
    self.payModeName.text = @"添加银行卡支付";
    self.payModeDesc.text = @"";
    
    self.activityImage.hidden = YES;
    self.activityName.hidden = YES;
    
    [self.payModeName mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.payModeImage.mas_right).with.offset(12);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)cellTypePayMethod:(NSString *)payType bankId:(NSString *)bankId displayName:(NSString *)displayName limitInfo:(NSString *)limitInfo icon:(NSString *)icon showIcon:(BOOL)showIcon activityMsg:(NSString *)activityMsg{
    self.payModeImage.hidden = !showIcon;
    
    if ([payType isEqualToString:KQPayMethodPayTypeDebitCard]||[payType isEqualToString:KQPayMethodPayTypeCreditCard]) {
        [self.payModeImage setBankIcon:[NSString stringWithFormat:@"bank_%@", [bankId lowercaseString]]];
    } else {
        if ([KQPayMethodPayTypeMaShang isEqualToString:payType] && [NSString kqc_isBlank:icon]){
            self.payModeImage.image = [UIImage imageNamed:@"bank_anyihua"];
        }else{
            [self.payModeImage setOMSIcon:icon];
        }
    }
//    else if ([payType isEqualToString:KQPayMethodPayTypeAccount]){
//        [self.payModeImage setImage:[UIImage kqppay_imageNamed:@"pay_method_account"]];
//    } else if ([payType isEqualToString:KQPayMethodPayTypeInstallment]){
//        [self.payModeImage setImage:[UIImage kqppay_imageNamed:@"pay_method_credit"]];
//    } else if ([payType isEqualToString:KQPayMethodPayTypeFinancial]){
//        [self.payModeImage setImage:[UIImage kqppay_imageNamed:@"pay_method_kuaililai"]];
//    } else if ([payType isEqualToString:KQPayMethodPayTypeMedical]){
//        [self.payModeImage setImage:[UIImage kqppay_imageNamed:@"ic_zhenliao"]];
//    }
    
    
    self.payModeName.text = displayName;
    self.payModeDesc.text = limitInfo;
    
    [self.payModeName mas_remakeConstraints:^(MASConstraintMaker *make){
        if (showIcon) {
            make.left.equalTo(self.payModeImage.mas_right).with.offset(12);
        } else {
            make.left.equalTo(self.contentView).with.offset(15);
        }
        if ([NSString kqc_isBlank:limitInfo]) {
            make.top.equalTo(self.contentView).with.offset(19);
        } else {
            make.top.equalTo(self.contentView).with.offset(12);
        }
        make.right.lessThanOrEqualTo(self.contentView).with.offset(-32);
    }];
    
    [self.activityName mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.payModeName.mas_right).with.offset(12);
        make.right.lessThanOrEqualTo(self.contentView).with.offset(-32);
        make.centerY.equalTo(self.payModeName);
    }];
    
    if (![NSString kqc_isBlank:activityMsg]) {
        self.activityImage.hidden = NO;
        self.activityName.hidden = NO;
        self.activityName.text = activityMsg;
        
        UIImage *strenchImage = [UIImage kqppay_imageNamed:@"ic_youhuiquan_left"];
        [self.activityImage setImage:[strenchImage resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 16, 0, 4)) resizingMode:UIImageResizingModeStretch]];
        
        
    }else{
        self.activityImage.hidden = YES;
        self.activityName.hidden = YES;
    }
}

@end
