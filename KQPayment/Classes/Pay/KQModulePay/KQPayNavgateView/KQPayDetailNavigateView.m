//
//  KQPayDetailNavigateView.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/27.
//  Copyright © 2015年 program. All rights reserved.
//


#import "KQPayDetailNavigateView.h"
#import "KQPayDetailCell.h"
#import "UIImage+KQProcessPay.h"
#import "KQPaymentMacro.h"

@implementation KQPayDetailInfoTypeWapper

@end


@interface KQPayDetailNavigateView () <UITableViewDataSource, UITableViewDelegate, KQPayDetailLoadingTypeDelegate>

@property (nonatomic, strong) UITableView *payDetailTableView;
@property (nonatomic, strong) UIView *paymentView;
@property (nonatomic, strong) UILabel *labelAmount;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableDictionary *cellTypeDic;
@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation KQPayDetailNavigateView

- (instancetype __nullable)init
{
    self = [super initWithTitle:@"付款详情"];
    if (self) {
        //创建table，显示订单信息、飞凡账户、付款方式等
        CGFloat mainViewHeight = self.mainView.height;
        self.payDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KQPAYSUBVIEW_START_Y_POS, KQC_SCREEN_WIDTH, mainViewHeight - KQPAYSUBVIEW_START_Y_POS) style:UITableViewStylePlain];
        self.payDetailTableView.backgroundView = nil;
        self.payDetailTableView.backgroundColor = [UIColor clearColor];
        self.payDetailTableView.dataSource = self;
        self.payDetailTableView.delegate = self;
        self.payDetailTableView.separatorColor = [UIColor clearColor];
        [self.mainView addSubview:self.payDetailTableView];
        
        //创建需付款view
        self.paymentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQPAYDETAIL_PAYMENT_HEIGHT)];
        self.payDetailTableView.tableFooterView = self.paymentView;
        
        __weak typeof(self) weakSelf = self;
        //左边的信息提示
        UILabel *labelInfo = [UILabel addLabel:[self.titleArray lastObject] frame:CGRectZero size:14 isBold:NO textAlignment:NSTextAlignmentCenter textColor:[UIColor blackColor] tag:(int)(self.titleArray.count + KQPAYSUBVIEW_LABEL_TAG) intoView:self.paymentView];
        [labelInfo sizeToFit];
        //垂直居中，离左边15
        [labelInfo mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(weakSelf.paymentView).with.offset(15);
            make.centerY.equalTo(weakSelf.paymentView);
        }];
        
        //付款金额
//        self.labelAmount = [UILabel addLabel:@"0.00元" frame:CGRectZero size:25 isBold:YES textAlignment:NSTextAlignmentCenter textColor:[UIColor blackColor] tag:(int)(self.titleArray.count + KQPAYSUBVIEW_LABEL_TAG) intoView:self.paymentView];
//        [self.labelAmount sizeToFit];
//        //垂直居中，离左边15
//        [self.labelAmount mas_makeConstraints:^(MASConstraintMaker *make){
//            make.right.equalTo(weakSelf.paymentView).with.offset(-15);
//            make.centerY.equalTo(weakSelf.paymentView);
//        }];
        
        //确认付款按钮
        self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom title:@"确认付款" frame:CGRectZero target:self action:@selector(confirmClicked) tag:(int)(self.titleArray.count + KQPAYSUBVIEW_LABEL_TAG)];
        [self.mainView addSubview:self.confirmBtn];
        self.confirmBtn.enabled = NO;
        UIView *mainView = self.mainView;
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainView).with.offset(15);
            make.right.equalTo(mainView).with.offset(-15);
            make.bottom.equalTo(mainView).with.offset(-30);
            make.height.equalTo(@44);
        }];
        [self payButtonHandle];
    }
    return self;
}

