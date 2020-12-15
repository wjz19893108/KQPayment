//
//  KQHttpSwipeCardDataSource.h
//  AFNetworking
//
//  Created by tian qing on 2018/12/18.
//

#import <Foundation/Foundation.h>
#import "KQSwipeCardHttpDataSource.h"

@interface KQHttpSwipeCardDataSource : NSObject<KQSwipeCardHttpDataSource>

+ (nonnull KQHttpSwipeCardDataSource *)sharedKQHttpSwipeCardDataSource;

@end
