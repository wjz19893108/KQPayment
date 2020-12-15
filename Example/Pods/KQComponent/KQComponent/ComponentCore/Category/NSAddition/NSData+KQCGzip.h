//
//  NSData+Gzip.h
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import <Foundation/Foundation.h>

@interface NSData(GzipData)

/**
 解压

 @return 数据流
 */
- (NSData *)kqc_gzipInflate;

/**
 压缩

 @return 数据流
 */
- (NSData *)kqc_gzipDeflate;

@end
