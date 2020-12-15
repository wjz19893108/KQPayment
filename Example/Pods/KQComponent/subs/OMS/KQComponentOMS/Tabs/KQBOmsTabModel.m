//
//  KQBOmsTabModel.m
//  kuaiQianbao
//
//  Created by pengkang on 2016/9/29.
//
//

#import "KQBOmsTabModel.h"
#import <objc/runtime.h>

#define ScaleFactor  ([UIScreen mainScreen].bounds.size.height) < 736? 2.0:3.0
#define ExcrptionArr @[@"isShowName",@"selectedItem",@"unselectedItem"]
@implementation KQBOmsTabItem

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _iconName = [dic objectForKey:@"iconName"];
        _iconUrl = [dic objectForKey:@"iconUrl"];
        _iconDiretory = [dic objectForKey:@"iconDiretory"];
    }
    return self;
}

- (UIImage *)image{
    if (!_image) {
        NSString *imagePath =  KQC_FORMAT(@"%@/%@%@", [KQBCacheManager directoryPath:KQCahceTypeUserOms], self.iconHome, self.iconDiretory);
        UIImage *tmpImage = [UIImage imageWithContentsOfFile:imagePath];
        _image = [UIImage imageWithData:UIImageJPEGRepresentation(tmpImage, 1.0) scale:ScaleFactor];
    }
    return  _image;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.iconDiretory forKey:@"iconDiretory"];
    [aCoder encodeObject:self.iconName forKey:@"iconName"];
    [aCoder encodeObject:self.iconUrl forKey:@"iconUrl"];
    [aCoder encodeObject:self.iconHome forKey:@"iconHome"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.iconDiretory = [aDecoder decodeObjectForKey:@"iconDiretory"];
        self.iconName = [aDecoder decodeObjectForKey:@"iconName"];
        self.iconUrl = [aDecoder decodeObjectForKey:@"iconUrl"];
        self.iconHome = [aDecoder decodeObjectForKey:@"iconHome"];
    }
    return self;
}

@end


@implementation KQBOmsTabModel

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([KQBOmsTabModel class], &count);
        for (int i = 0; i < count; ++i) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *keyName = KQC_FORMAT(@"%s", name);
            if (configDic[keyName]) {
                if ([ExcrptionArr containsObject:keyName]) {
                    continue;
                }
                [self setValue:configDic[keyName] forKey:keyName];
            }
        }
        self.isShowName = [[configDic objectForKey:@"isShowName"] isEqualToString:@"1"];
        self.jumpModel = @"1";
        
        NSDictionary *selectIconInfo = [configDic objectForKey:@"selectIconInfo"];
        self.selectedItem = [[KQBOmsTabItem alloc] initWithDic:selectIconInfo];
        self.selectedItem.iconHome = self.resHome;
        
        NSDictionary *unselectIconInfo = [configDic objectForKey:@"notSelectIconInfo"];
        self.unselectedItem = [[KQBOmsTabItem alloc] initWithDic:unselectIconInfo];
        self.unselectedItem.iconHome = self.resHome;
        
        if(!_isShowName) {
            _tabIconName = @"";
        }
    }
    return self;
}

- (void)setResHome:(NSString *)resHome{
    resHome = resHome;
    self.selectedItem.iconHome = resHome;
    self.unselectedItem.iconHome = resHome;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.tabIconName forKey:@"tabIconName"];
    [aCoder encodeObject:self.charactersColor forKey:@"charactersColor"];
    [aCoder encodeObject:self.selectedItem forKey:@"selectedItem"];
    [aCoder encodeObject:self.unselectedItem forKey:@"unselectedItem"];
    [aCoder encodeBool:self.isShowName forKey:@"isShowName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabIconName = [aDecoder decodeObjectForKey:@"tabIconName"];
        self.charactersColor = [aDecoder decodeObjectForKey:@"charactersColor"];
        self.selectedItem = [aDecoder decodeObjectForKey:@"selectedItem"];
        self.unselectedItem = [aDecoder decodeObjectForKey:@"unselectedItem"];
        self.isShowName = [aDecoder decodeBoolForKey:@"isShowName"];
    }
    return self;
}

@end
