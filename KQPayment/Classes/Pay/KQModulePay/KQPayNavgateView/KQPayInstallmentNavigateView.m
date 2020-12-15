//
//  KQPayInstallmentNavigateView.m
//  kuaiQianbao
//
//  Created by zouf on 16/1/14.
//
//

#import "KQPayInstallmentNavigateView.h"
#import "KQPayInstallmentCell.h"


@interface KQPayInstallmentNavigateView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *installmentTableView;

@end

@implementation KQPayInstallmentNavigateView

- (instancetype __nullable)init
{
    self = [super initWithTitle:@"请选择分期方式"];
    if (self) {
        //创建table，显示付款方式选择等
        CGFloat mainViewHeight = self.mainView.height;
        self.installmentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KQPAYSUBVIEW_START_Y_POS, KQC_SCREEN_WIDTH, mainViewHeight - KQPAYSUBVIEW_START_Y_POS) style:UITableViewStylePlain];
        self.installmentTableView.backgroundView = nil;
        self.installmentTableView.backgroundColor = [UIColor clearColor];
        self.installmentTableView.dataSource = self;
        self.installmentTableView.delegate = self;
        self.installmentTableView.separatorColor = [UIColor clearColor];
        [self.mainView addSubview:self.installmentTableView];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(installmentCount)]) {
        return [self.delegate installmentCount];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KQPAY_INSTALLMENT_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KQPayInstallmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KQPayInstallmentCellIdentifier"];
    if(cell == nil)
    {
        cell = [[KQPayInstallmentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:@"KQPayInstallmentCellIdentifier"];
    }

    if (self.delegate&&[self.delegate respondsToSelector:@selector(installmentInfo:resultBlock:)]) {
        [self.delegate installmentInfo:indexPath.row resultBlock:^(NSString * _Nullable rate, NSString * _Nullable cost, NSString * _Nullable total, BOOL selected) {
            [cell setNumText:rate];
            [cell setPerText:cost];
            [cell setSumText:total];
            if (selected) {
                cell.selectedImage.hidden = NO;
            }
            else {
                cell.selectedImage.hidden = YES;
            }
        }];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(selectInstallment:)]) {
        [self.delegate selectInstallment:indexPath.row];
        [self.installmentTableView reloadData];
    }
}

- (void)viewDidShow {
    [self.installmentTableView reloadData];
}

@end
