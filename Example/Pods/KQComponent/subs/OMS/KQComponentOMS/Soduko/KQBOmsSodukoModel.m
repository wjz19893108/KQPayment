//
//  KQBOmsSodukoModel.m
//  kuaiQianbao
//
//  Created by pengkang on 16/9/15.
//
//

#import "KQBOmsSodukoModel.h"
#import <objc/runtime.h>
//#import "KQBFunctionSwitchManager.h"

//#define checkWhiteListLoopInit      @"0"
//#define checkWhiteListLoopEnd       @"1"
//#define checkWhiteListResultSuc     @"2"

@implementation KQBOmsSodukoModel

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([KQBOmsSodukoModel class], &count);
        for (int i = 0; i < count; ++i) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *keyName = KQC_FORMAT(@"%s", name);
            if (configDic[keyName]) {
                [self setValue:configDic[keyName] forKey:keyName];
            }
        }
//        [self checkIfShowTransfer];
    }
    return self;
}

//- (void)checkIfShowTransfer{
//    if (![self.lifeAppAbbrName isEqualToString:@"zhuanzhang"]){
//        return;
//    }
//    
//    if (![FunctionSwitchManager.transferNeedWhiteList isEqualToString:@"1"]){
//        return;
//    }
//    
//    self.isAvailable = KQP_Manager_Protocol.userInfoDelegate.isCreditWhiteList;
//}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.functionName forKey:@"functionName"];
    [aCoder encodeObject:self.isMore forKey:@"isMore"];
    [aCoder encodeObject:self.operationStatus forKey:@"operationStatus"];
    [aCoder encodeObject:self.promotionText forKey:@"promotionText"];
    [aCoder encodeObject:self.lifeAppAbbrName forKey:@"lifeAppAbbrName"];
    [aCoder encodeObject:self.messageText forKey:@"messageText"];
    [aCoder encodeObject:self.resDesc forKey:@"resDesc"];
    [aCoder encodeObject:self.index forKey:@"index"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.functionName = [aDecoder decodeObjectForKey:@"functionName"];
        self.isMore = [aDecoder decodeObjectForKey:@"isMore"];
        self.operationStatus = [aDecoder decodeObjectForKey:@"operationStatus"];
        self.promotionText = [aDecoder decodeObjectForKey:@"promotionText"];
        self.lifeAppAbbrName = [aDecoder decodeObjectForKey:@"lifeAppAbbrName"];
        self.messageText = [aDecoder decodeObjectForKey:@"messageText"];
        self.resDesc = [aDecoder decodeObjectForKey:@"resDesc"];
        self.index = [aDecoder decodeObjectForKey:@"index"];
    }
    return self;
}

@end
