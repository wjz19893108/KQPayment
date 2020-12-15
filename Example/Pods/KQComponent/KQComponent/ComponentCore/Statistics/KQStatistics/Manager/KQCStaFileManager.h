//
//  KQCStaFileManager.h
//  kuaiQianbao
//
//  Created by lihui on 16/4/1.
//
//

#import <Foundation/Foundation.h>

@interface KQCStaFileManager : NSObject
+ (KQCStaFileManager *)sharedKQCStaFileManager;

/**
 *  埋点文件设置路径
 *
 *  @param path    路径
 *  未设置路径将无法保存文件
 */
- (void)setFilePath:(NSString *)path;


/**
 更新当前写入文件路径，生成新的日志文件
 */
- (void)resetFilePath;

/**
 *  埋点文件持续读写，追加写
 *
 *  @param content    追加内容
 */
- (void)staLivingFileAppend:(NSData *)content;

/**
 *  从文件夹读取埋点文件
 *
 *  @return 二进制流
 */
- (NSData *)staData;

/**
 *  清除发送成功的埋点数据
 *
 */
- (void)deleteAllStaData;

/**
 *  保存闪退数据(集成环境)
 *
 */
- (void)saveCrashData:(NSString *)data;

@end
