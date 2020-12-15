//
//  KQOmsReqModel.m
//  kuaiQianbao
//
//  Created by pengkang on 16/1/5.
//
//

#import "KQBOmsConfigData.h"
#import <objc/runtime.h>

#define OmsResourceTypeDescription      @"7"
#define OmsResourceTypeFunctionSwitch   @"8"
#define OmsResourceTypeH5               @"9"
#define OmsResourceTypeCityList         @"18"

@implementation KQBOmsConfigData

- (instancetype)initWithObj:(ContentResourceInfo *)resourceInfo{
    self = [super init];
    if (self) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([ContentResourceInfo class], &count);
        for (int i = 0; i < count; ++i) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *keyName = KQC_FORMAT(@"%s", name);
            id value = [resourceInfo valueForKey:keyName];
            if (value) {
                [self setValue:value forKey:keyName];
            }
        }
    }
    
    if ([NSString kqc_isBlank:_resourceId]) {
        return nil;
    }
    return self;
}

- (instancetype)initWithZip:(ContentCommonZipInfo *)commonZip{
    self = [super init];
    if (self) {
        self.resourceId = commonZip.commonZipId;
        self.resourceName = commonZip.commonZipName;
        self.resourceUrl = commonZip.commonZipUrl;
        self.md5 = commonZip.md5;
        
        if ([self.resourceId isEqualToString:@"301"]) {
            self.resourceType = OmsResourceTypeDescription;
        }
        
        if ([self.resourceId isEqualToString:@"302"]) {
            self.resourceType = OmsResourceTypeFunctionSwitch;
        }
        
        if ([self.resourceId isEqualToString:@"303"]) {
            self.resourceType = OmsResourceTypeH5;
        }
        
        if ([self.resourceId isEqualToString:@"304"]) {
            self.resourceType = OmsResourceTypeCityList;
        }
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.resourceId forKey:@"resourceId"];
    [aCoder encodeObject:self.resourceName forKey:@"resourceName"];
    [aCoder encodeObject:self.resourceUrl forKey:@"resourceUrl"];
    [aCoder encodeObject:self.resourceVersion forKey:@"resourceVersion"];
    [aCoder encodeObject:self.isCaseUser forKey:@"isCaseUser"];
    [aCoder encodeObject:self.isIncrement forKey:@"isIncrement"];
    [aCoder encodeObject:self.md5 forKey:@"md5"];
    [aCoder encodeObject:self.resourceDirectory forKey:@"resourceDirectory"];
    [aCoder encodeObject:self.resStatus forKey:@"resStatus"];
    [aCoder encodeObject:self.resourceType forKey:@"resourceType"];
    [aCoder encodeObject:self.resFrom forKey:@"resFrom"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.resourceId = [aDecoder decodeObjectForKey:@"resourceId"];
        self.resourceName = [aDecoder decodeObjectForKey:@"resourceName"];
        self.resourceUrl = [aDecoder decodeObjectForKey:@"resourceUrl"];
        self.resourceVersion = [aDecoder decodeObjectForKey:@"resourceVersion"];
        self.isCaseUser = [aDecoder decodeObjectForKey:@"isCaseUser"];
        self.isIncrement = [aDecoder decodeObjectForKey:@"isIncrement"];
        self.md5 = [aDecoder decodeObjectForKey:@"md5"];
        self.resourceDirectory = [aDecoder decodeObjectForKey:@"resourceDirectory"];
        self.resStatus = [aDecoder decodeObjectForKey:@"resStatus"];
        self.resourceType = [aDecoder decodeObjectForKey:@"resourceType"];
        self.resFrom = [aDecoder decodeObjectForKey:@"resFrom"];
    }
    return self;
}

@end
