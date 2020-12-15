//
//  KQPayVoucherNavigateView.m
//  kuaiQianbao
//
//  Created by zouf on 16/4/16.
//
//

#import "KQPayVoucherNavigateView.h"
#import "KQPayVoucherCell.h"

#define START_MAT_LINE      4       //最开始显示4行


@interface KQPayVoucherNavigateView () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *voucherTableView;
@property (nonatomic, assign) NSInteger maxLine;                //最开始一次显示多少行
@property (nonatomic, strong) UIView *moreVoucherView;          //查看更多的券

@end

@implementation KQPayVoucherNavigateView

- (instancetype __nullable)init
{
    self = [super initWithTitle:@"选择优惠券"];
    if (self) {
        self.maxLine = START_MAT_LINE;
        CGFloat mainViewHeight = self.mainView.height;
        self.voucherTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KQPAYSUBVIEW_START_Y_POS, KQC_SCREEN_WIDTH, mainViewHeight - KQPAYSUBVIEW_START_Y_POS) style:UITableViewStylePlain];
        self.voucherTableView.backgroundView = nil;
        self.voucherTableView.backgroundColor = UIColorFromRGB(0xf2, 0xf2, 0xf2);
        self.voucherTableView.dataSource = self;
        self.voucherTableView.delegate = self;
        self.voucherTableView.separatorColor = [UIColor clearColor];
        [self.mainView addSubview:self.voucherTableView];
        
        self.moreVoucherView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KQC_SCREEN_WIDTH, KQPAY_MORE_VOUCHER_FOOTER_HEIGHT)];
        //直接设置tableFooterView，不存在始终在tableView底部的问题
        self.voucherTableView.tableFooterView = self.moreVoucherView;
        UILabel *moreVoucherLabel = [UILabel addLabel:@"查看更多的券" frame:CGRectZero size:15 isBold:NO textAlignment:NSTextAlignmentCenter textColor:UIColorFromRGB(0x29, 0x8b, 0xeb) tag:(int)KQPAYSUBVIEW_LABEL_TAG intoView:self.moreVoucherView];
        [moreVoucherLabel sizeToFit];
        [moreVoucherLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(self.moreVoucherView);
            make.centerY.equalTo(self.moreVoucherView);
        }];
        UIButton *moreVoucherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreVoucherButton addTarget:self action:@selector(moreVoucherClick) forControlEvents:UIControlEventTouchUpInside];
        [self.moreVoucherView addSubview:moreVoucherButton];
        [moreVoucherButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.moreVoucherView);
            make.right.equalTo(self.moreVoucherView);
            make.top.equalTo(self.moreVoucherView);
            make.bottom.equalTo(self.moreVoucherView);
        }];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.payViewStep == KQPayViewStepVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voucherEnableCount)]&&[self.delegate respondsToSelector:@selector(voucherDisableCount)]) {
            NSInteger lineCount = [self.delegate voucherEnableCount] + [self.delegate voucherDisableCount];
            return (lineCount > self.maxLine?self.maxLine:lineCount);
        }
    }
    else if (self.payViewStep == KQPayViewStepAllVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voucherAllCount)]) {
            NSInteger lineCount = [self.delegate voucherAllCount];
            return (lineCount > self.maxLine?self.maxLine:lineCount);
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KQPAY_VOUCHER_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KQPayVoucherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KQPayVoucherCellIdentifier"];
    if(cell == nil)
    {
        cell = [[KQPayVoucherCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"KQPayVoucherCellIdentifier"];
    }
    
    if (self.payViewStep == KQPayViewStepVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voucherInfo:resultBlock:)]) {
            [self.delegate voucherInfo:indexPath.row resultBlock:^(NSString * _Nullable voucherInfo, NSString * _Nullable name, NSString * _Nullable expDate, KQPayVoucherType payVoucherType, BOOL enable, BOOL selected, KQPayVoucherSourceFrom sourceFrom) {
                [cell voucherInfo:voucherInfo name:name expDate:expDate voucherType:payVoucherType sourceFrom:sourceFrom];
                cell.payVoucherType = payVoucherType;
                cell.payVoucherEnable = enable;
                cell.payVoucherSelected = selected;
                cell.selectionStyle = enable?UITableViewCellSelectionStyleGray:UITableViewCellSelectionStyleNone;
            }];
        }
    }
    else if (self.payViewStep == KQPayViewStepAllVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(allVoucherInfo:resultBlock:)]) {
            [self.delegate allVoucherInfo:indexPath.row resultBlock:^(NSString * _Nullable voucherInfo, NSString * _Nullable name, NSString * _Nullable expDate, KQPayVoucherType payVoucherType, BOOL enable, BOOL selected, KQPayVoucherSourceFrom sourceFrom) {
                [cell voucherInfo:voucherInfo name:name expDate:expDate voucherType:payVoucherType sourceFrom:sourceFrom];
                cell.payVoucherType = payVoucherType;
                cell.payVoucherEnable = enable;
                cell.payVoucherSelected = selected;
                cell.selectionStyle = enable?UITableViewCellSelectionStyleGray:UITableViewCellSelectionStyleNone;
            }];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.payViewStep == KQPayViewStepVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(selectVoucher:)]) {
            [self.delegate selectVoucher:indexPath.row];
            [self.voucherTableView reloadData];
        }
    }
}

- (void)moreVoucherClick
{
    self.maxLine += START_MAT_LINE;
    NSInteger lineCount = 0;
    if (self.payViewStep == KQPayViewStepVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voucherEnableCount)]&&[self.delegate respondsToSelector:@selector(voucherDisableCount)]) {
            lineCount = [self.delegate voucherEnableCount] + [self.delegate voucherDisableCount];
        }
    }
    else if (self.payViewStep == KQPayViewStepAllVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voucherAllCount)]) {
            lineCount = [self.delegate voucherAllCount];
        }
    }
    if (self.maxLine >= lineCount) {
        self.voucherTableView.tableFooterView.hidden = YES;
    }
    [self.voucherTableView reloadData];
}

- (void)reloadData {
    NSInteger lineCount = 0;
    if (self.payViewStep == KQPayViewStepVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voucherEnableCount)]&&[self.delegate respondsToSelector:@selector(voucherDisableCount)]) {
            lineCount = [self.delegate voucherEnableCount] + [self.delegate voucherDisableCount];
        }
    }
    else if (self.payViewStep == KQPayViewStepAllVoucher) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(voucherAllCount)]) {
            lineCount = [self.delegate voucherAllCount];
        }
    }
    if (self.maxLine >= lineCount) {
        self.voucherTableView.tableFooterView.hidden = YES;
    }
    [self.voucherTableView reloadData];
}

- (void)viewDidShow {
    [self reloadData];
}

@end

