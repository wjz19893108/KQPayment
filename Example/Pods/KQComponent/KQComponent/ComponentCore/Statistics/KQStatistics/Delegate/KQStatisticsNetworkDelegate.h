//
//  KQStatisticsUserDelegate.h
//  KQComponent
//
//  Created by wangping on 2018/6/11.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@protocol KQStatisticsNetworkDelegate <NSObject>


- (void)setupSecurityPolicy:(AFURLSessionManager *)manager;

//- (NSString *)statisticsRequestURL:(NSString *)netType;

@end
