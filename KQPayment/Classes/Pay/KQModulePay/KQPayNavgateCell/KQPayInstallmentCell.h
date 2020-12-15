//
//  KQPayInstallmentCell.h
//  kuaiQianbao
//
//  Created by zouf on 16/1/14.
//
//

#import <UIKit/UIKit.h>

@interface KQPayInstallmentCell : UITableViewCell

@property (nonatomic, strong, readonly) UIImageView *selectedImage; //选中图片

- (void)setNumText:(NSString*)text;
- (void)setPerText:(NSString*)text;
- (void)setSumText:(NSString*)text;

@end
