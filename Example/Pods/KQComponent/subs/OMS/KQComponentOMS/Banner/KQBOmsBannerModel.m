//
//  KQBOmsBannerModel.m
//  kuaiQianbao
//
//  Created by pengkang on 16/1/5.
//
//

#import "KQBOmsBannerModel.h"
#import <objc/runtime.h>

@implementation KQBOmsBannerModel

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([KQBOmsBannerModel class], &count);
        for (int i = 0; i < count; ++i) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *keyName = KQC_FORMAT(@"%s", name);
            if (configDic[keyName]) {
                [self setValue:configDic[keyName] forKey:keyName];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.functionName forKey:@"functionName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.functionName = [aDecoder decodeObjectForKey:@"functionName"];
    }
    return self;
}

@end
