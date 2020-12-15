//
//  KQCOPFileEngine.m
//  KQCore
//
//  Created by pengkang on 2016/10/19.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBOPFileEngine.h"

@interface KQBOPFileEngine ()

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation KQBOPFileEngine

/**
 *  初始化&创建NSFileHandle
 *
 *  @param filePath 文件路径
 *
 *  @return 类实例
 */
- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        [self open:filePath];
    }
    return self;
}

/**
 *  追加数据至文件末尾
 *
 *  @param content 数据
 */
- (void)appendData:(NSData *)content {
    if (_fileHandle && content && [content length] > 0) {
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
            [self close];
            [self open:_filePath];
        }
        
        [_fileHandle seekToEndOfFile];
        [_fileHandle writeData:content];
    }
}

/**
 *  当前打开文件大小体积
 *
 *  @return 体积
 */
- (unsigned long long)size {
    unsigned long long ofset = 0;
    if (_fileHandle) {
        unsigned long long pos = [_fileHandle offsetInFile];
        [_fileHandle seekToEndOfFile];
        ofset = [_fileHandle offsetInFile];
        [_fileHandle seekToFileOffset:pos];
    }
    return ofset;
}

/**
 *  打开文件
 *
 *  @param filePath 文件路径
 */
- (void)open:(NSString *)filePath {
    if (![NSString kqc_isBlank:filePath]) {
        [self close];
        _filePath   = filePath;
        
        [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    }
}

/**
 *  关闭文件读写功能
 */
- (void)close {
    if (_fileHandle) {
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
}

@end
