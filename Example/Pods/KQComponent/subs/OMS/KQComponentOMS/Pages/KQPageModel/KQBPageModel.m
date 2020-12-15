//
//  KQOmsPage.m
//  kuaiQianbao
//
//  Created by pengkang on 16/3/8.
//
//

#import "KQBPageModel.h"
#import "KQBOmsPageModel.h"
@implementation KQBPageModel
{
    NSString *resHome;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.pageNo forKey:@"pageNo"];
    [aCoder encodeObject:self.pageInterface forKey:@"pageInterface"];
    [aCoder encodeObject:self.resourceId forKey:@"resourceId"];
    [aCoder encodeObject:self.contentArray forKey:@"contentArray"];
    [aCoder encodeInteger:self.pageStatus forKey:@"pageStatus"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.pageInterface = [aDecoder decodeObjectForKey:@"pageInterface"];
        self.resourceId = [aDecoder decodeObjectForKey:@"resourceId"];
        self.contentArray = [aDecoder decodeObjectForKey:@"contentArray"];
        self.pageStatus = [aDecoder decodeIntegerForKey:@"pageStatus"];
        self.pageNo = [aDecoder decodeObjectForKey:@"pageNo"];
    }
    return self;
}
@end
