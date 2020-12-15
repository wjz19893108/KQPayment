//
//  KQBSecureCacheDelegate.h
//  KQComponentSecure
//
//  Created by xy on 2017/11/9.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KQPSecureKeyGroup;
@protocol KQBSecureCacheDelegate <NSObject>

@optional
- (KQPSecureKeyGroup *)loadSecureDataCache;

- (void)saveSecureDataCache:(KQPSecureKeyGroup *)keyGroup;

@end
