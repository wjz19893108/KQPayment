//
//  KQBSodukoModel.m
//  KQBusiness
//
//  Created by pengkang on 2016/11/29.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "KQBSodukoModel.h"

@implementation KQBSodukoModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.columnsPerRow forKey:@"columnsPerRow"];
    [aCoder encodeObject:self.optionType forKey:@"optionType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.columnsPerRow = [aDecoder decodeObjectForKey:@"columnsPerRow"];
        self.optionType = [aDecoder decodeObjectForKey:@"optionType"];
    }
    return self;
}
@end
