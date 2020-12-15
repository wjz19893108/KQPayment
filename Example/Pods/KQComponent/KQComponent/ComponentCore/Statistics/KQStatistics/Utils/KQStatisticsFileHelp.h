//
//  KQStatisticsFileHelp.h
//  KQComponent
//
//  Created by wangping on 2018/6/11.
//

#import <Foundation/Foundation.h>

@interface KQStatisticsFileHelp : NSObject

// 文件路径
@property (nonatomic, copy) NSString *filePath;

/**
 *  初始化&创建NSFileHandle
 *
 *  @param filePath 文件路径
 *
 *  @return 类实例
 */
- (instancetype)initWithFilePath:(NSString *)filePath;

/**
 *  追加数据至文件末尾
 *
 *  @param content 数据
 */
- (void)appendData:(NSData *)content;

/**
 *  当前打开文件大小体积
 *
 *  @return 体积
 */
- (unsigned long long)size;

/**
 *  打开文件
 *
 *  @param filePath 文件路径
 */
- (void)open:(NSString *)filePath;

/**
 *  关闭文件读写功能
 */
- (void)close;

+ (BOOL)removeFile:(NSString *)filePath;
+ (long long)sizeAtPath:(NSString *)path;

@end
