//
//  KQCSecureKeyGroup.m
//  KQProtocol
//
//  Created by xy on 2017/3/7.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQPSecureKeyGroup.h"

@implementation KQPSecureKeyGroup

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        // 仅保存这些需要这些
        self.clientPrivateKey = [aDecoder decodeObjectForKey:@"clientPrivateKey"];
        self.serverPublicKey = [aDecoder decodeObjectForKey:@"serverPublicKey"];
        self.aesKey = [aDecoder decodeObjectForKey:@"aesKey"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.clientPrivateKey forKey:@"clientPrivateKey"];
    [aCoder encodeObject:self.serverPublicKey forKey:@"serverPublicKey"];
    [aCoder encodeObject:self.aesKey forKey:@"aesKey"];
}

@end
