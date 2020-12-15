//
//  KQShareView.h
//  kuaiQianbao
//
//  Created by building wang on 15/8/19. Modified by zouf on 15/11/3.
//
//

#import <UIKit/UIKit.h>
#import "KQBShareMacro.h"

@interface KQBShareView : UIView

@property (nonatomic, strong) KQCShareData *shareData;
@property (nonatomic, copy) ShareSelectedBlock selectedBlock;
@property (nonatomic, copy) ShareViewSelectedBlock selectedViewBlock;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title shareData:(KQCShareData *)data;
- (void)show;
- (void)dismiss;

@end
