//
//  KQBasePayView.m
//  kuaiQianbao
//
//  Created by zouf on 16/1/18.
//
//

/*
 这个类模拟了整个页面，包含了关闭事件closeView
 */

#import "KQBasePayView.h"


@implementation KQBasePayView

- (void)viewDidShow {
    
}

-(void)closeView:(id)sender
{
    [self willInvokeCloseBlock];
}

- (void)willInvokeCloseBlock
{
    [self previousStep];
}

- (CGSize)getMoveSizeWhenKeyboardShow:(CGSize)keyboardSize {
    return CGSizeZero;
}

- (void)previousStep {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(back:)]) {
        [self.delegate back:self.payViewStep];
    }
}

@end
