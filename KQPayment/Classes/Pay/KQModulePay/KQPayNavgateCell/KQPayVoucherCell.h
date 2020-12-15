//
//  KQPayVoucherCell.h
//  kuaiQianbao
//
//  Created by zouf on 16/4/16.
//
//

#import <UIKit/UIKit.h>
#import "KQPayOrderDataProcess.h"

@class KQPayVoucher;

@interface KQPayVoucherCell : UITableViewCell

@property (nonatomic, assign) BOOL payVoucherEnable;                    //优惠券是否可用
@property (nonatomic, assign) KQPayVoucherType payVoucherType;          //主动or被动权益
@property (nonatomic, assign) BOOL payVoucherSelected;                  //优惠券是否选中

- (void)voucherInfo:(NSString *)voucherInfo name:(NSString *)name expDate:(NSString *)expDate voucherType:(NSInteger)voucherType sourceFrom:(KQPayVoucherSourceFrom)sourceFrom;

@end
