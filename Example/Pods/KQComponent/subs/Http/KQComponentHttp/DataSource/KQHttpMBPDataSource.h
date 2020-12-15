//
//  KQHttpMBPDataSource.h
//  KQComponent
//
//  Created by xy on 2018/7/31.
//

#import <Foundation/Foundation.h>
#import "KQHttpDataSource.h"

@interface KQHttpMBPDataSource : NSObject<KQHttpDataSource>

+ (nonnull KQHttpMBPDataSource *)sharedKQHttpMBPDataSource;

@end