-(void)updateCellInfo{
    KQPayVoucherSourceFrom voucherFrom = [self.delegate maShangVoucherFrom];
    self.titleArray = @[@"订单信息", @"快钱刷账户", @"付款方式", @"分期方式", @"优惠券", @"银联优惠", @"备注", @"需付款",
                        voucherFrom==KQPayUnuseVoucher?@"应还金额(含利息)":
                        (voucherFrom==KQPayVoucherFromMSXF?@"应还金额(含利息)":@"优惠券抵扣"),
                        ((voucherFrom==KQPayVoucherFromMSXF) ||
                         (voucherFrom==KQPayUnuseVoucher))?@"优惠券抵扣":@"应还金额(含利息)"];
    self.cellTypeDic = [NSMutableDictionary dictionary];
    [self.titleArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQPayDetailInfoTypeWapper *infoTypeWapper = [[KQPayDetailInfoTypeWapper alloc] init];
        if ([obj isEqualToString:@"订单信息"]) {
            infoTypeWapper.infoType = KQPayDetailInfoTypeMerchantName;
        }
        else if ([obj isEqualToString:@"快钱刷账户"]) {
            infoTypeWapper.infoType = KQPayDetailInfoTypeAccountName;
        }
        else if ([obj isEqualToString:@"付款方式"]) {
            infoTypeWapper.infoType = KQPayDetailInfoTypePaymentMode;
        }
        else if ([obj isEqualToString:@"分期方式"]) {
            infoTypeWapper.infoType = KQPayDetailInfoTypeInstallmentMode;
        }
        else if ([obj isEqualToString:@"优惠券"]) {
            infoTypeWapper.infoType = KQPayDetailInfoTypeVoucher;
        }
        else if ([obj isEqualToString:@"银联优惠"]){
            infoTypeWapper.infoType = KQPayDetailInfoTypeUPayVoucher;
        }
        else if ([obj isEqualToString:@"备注"]) {
            infoTypeWapper.infoType = KQPayDetailInfoTypeRemark;
        }
        else if ([obj isEqualToString:@"需付款"]) {
            infoTypeWapper.infoType = KQPayDetailInfoTypeOrderAmount;
        }
        else if ([obj isEqualToString:@"应还金额(含利息)"]) {
            infoTypeWapper.infoType = ((voucherFrom == KQPayVoucherFromMSXF || voucherFrom == KQPayUnuseVoucher)?KQPayDetailInfoTypeExtendOne:KQPayDetailInfoTypeExtendTwo);
        }
        else if ([obj isEqualToString:@"优惠券抵扣"]) {
            infoTypeWapper.infoType = ((voucherFrom == KQPayVoucherFromMSXF || voucherFrom == KQPayUnuseVoucher)?KQPayDetailInfoTypeExtendTwo:KQPayDetailInfoTypeExtendOne);
        }
        
        [self.cellTypeDic setObject:infoTypeWapper forKey:obj];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 130;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, KQC_SCREEN_WIDTH, 120)];
    footerView.backgroundColor = [UIColor clearColor];
    
    NSString *cLabelString = @"支付交易风险提示：\n1、请认真核对付款信息，确保信息准确\n2、交易系统会对可疑交易进行拦截；\n3、请妥善保管您的支付密码和账户信息，不要随意透漏给他人";
    UILabel *tipLabel = [UILabel labelBlackByFont:12.5 frame:CGRectMake(15, footerView.y, footerView.width-30, footerView.height) align:TextLeft];;
    tipLabel.numberOfLines = 0;
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:cLabelString];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [cLabelString length])];
    [tipLabel setAttributedText:attributedString];
    [tipLabel sizeToFit];
    [footerView addSubview:tipLabel];
    return footerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isRowShouldHide:indexPath]) {
        return 0;
    }
    return KQPAYTABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KQPayDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KQPayDetailIdentifier"];
    if(cell == nil)
    {
        cell = [[KQPayDetailCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"KQPayDetailIdentifier"];
    }
    
    // 银联C扫B文案
    NSString *labelInfo = [self.titleArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate isKindOfClass:NSClassFromString(@"KQCScanBManager")] && [labelInfo isEqualToString:@"优惠券"]) {
        labelInfo = @"快钱支付优惠";
    }
    cell.labelInfo.text = labelInfo;
    
    KQPayDetailInfoType cellType = [self getCellType:[self.titleArray objectAtIndex:indexPath.row]];
    //默认颜色是黑色
    [cell labelRightTextColor:RIGHT_INFO_BLACK_STYLE];
    [cell labelLeftTextColor:[UIColor blackColor]];
    __block NSString *rightInfo = @"";
    __block NSMutableAttributedString *attributedRightInfo;
    __block BOOL hasNextPage = NO;
    __block BOOL attributedStringFlag = NO;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(getColumnInfo:resultBlock:)]) {
        [self.delegate getColumnInfo:cellType resultBlock:^(NSString * _Nullable info, BOOL canSelected, NSString * activityMsg, BOOL hasActivity) {
            hasNextPage = canSelected;
            rightInfo = info;
            if (cellType == KQPayDetailInfoTypePaymentMode) {
                if ([NSString kqc_isBlank:rightInfo]) {
                    rightInfo = @"请先绑卡";
                    if ([self.delegate respondsToSelector:@selector(canBindCard)]) {
                        if (![self.delegate canBindCard]) {
                            attributedStringFlag = YES;
                            //没有支付方式，又不能绑卡，提示文字也改成红色
                            NSString *status;
                            if ([self.delegate respondsToSelector:@selector(anYiHuaPayStatus)]){
                                status = [self.delegate anYiHuaPayStatus];
                            }
                            attributedRightInfo = [self payTipStr:status];
                            [cell labelRightTextColor:RIGHT_INFO_RED_STYLE];
                        }
                    }
                }
            } else if (cellType == KQPayDetailInfoTypeInstallmentMode) {
                if ([NSString kqc_isBlank:rightInfo]) {
                    rightInfo = @"请选择分期方式";
                }
            } else if (cellType == KQPayDetailInfoTypeVoucher) {
                //优惠券的右边文字是灰的
                if ([NSString kqc_isBlank:rightInfo]) {
                    if ([self.delegate respondsToSelector:@selector(vouchersCount)]) {
                        if ([self.delegate vouchersCount] > 0) {
                            [cell labelRightTextColor:RIGHT_INFO_BLACK_STYLE];
                            
                            rightInfo = [NSString stringWithFormat:@"您有%lu张优惠券可用", (unsigned long)[self.delegate vouchersCount]];
                            
                            attributedRightInfo = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"您有%lu张优惠券可用", (unsigned long)[self.delegate vouchersCount]]];
                            NSRange beginRange = [rightInfo rangeOfString:@"您有"];
                            NSRange endRange = [rightInfo rangeOfString:@"优"];
                            NSRange numberRange = NSMakeRange(beginRange.location + beginRange.length, endRange.location - beginRange.location - beginRange.length);
                            
                            [attributedRightInfo addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:numberRange];
                        }
                        else {
                            [cell labelRightTextColor:RIGHT_INFO_GRAY_STYLE];
                            rightInfo = @"暂无可用优惠券";
                        }
                    }
                } else {
                    //选了券是红的
                    [cell labelRightTextColor:RIGHT_INFO_BLACK_STYLE];
                }
            }else if(cellType == KQPayDetailInfoTypeOrderAmount){
                KQPayVoucherSourceFrom voucherFrom = [self.delegate maShangVoucherFrom];
                if (voucherFrom == KQPayVoucherFromVAS) {
                    attributedStringFlag = YES;
                    NSString *orderAmt = KQC_FORMAT(@"%@元", [KQCAmount getDecimalAmount:[self.delegate orderAmt] amountUnit:KQCAmountUnitTypeFen]);
                    NSString *showStr = KQC_FORMAT(@"%@ (%@)", info, orderAmt);
                    attributedRightInfo = [self midLineStr:showStr lineStr:orderAmt];
                }
            }
            else if (cellType == KQPayDetailInfoTypeExtendOne) {
                KQPayVoucherSourceFrom voucherFrom = [self.delegate maShangVoucherFrom];
                if (voucherFrom == KQPayVoucherFromVAS) {
                    [cell labelLeftTextColor:[UIColor redColor]];
                    [cell labelRightTextColor:[UIColor redColor]];
                    rightInfo = [NSString stringWithFormat:@"-%@元",
                                 [KQCAmount getDecimalAmount:[self.delegate orderTrialRipAmt] amountUnit:KQCAmountUnitTypeFen]];
                }else if(voucherFrom == KQPayUnuseVoucher){
                    rightInfo = [NSString stringWithFormat:@"%@元", [KQCAmount getDecimalAmount:[self.delegate orderTrialAmt] amountUnit:KQCAmountUnitTypeFen]];
                }
                else if(voucherFrom == KQPayVoucherFromMSXF){
                    attributedStringFlag = YES;
                    NSString *trialAmt = [KQCAmount getDecimalAmount:[self.delegate orderTrialAmt] amountUnit:KQCAmountUnitTypeFen];
                    NSString *totalAmt = [NSString stringWithFormat:@"%@元",
                                          [KQCAmount getDecimalAmount:[self.delegate orderTrialTotalAmt] amountUnit:KQCAmountUnitTypeFen]];
                    
                    NSString *showAmt = [NSString stringWithFormat:@"%@元 (%@)",trialAmt, totalAmt];
                    attributedRightInfo = [self midLineStr:showAmt lineStr:totalAmt];
                }
            } else if (cellType == KQPayDetailInfoTypeExtendTwo) {
                KQPayVoucherSourceFrom voucherFrom = [self.delegate maShangVoucherFrom];
                if (voucherFrom == KQPayVoucherFromMSXF) {
                    [cell labelLeftTextColor:[UIColor redColor]];
                    [cell labelRightTextColor:[UIColor redColor]];
                    rightInfo = [NSString stringWithFormat:@"-%@元", [KQCAmount getDecimalAmount:[self.delegate orderTrialRipAmt] amountUnit:KQCAmountUnitTypeFen]];
                }else if(voucherFrom == KQPayVoucherFromVAS){
                    rightInfo = [NSString stringWithFormat:@"%@元", [KQCAmount getDecimalAmount:[self.delegate orderTrialAmt] amountUnit:KQCAmountUnitTypeFen]];
                }
            }
            [cell updateLabelActivityConstraints:activityMsg hasActivity:hasActivity isShown:(cellType == KQPayDetailInfoTypePaymentMode)&&![NSString kqc_isBlank:rightInfo]];
        }];
    }
    
    if (hasNextPage) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if(attributedStringFlag){
        cell.labelRight.attributedText = attributedRightInfo;
    }else{
        cell.labelRight.text = rightInfo;
    }
    
    if (![NSString kqc_isBlank:[attributedRightInfo string]]) {
        cell.labelRight.attributedText = attributedRightInfo;
    }
    
    [cell updateLabelRightTextConstraints:hasNextPage];
    return cell;
}

