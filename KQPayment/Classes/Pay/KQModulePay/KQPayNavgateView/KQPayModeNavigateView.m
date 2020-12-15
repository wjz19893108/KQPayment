//
//  KQPayModeNavigateView.m
//  kuaiQianbao
//
//  Created by zouf on 15/11/30.
//  Copyright © 2015年 program. All rights reserved.
//


#import "KQPayModeNavigateView.h"
#import "KQPayModeCell.h"
#import "KQPaymentMacro.h"
#import "KQInstallmentAdapter.h"

@interface KQPayModeNavigateView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *payModeTableView;

@end

@implementation KQPayModeNavigateView

- (instancetype __nullable)init
{
    self = [super initWithTitle:@"选择付款方式"];
    if (self) {
        //创建table，显示付款方式选择等
        CGFloat mainViewHeight = self.mainView.height;
        self.payModeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KQPAYSUBVIEW_START_Y_POS, KQC_SCREEN_WIDTH, mainViewHeight - KQPAYSUBVIEW_START_Y_POS) style:UITableViewStylePlain];
        self.payModeTableView.backgroundView = nil;
        self.payModeTableView.backgroundColor = [UIColor clearColor];
        self.payModeTableView.dataSource = self;
        self.payModeTableView.delegate = self;
        self.payModeTableView.separatorColor = [UIColor clearColor];
        [self.mainView addSubview:self.payModeTableView];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(payMethodCount)]&&[self.delegate respondsToSelector:@selector(payMethodDisabledCount)]) {
        return [self.delegate payMethodCount] + [self.delegate payMethodDisabledCount] + 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block BOOL maShangType = NO;
    if ([self.delegate respondsToSelector:@selector(maShangCell:resultBlock:)]) {
        [self.delegate maShangCell:indexPath.row resultBlock:^(BOOL maShang) {
            maShangType = maShang;
        }];
    }
    
    if (maShangType) {
        return 60 + kAdapterHeight;
    }
    
    if ([self isRowShouleHide:indexPath]) {
        return 0;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[KQPayModeCell class]]) {
        cell.hidden = NO;
        if ([self isRowShouleHide:indexPath]) {
            cell.hidden = YES;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KQPayModeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KQPayModeIdentifier"];
    if(cell == nil)
    {
        cell = [[KQPayModeCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:@"KQPayModeIdentifier"];
    }
    [cell hiddeInstallment:YES];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(payMethodCount)]) {
        if (indexPath.row == [self.delegate payMethodCount]) {
            //可用和不可用之间：使用其他银行卡支付
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.maskView.hidden = YES;
            [cell cellTypeAddOtherBankCard];
            cell.selectedImage.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            if (indexPath.row < [self.delegate payMethodCount]) {
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.maskView.hidden = YES;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.maskView.hidden = NO;
            }
            if ([self.delegate respondsToSelector:@selector(payMethodInfo:resultBlock:)]) {
                [self.delegate payMethodInfo:indexPath.row resultBlock:^(NSString * _Nullable payType, NSString * _Nullable bankId, NSString * _Nullable displayName, NSString * _Nullable limitInfo, NSString * _Nullable icon, BOOL selected, BOOL showIcon,  NSString * activityMsg) {
                    
                    [cell cellTypePayMethod:payType bankId:bankId displayName:displayName limitInfo:limitInfo icon:icon showIcon:showIcon activityMsg:activityMsg];
                    if (selected) {
                        cell.selectedImage.hidden = NO;
                    } else {
                        cell.selectedImage.hidden = YES;
                    }
                    
                    //马上金服 分期信息
                    if ([KQPayMethodPayTypeMaShang isEqualToString:payType] &&
                        [self.delegate respondsToSelector:@selector(installmentInfos:resultBlock:)]) {
                        //可用时 显示分期信息
                        if (self.delegate&&[self.delegate respondsToSelector:@selector(payMethodCount)]) {
                            if (indexPath.row > [self.delegate payMethodCount]) {
                                [cell hiddeInstallment:YES];
                            }else{
                                [self.delegate installmentInfos:KQPayMethodPayTypeMaShang resultBlock:^(NSArray * _Nullable installments, NSString * _Nullable defaultInstallment, BOOL selected) {
                                    [cell installmentInfo:installments defaultInstallment:defaultInstallment clickDone:^(NSInteger choiceInstal,BOOL popFlag) {
                                        if (self.delegate&&[self.delegate respondsToSelector:@selector(selectInstallment:popFlag:)]) {
                                            [self.delegate selectInstallment:choiceInstal popFlag:popFlag];
                                        }
                                    }];
                                    
                                    [cell hiddeInstallment:selected?NO:YES];
                                }];
                            }
                        }
                    }
                }];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (self.delegate&&[self.delegate respondsToSelector:@selector(payMethodCount)]) {
        if (indexPath.row == [self.delegate payMethodCount]) {
            if ([self.delegate respondsToSelector:@selector(addNewCard)]) {
                [self.delegate addNewCard];
            }
        } else if (indexPath.row < [self.delegate payMethodCount]) {
            if ([self.delegate respondsToSelector:@selector(selectPayMethod:)]) {
                [self.delegate selectPayMethod:indexPath.row];
                [self.payModeTableView reloadData];
            }
        } else {
            //禁用的支付方式不可选
        }
    }
}

- (BOOL)isRowShouleHide:(NSIndexPath *)indexPath {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(payMethodCount)]) {
        if (indexPath.row == [self.delegate payMethodCount]) {
            if ([self.delegate respondsToSelector:@selector(canBindCard)]) {
                if (![self.delegate canBindCard]) {
                    //支持的支付方式没有银行卡和信用卡，添加其他卡片要隐藏起来
                    return YES;
                }
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(payMethodShouldHide:)]) {
        return [self.delegate payMethodShouldHide:indexPath.row];
    }
    return NO;
}

- (void)viewDidShow {
    [self.payModeTableView reloadData];
}

@end
