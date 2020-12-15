//
//  KQPayDetailCell.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/28.
//  Copyright © 2015年 program. All rights reserved.
//

#import "KQPayDetailCell.h"
#import "KQBasePayHalfView.h"
#import "UIImage+KQProcessPay.h"

@interface KQPayDetailCell ()

@property (nonatomic, strong, readwrite) UILabel *labelInfo;
@property (nonatomic, strong, readwrite) UILabel *labelRight;
@property (nonatomic, strong, readwrite) UIImageView *activityImage;
@property (nonatomic, strong, readwrite) UILabel *activityName;
@property (nonatomic, strong, readwrite) UIView *roundView;

@end

@implementation KQPayDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //标题分隔线
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = UIColorFromRGB(235, 235, 235);
        [self.contentView addSubview:lineView];
        
        __weak typeof(&*self) weakSelf = self;
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.contentView).with.offset(KQPAYPASSWORD_GRID_START_Y_POS);
            make.bottom.equalTo(weakSelf.contentView).with.offset(-KQBASE_NAVIGATE_SEPARATOR_HEIGHT);
            make.width.equalTo(@(KQC_SCREEN_WIDTH));
            make.height.equalTo(@(KQBASE_NAVIGATE_SEPARATOR_HEIGHT));
        }];
        
        //左边的信息提示
        self.labelInfo = [UILabel addLabel:@"" frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentLeft textColor:UIColorFromRGB(149, 149, 149) tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.labelInfo sizeToFit];
        //垂直居中，离左边15
        [self.labelInfo mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView).with.offset(15);
            make.centerY.equalTo(self.contentView);
            make.right.lessThanOrEqualTo(self.contentView).with.offset(-KQC_SCREEN_WIDTH*1.7/3);
        }];
        
        
        //右边的信息提示
        self.labelRight = [UILabel addLabel:@"" frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentRight textColor:[UIColor blackColor] tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.labelRight sizeToFit];
        
        // 活动信息背景框
        self.activityImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.activityImage];
        
        //活动信息描述
        self.activityName = [UILabel addLabel:@"" frame:CGRectZero size:11 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(0xfd, 0x61, 0x54) tag:KQPAYSUBVIEW_LABEL_TAG intoView:self.contentView];
        [self.activityName sizeToFit];
        [self.activityName mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.labelRight.mas_left).with.offset(-12);
            make.centerY.equalTo(self.labelRight);
            make.left.greaterThanOrEqualTo(self.labelInfo.mas_right).with.offset(5);
            
        }];
        
        [self.activityImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.activityName).with.insets(UIEdgeInsetsMake(1, -2, 1, -10));
        }];
        
        self.roundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.roundView.backgroundColor = [UIColor redColor];
        self.roundView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.roundView];
        [self.roundView mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.mas_equalTo(@6);
            make.height.mas_equalTo(@6);
            make.left.equalTo(self.labelRight.mas_right).with.offset(2);
            make.centerY.equalTo(self.contentView).offset(-5);
        }];
        [self.roundView.layer setCornerRadius:3.0f];
        
    }
    return self;
}

- (void)labelRightTextColor:(UIColor*)color
{
    [self.labelRight setTextColor:color];
}

- (void)labelLeftTextColor:(UIColor*)color{
    [self.labelInfo setTextColor:color];
}

- (void)updateLabelRightTextConstraints:(BOOL)hasNextPage {
    //垂直居中，离左边15
    [self.labelRight mas_remakeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.contentView).with.offset(hasNextPage?0:-15);
        make.centerY.equalTo(self.contentView);
        make.left.greaterThanOrEqualTo(self.contentView).with.offset(KQC_SCREEN_WIDTH/3+5);
    }];
}

- (void)updateLabelActivityConstraints:(NSString *)activityMsg hasActivity:(BOOL)hasActivity isShown:(BOOL)isShown{
    self.roundView.hidden = YES;
    
    if (![NSString kqc_isBlank:activityMsg]) {
        self.activityImage.hidden = NO;
        self.activityName.hidden = NO;
        self.activityName.text = activityMsg;
        UIImage *strenchImage = [UIImage kqppay_imageNamed:@"ic_youhuiquan"];
        [self.activityImage setImage:[strenchImage resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 4, 0, 16)) resizingMode:UIImageResizingModeStretch]];
    } else {
        self.activityImage.hidden = YES;
        self.activityName.hidden = YES;
        if (hasActivity && isShown) {
            self.roundView.hidden = NO;
        }
    }
    
}

@end