- (NSMutableAttributedString*)midLineStr:(NSString*)str lineStr:(NSString*)lineStr{
    if (!str || !lineStr) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSRange range = [str rangeOfString:lineStr];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    [attr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid) range:range];
    //    [attr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, str.length)];
    return attr;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[KQPayDetailCell class]]) {
        cell.hidden = NO;
        if ([self isRowShouldHide:indexPath]) {
            cell.hidden = YES;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    KQPayDetailInfoType cellType = [self getCellType:[self.titleArray objectAtIndex:indexPath.row]];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(selectColumn:)]) {
        [self.delegate selectColumn:cellType];
    }
}

- (NSMutableAttributedString*)payTipStr:(NSString*)payStatus{
    NSMutableAttributedString *mutStr;
    if ([@"1" isEqualToString:payStatus]) {
        //还款 用蓝色字，可点击，点击跳转至安逸花首页
        mutStr = [[NSMutableAttributedString alloc] initWithString:@"您有逾期欠款，请先还款"];
        NSRange rangeBlue = [[mutStr string] rangeOfString:@"还款"];
        [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rangeBlue];
        NSRange rangeRed = [[mutStr string] rangeOfString:@"您有逾期欠款，请先"];
        [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:rangeRed];
    }else if([@"2" isEqualToString:payStatus]){
        //重新申请 用蓝色字，可点击，点击跳转至安逸花申请页面
        mutStr = [[NSMutableAttributedString alloc] initWithString:@"安逸花授信过期，请重新申请"];
        NSRange rangeBlue = [[mutStr string] rangeOfString:@"重新申请"];
        [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:rangeBlue];
        NSRange rangeRed = [[mutStr string] rangeOfString:@"安逸花授信过期，请"];
        [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:rangeRed];
    }else if([@"-1" isEqualToString:payStatus]){
        mutStr = [[NSMutableAttributedString alloc] initWithString:@"尚未开通安逸花，请返回开通"];
        NSRange rangeRed = [[mutStr string] rangeOfString:@"尚未开通安逸花，请返回开通"];
        [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:rangeRed];
    }else {
        mutStr = [[NSMutableAttributedString alloc] initWithString:@"您暂无可用的支付方式"];
        NSRange rangeRed = [[mutStr string] rangeOfString:@"您暂无可用的支付方式"];
        [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:rangeRed];
    }
    return mutStr;
}

