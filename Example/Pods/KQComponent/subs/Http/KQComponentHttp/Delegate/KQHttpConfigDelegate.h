//
//  KQHttpConfigDelegate.h
//  Pods
//
//  Created by pengkang on 2019/1/16.
//


#import <Foundation/Foundation.h>

@protocol KQHttpConfigDelegate <NSObject>

@optional

- (NSString *)sourceId;

- (NSString *)swipeSourceId;

@end
