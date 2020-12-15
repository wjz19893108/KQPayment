//
//  KQBCacheSecureDelegate.h
//  KQComponentCache
//
//  Created by xy on 2017/11/20.
//  Copyright © 2017年 99bill. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KQBCacheSecureDelegate <NSObject>

@optional
- (NSString *)encryptDataByAES:(NSData *)plainData;

- (NSData *)decryptDataByAES:(NSString *)cipherStr;

@end
