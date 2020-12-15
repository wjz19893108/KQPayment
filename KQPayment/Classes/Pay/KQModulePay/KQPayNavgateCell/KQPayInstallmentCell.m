//
//  KQPayInstallmentCell.m
//  kuaiQianbao
//
//  Created by zouf on 16/1/14.
//
//

#import "KQPayInstallmentCell.h"
#import "KQBasePayHalfView.h"
#import "UIImage+KQProcessPay.h"


@interface KQPayInstallmentCell ()

@property (nonatomic, strong) UILabel *installmentNum;      //分几期
@property (nonatomic, strong) UILabel *installmentPer;      //每期换
@property (nonatomic, strong) UILabel *installmentSum;      //总共换
@property (nonatomic, strong) UIView *lineView;             //分隔线
@property (nonatomic, strong, readwrite) UIImageView *selectedImage;

@end

@implementation KQPayInstallmentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //分隔线
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(KQPAYPASSWORD_GRID_START_Y_POS, KQPAY_INSTALLMENT_TABLE_CELL_HEIGHT - KQBASE_NAVIGATE_SEPARATOR_HEIGHT, KQC_SCREEN_WIDTH, KQBASE_NAVIGATE_SEPARATOR_HEIGHT)];
        self.lineView.backgroundColor = UIColorFromRGB(228, 228, 228);
        [self.contentView addSubview:self.lineView];
        
        __weak typeof(self) weakSelf = self;
        self.installmentNum = [UILabel addLabel:@"" frame:CGRectZero size:15 isBold:NO textAlignment:NSTextAlignmentCenter textColor:[UIColor blackColor] tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.installmentNum sizeToFit];
        [self.installmentNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).with.offset(18);
            make.top.equalTo(weakSelf).with.offset(10);
        }];
        
        self.installmentPer = [UILabel addLabel:@"" frame:CGRectZero size:13 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(149, 149, 149) tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.installmentPer sizeToFit];
        [self.installmentPer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).with.offset(18);
            make.top.equalTo(weakSelf).with.offset(30);
        }];
        
        self.installmentSum = [UILabel addLabel:@"" frame:CGRectZero size:13 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(245, 77, 79) tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.installmentSum sizeToFit];
        [self.installmentSum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).with.offset(18);
            make.top.equalTo(weakSelf).with.offset(48);
        }];
        
        //选中图片
        self.selectedImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.selectedImage.image = [UIImage kqppay_imageNamed:@"pay_selected"];
        [self.contentView addSubview:self.selectedImage];
        [self.selectedImage mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.mas_equalTo(@16);
            make.height.mas_equalTo(@16);
            make.right.equalTo(weakSelf).with.offset(-15);
            make.centerY.equalTo(weakSelf);
        }];
    }
    return self;
}

- (void)setNumText:(NSString*)text
{
    self.installmentNum.text = text;
}

- (void)setPerText:(NSString*)text
{
    self.installmentPer.text = text;
}

- (void)setSumText:(NSString*)text
{
    self.installmentSum.text = text;
}

@end
