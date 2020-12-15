//
//  KQCMath.m
//  KQCore
//
//  Created by xy on 2016/10/14.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQCMath.h"

@implementation KQCMath

+ (int)getRandomNumber:(int)from to:(int)to{
    int intVal = (int)(from + (arc4random() % (to-from+1)));
    return intVal;
}

+ (NSData *)int2Bytes:(int)value{
    unsigned char src[4] = {0};
    src[3] = (unsigned char) ((value>>24) & 0xFF);
    src[2] = (unsigned char) ((value>>16)& 0xFF);
    src[1] = (unsigned char) ((value>>8)&0xFF);
    src[0] = (unsigned char) (value & 0xFF);
    return [NSData dataWithBytes:src length:4];
}

+ (int)bytes2Int:(unsigned char *)src offset:(int)offset{
    int value;
    value = (int) ((src[offset] & 0xFF)
                   | ((src[offset+1] & 0xFF)<<8)
                   | ((src[offset+2] & 0xFF)<<16)
                   | ((src[offset+3] & 0xFF)<<24));
    return value;
}

@end
