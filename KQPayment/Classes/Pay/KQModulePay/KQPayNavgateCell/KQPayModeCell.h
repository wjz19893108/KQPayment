//
//  KQPayModeCell.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/30.
//  Copyright © 2015年 program. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KQPayModeCell : UITableViewCell

@property (nonatomic, strong, readonly) UIImageView *selectedImage; //选中图片
@property (nonatomic, strong, readonly) UIView *maskView;           //不可用支付方式蒙版

- (void)cellTypeAddOtherBankCard;
- (void)cellTypePayMethod:(NSString *)payType bankId:(NSString *)bankId displayName:(NSString *)displayName limitInfo:(NSString *)limitInfo icon:(NSString *)icon showIcon:(BOOL)showIcon activityMsg:(NSString *)activityMsg;
- (void)installmentInfo:(NSArray*)installemnts defaultInstallment:defaultInfo clickDone:(void(^)(NSInteger  choiceInstal,BOOL popFlag))stalmentClickBlock;
- (void)hiddeInstallment:(BOOL)flag;

@end