- (BOOL)isRowShouldHide:(NSIndexPath *)indexPath {
    if ([self getCellType:[self.titleArray objectAtIndex:indexPath.row]] == KQPayDetailInfoTypeMerchantName) {
        // OMS文案配置(参数名 merchantNameVisible)
        if (self.delegate&&[self.delegate respondsToSelector:@selector(orderInformationShow)]) {
            return ![self.delegate orderInformationShow];
        }
    } else if ([self getCellType:[self.titleArray objectAtIndex:indexPath.row]] == KQPayDetailInfoTypeInstallmentMode) {
        //有分期信息就不隐藏
        if (self.delegate&&[self.delegate respondsToSelector:@selector(hasInstalmentInfo)]) {
            return ![self.delegate hasInstalmentInfo];
        }
    } else if ([self getCellType:[self.titleArray objectAtIndex:indexPath.row]] == KQPayDetailInfoTypeRemark) {
        //备注暂时先隐藏
        return YES;
    } else if ([self getCellType:[self.titleArray objectAtIndex:indexPath.row]] == KQPayDetailInfoTypeVoucher) {// 优惠券
        if (self.delegate&&[self.delegate respondsToSelector:@selector(getCurrentProductCode)]) {
            if ([[self.delegate getCurrentProductCode] isEqualToString:KQPaymentProductCodeTransfer]) {
                return YES;
            }
        }
        
        if ([self.delegate allVouchersCount] == 0) {
            return YES;
        }
        
        if (self.delegate&&[self.delegate respondsToSelector:@selector(canUseVoucher)]) {
            return ![self.delegate canUseVoucher];
            
        }
        
    } else if ([self getCellType:[self.titleArray objectAtIndex:indexPath.row]] == KQPayDetailInfoTypeUPayVoucher){// 银联优惠信息
        return ![self.delegate canUserUPayVoucher];
    } else if ([self getCellType:[self.titleArray objectAtIndex:indexPath.row]] == KQPayDetailInfoTypeExtendOne){
        return [self.delegate maShangVoucherFrom] == KQPayVoucherFromNone;
        
    }else if([self getCellType:[self.titleArray objectAtIndex:indexPath.row]] == KQPayDetailInfoTypeExtendTwo){
        return (([self.delegate maShangVoucherFrom] == KQPayVoucherFromNone)
                ||  ([self.delegate maShangVoucherFrom] == KQPayUnuseVoucher));
    }
    return NO;
}

