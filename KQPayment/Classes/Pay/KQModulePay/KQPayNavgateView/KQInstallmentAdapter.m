//
//  KQInstalmentAdapter.m
//  FenQiDemo
//
//  Created by tian qing on 2018/2/24.
//  Copyright © 2018年 tian. All rights reserved.
//

#import "KQInstallmentAdapter.h"


@interface KQInstallmentAdapter()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) UIView *preSelectedBtn;
@property (nonatomic, copy) kStallmentBlock stallmentClickBlock;
@property (nonatomic, strong) NSString *defaultStage;
@end

@implementation KQInstallmentAdapter


#define kInstallmentBtnWidth 115
#define kInstallmentBtnHeight 36

#define kInfoLabel 100
#define kAmtLabel 101
- (instancetype)initInstallmentOffY:(CGFloat)offY{
    self = [super init];
    if (self) {
        [self initView:offY];
    }
    return self;
}

- (void)initView:(CGFloat)offY{
    CGRect windowFrame = [UIScreen mainScreen].bounds;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, windowFrame.size.width, kAdapterHeight)];
    self.scrollView.backgroundColor = UIColorFromRGB(238, 241, 242);
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, offY, windowFrame.size.width, kAdapterHeight)];
    [self.bgView addSubview:self.scrollView];
    
    UILabel *instalmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 10, 200, 12)];
    instalmentLabel.text =@"安逸花分期";
    [instalmentLabel setTextAlignment:NSTextAlignmentLeft];
    [instalmentLabel setTextColor:UIColorFromRGB(51, 51, 51)];
    [instalmentLabel setFont:[UIFont systemFontOfSize:12]];
    [instalmentLabel sizeToFit];
    [self.bgView addSubview:instalmentLabel];
    
    UILabel *instalmentTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(instalmentLabel.right + 5, 10, 200, 12)];
    instalmentTipLabel.text =@"(以实际还款金额为准)";
    [instalmentTipLabel setTextAlignment:NSTextAlignmentLeft];
    [instalmentTipLabel setTextColor:[UIColor grayColor]];
    [instalmentTipLabel setFont:[UIFont systemFontOfSize:12]];
    [instalmentTipLabel sizeToFit];
    [self.bgView addSubview:instalmentTipLabel];
}

- (void)clickAction:(UIButton *)btn{
    [self btnSelected:btn];
    [self btnDisSelected:self.preSelectedBtn];
    self.preSelectedBtn = btn;
    if (self.stallmentClickBlock) {
        self.stallmentClickBlock(btn.tag, YES);
    }
}

- (void)updateByInfo:(NSArray *)data defaultInstallment:(NSString *)defaultStage clickDone:(void(^)(NSInteger  choiceInstal,BOOL popFlag))stalmentClickBlock{
    for(UIView *btnView in [self.scrollView subviews]){
        if ([btnView isKindOfClass:[UIButton class]]) {
            [btnView removeFromSuperview];
        }
    }
    
    self.data = data;
    self.stallmentClickBlock = stalmentClickBlock;
    self.defaultStage = defaultStage;
    
    self.scrollView.contentSize = CGSizeMake((kInstallmentBtnWidth + 10)*[self.data count] + 10, kAdapterHeight);
    [self.data enumerateObjectsUsingBlock:^(KQPayInstalment *installment, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10 + (kInstallmentBtnWidth+10)*idx, 36, kInstallmentBtnWidth, kInstallmentBtnHeight)];
        btn.backgroundColor = [UIColor whiteColor];
        btn.tag = idx;
        [btn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btn];
        
        UILabel *instalMentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, kInstallmentBtnWidth, 10)];
        instalMentLabel.text = installment.stageInfo;
        instalMentLabel.tag = kInfoLabel;
        [instalMentLabel setFont:[UIFont systemFontOfSize:10]];
        [instalMentLabel setTextAlignment:NSTextAlignmentCenter];
        [btn addSubview:instalMentLabel];
        
        UILabel *amtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, instalMentLabel.frame.origin.y + 10 + 5, kInstallmentBtnWidth, 10)];
        amtLabel.tag = kAmtLabel;
        amtLabel.text = installment.feeInfo;
        [amtLabel setFont:[UIFont systemFontOfSize:10]];
        [amtLabel setTextAlignment:NSTextAlignmentCenter];
        [btn addSubview:amtLabel];
        
        if ([installment.stageNumber isEqualToString:self.defaultStage]) {
            self.preSelectedBtn = btn;
            [self btnSelected:btn];
        }else{
            [self btnDisSelected:btn];
        }
    }];
    if (!self.preSelectedBtn) {
        UIButton *btn = [self.scrollView viewWithTag:0];
        self.preSelectedBtn = btn;
        [self btnSelected:btn];
    }
    
    if (self.stallmentClickBlock) {
        self.stallmentClickBlock((int)self.preSelectedBtn.tag, NO);
    }
    
}

- (void)btnSelected:(UIView *)bgView{
    UILabel *infoLabel = [bgView viewWithTag:kInfoLabel];
    UILabel *amtLabel = [bgView viewWithTag:kAmtLabel];
    infoLabel.textColor = [UIColor redColor];
    amtLabel.textColor = [UIColor redColor];
    
    bgView.layer.borderWidth = 0.4;
    bgView.layer.borderColor = [UIColor clearColor].CGColor;
    bgView.layer.cornerRadius = 5;
}

- (void)btnDisSelected:(UIView *)bgView{
    UILabel *infoLabel = [bgView viewWithTag:kInfoLabel];
    UILabel *amtLabel = [bgView viewWithTag:kAmtLabel];
    infoLabel.textColor = UIColorFromRGB(133, 136, 138);
    amtLabel.textColor = UIColorFromRGB(133, 136, 138);
    
    bgView.layer.borderWidth = 0.4;
    bgView.layer.cornerRadius = 5;
    bgView.layer.borderColor = [UIColor clearColor].CGColor;
}


- (UIView *)adapterView{
    return self.bgView;
}

@end
