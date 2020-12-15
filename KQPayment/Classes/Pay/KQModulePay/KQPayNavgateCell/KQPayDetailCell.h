//
//  KQPayDetailCell.h
//  kuaiQianbao
//
//  Created by zouf on 15/11/28.
//  Copyright © 2015年 program. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KQPayDetailCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *labelInfo;
@property (nonatomic, strong, readonly) UILabel *labelRight;

- (void)labelRightTextColor:(UIColor*)color;
- (void)labelLeftTextColor:(UIColor*)color;
- (void)updateLabelRightTextConstraints:(BOOL)hasNextPage;
- (void)updateLabelActivityConstraints:(NSString *)activityMsg hasActivity:(BOOL)hasActivity isShown:(BOOL)isShown;

@end