- (void)confirmClicked
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(confirmPayment:)]) {
        [self.delegate confirmPayment:self];
    }
}

- (void)payDetailLoadingType:(KQPayDetailLoadingType)loadingType {
    [self fingerLoading:loadingType];
}

- (void)reloadData
{
    //由于有优惠券，需要支付的金额也要刷新
    [self.payDetailTableView reloadData];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(isInAppCall)]) {
        //        if (![self.delegate isInAppCall]) {
        //            //第三方调用要显示一个飞凡的icon
        //            [self titleImage:[UIImage imageNamed:@"member_produce1"]];
        //        }
    }
}

- (KQPayDetailInfoType)getCellType:(NSString *)key
{
    return ((KQPayDetailInfoTypeWapper*)[self.cellTypeDic objectForKey:key]).infoType;
}

- (void)viewDidShow {
    [self payButtonHandle];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(needRequestInstalmentInfo:)]) {
        [self.delegate needRequestInstalmentInfo:^{
            [self trialAmtDeal];
        }];
    }
}

- (void)trialAmtDeal{
    if (self.delegate && [self.delegate respondsToSelector:@selector(trialAmt:)]) {
        [self.delegate trialAmt:^{
            [self updateCellInfo];
            [self reloadData];
        }];
    }
}

- (void)payButtonHandle{
    if (self.delegate && [self.delegate respondsToSelector:@selector(payMethodCount)]) {
        self.confirmBtn.enabled = ([self.delegate payMethodCount] > 0);
    }
}

@end
