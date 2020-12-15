//
//  KQBMatrixModel.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBMatrixModel.h"

@implementation KQBMatrixModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cols forKey:@"cols"];
    [aCoder encodeObject:self.rows forKey:@"rows"];

}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.cols = [aDecoder decodeObjectForKey:@"cols"];
        self.rows = [aDecoder decodeObjectForKey:@"rows"];

    }
    return self;
}

@end
