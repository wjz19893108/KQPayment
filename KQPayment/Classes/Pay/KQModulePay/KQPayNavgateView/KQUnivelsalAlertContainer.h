//
//  KQUnivelsalAlertContainer.h
//  kuaiQianbao
//
//  Created by zouf on 16/7/19.
//
//

#import <UIKit/UIKit.h>

#define UnivelsalAlertContainer [KQUnivelsalAlertContainer sharedKQUnivelsalAlertContainer]

@interface KQUnivelsalAlertContainer : NSObject

+ (instancetype __nullable)sharedKQUnivelsalAlertContainer;

- (void)dismissAllUnivelsalAlert;

- (void)addUIAlertView:(UIAlertView * __nonnull)alertView;

@end
