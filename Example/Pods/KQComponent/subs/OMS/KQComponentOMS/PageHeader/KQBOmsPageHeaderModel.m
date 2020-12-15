//
//  KQBOmsPageHeaderModel.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBOmsPageHeaderModel.h"

@implementation KQBPageHeaderTitle

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        self.subTitle = configDic[@"subTitle"];
        self.title = configDic[@"title"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subTitle forKey:@"subTitle"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subTitle = [aDecoder decodeObjectForKey:@"subTitle"];
    }
    return self;
}

@end

@implementation KQBPageHeaderButton

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        self.bgColor = [UIColor colorWithHexString:configDic[@"bgColor"]];
        self.fontColor = [UIColor colorWithHexString:configDic[@"fontColor"]];
        self.jumpModel = configDic[@"jumpModel"];
        self.jumpTarget = configDic[@"jumpTarget"];
        self.title = configDic[@"title"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.bgColor forKey:@"bgColor"];
    [aCoder encodeObject:self.fontColor forKey:@"fontColor"];
    [aCoder encodeObject:self.jumpModel forKey:@"jumpModel"];
    [aCoder encodeObject:self.jumpTarget forKey:@"jumpTarget"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.bgColor = [aDecoder decodeObjectForKey:@"bgColor"];
        self.fontColor = [aDecoder decodeObjectForKey:@"fontColor"];
        self.jumpModel = [aDecoder decodeObjectForKey:@"jumpModel"];
        self.jumpTarget = [aDecoder decodeObjectForKey:@"jumpTarget"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end

@implementation KQBPageHeaderBgImage

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        self.imgDiretory = configDic[@"imgDiretory"];
        self.imgUrl = configDic[@"imgUrl"];
        self.imgName = configDic[@"imgName"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.imgDiretory forKey:@"imgDiretory"];
    [aCoder encodeObject:self.imgName forKey:@"imgName"];
    [aCoder encodeObject:self.imgUrl forKey:@"imgUrl"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.imgDiretory = [aDecoder decodeObjectForKey:@"imgDiretory"];
        self.imgName = [aDecoder decodeObjectForKey:@"imgName"];
        self.imgUrl = [aDecoder decodeObjectForKey:@"imgUrl"];
    }
    return self;
}

@end

@implementation KQBOmsPageHeaderModel

- (instancetype)initWithDic:(NSDictionary *)configDic {
    self = [super init];
    if (self) {
        self.headerBtn = [[KQBPageHeaderButton alloc] initWithDic:configDic[@"buttonInfo"]];
        self.bgImg = [[KQBPageHeaderBgImage alloc] initWithDic:configDic[@"bgImgInfo"]];
        self.isShowBtn = [configDic[@"showButton"] isEqualToString:@"1"];
        self.creditAmt = configDic[@"creditAmt"];
        self.unpaidAmt = configDic[@"unpaidAmt"];
        self.creditStatus = configDic[@"status"];
        self.tipInfo = configDic[@"tipInfo"];
        self.titleColor = [UIColor colorWithHexString:configDic[@"titleColor"]];
        [self parseTitleArr:configDic[@"titleInfoList"]];
    }
    return self;
}

- (void)parseTitleArr:(NSArray *)titleArr {
    NSMutableArray *tmpArr = [NSMutableArray array];
    [titleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KQBPageHeaderTitle *pageHeader = [[KQBPageHeaderTitle alloc] initWithDic:obj];
        [tmpArr addObject:pageHeader];
    }];
    self.titleInfo = tmpArr;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.titleInfo forKey:@"titleInfo"];
    [aCoder encodeObject:self.headerBtn forKey:@"headerBtn"];
    [aCoder encodeObject:self.bgImg forKey:@"bgImg"];
    [aCoder encodeBool:self.isShowBtn forKey:@"isShowBtn"];
    [aCoder encodeObject:self.creditAmt forKey:@"creditAmt"];
    [aCoder encodeObject:self.titleColor forKey:@"titleColor"];
    [aCoder encodeObject:self.unpaidAmt forKey:@"unpaidAmt"];
    [aCoder encodeObject:self.creditStatus forKey:@"creditStatus"];
    [aCoder encodeObject:self.tipInfo forKey:@"tipInfo"];

}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.titleInfo = [aDecoder decodeObjectForKey:@"titleInfo"];
        self.titleColor = [aDecoder decodeObjectForKey:@"titleColor"];
        self.headerBtn = [aDecoder decodeObjectForKey:@"headerBtn"];
        self.bgImg = [aDecoder decodeObjectForKey:@"bgImg"];
        self.isShowBtn = [aDecoder decodeBoolForKey:@"isShowBtn"];
        self.creditAmt = [aDecoder decodeObjectForKey:@"creditAmt"];
        self.unpaidAmt = [aDecoder decodeObjectForKey:@"unpaidAmt"];
        self.creditStatus = [aDecoder decodeObjectForKey:@"creditStatus"];
        self.tipInfo = [aDecoder decodeObjectForKey:@"tipInfo"];

    }
    return self;
}


@end
