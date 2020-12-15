//
//  KQCMath.h
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQCMath : NSObject

/**
 获取随机数

 @param from 下限
 @param to 上限
 @return 区间内的随机数
 */
+ (int)getRandomNumber:(int)from to:(int)to;

/**
 将int转为4位的byte数组，低位在前，如1转完后变0x01 0x00 0x00 0x00

 @param value 待转数字
 @return 字节流
 */
+ (NSData *)int2Bytes:(int)value;

/**
 将字节流转为int，低位在前

 @param src 字节流
 @param offset 位移
 @return 数字
 */
+ (int)bytes2Int:(unsigned char *)src offset:(int)offset;

@end
