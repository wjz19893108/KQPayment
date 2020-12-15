//
//  KQOmsAdvPageModel.m
//  kuaiQianbao
//
//  Created by pengkang on 16/1/14.
//
//

#import "KQBOmsAdvPageModel.h"
#import <objc/runtime.h>

@implementation KQBOmsAdvPageModel

-(instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([KQBOmsAdvPageModel class], &count);
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

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (UIImage *)image{
    NSString *imagePath =  KQC_FORMAT(@"%@/%@%@", [KQBCacheManager directoryPath:KQCahceTypeUserOms],self.resHome, self.resDiretory);
    UIImage * tmpImage = [UIImage imageWithContentsOfFile:imagePath];
    return  tmpImage;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.showTime forKey:@"showTime"];
    [aCoder encodeObject:self.isCanSkip forKey:@"isCanSkip"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.showTime = [aDecoder decodeObjectForKey:@"showTime"];
        self.isCanSkip = [aDecoder decodeObjectForKey:@"isCanSkip"];
    }
    return self;
}

@end
