//
//  KQBOmsImageModel.m
//  kuaiQianbao
//
//  Created by pengkang on 16/1/14.
//
//

#import "KQBOmsImageModel.h"
#import <objc/runtime.h>

@implementation KQBOmsImageModel

- (instancetype)initWithDic:(NSDictionary *)configDic{
    self = [super init];
    if (self) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([KQBOmsImageModel class], &count);
        for (int i = 0; i < count; ++i) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *keyName = KQC_FORMAT(@"%s", name);
            if (configDic[keyName]) {
                [self setValue:configDic[keyName] forKey:keyName];
            }
        }
        _imgPosition = [configDic objectForKey:@"position"];
    }
    return self;
}

- (UIImage *)image{
    if(!_image){
        NSString *imagePath =  KQC_FORMAT(@"%@/%@%@", [KQBCacheManager directoryPath:KQCahceTypeUserOms], self.resHome, self.resDiretory);
        _image = [UIImage imageWithContentsOfFile:imagePath];
        if (!_image) {
            _image = [self getImageFromRes];
        }
    } else {
        if (_image.size.height <= 0 || _image.size.width <= 0 ) {
            NSString *imagePath =  KQC_FORMAT(@"%@/%@%@", [KQBCacheManager directoryPath:KQCahceTypeUserOms], self.resHome, self.resDiretory);
            _image = [UIImage imageWithContentsOfFile:imagePath];
        }
        
        if (!_image) {
            _image = [self getImageFromRes];
        }
    }
    return _image;
}

- (UIImage *)getImageFromRes{
    if ([NSString  kqc_isBlank:_resFrom]) {
        return nil;
    }
    NSArray *imageNames = [self.resDiretory componentsSeparatedByString:@"/"];
    NSString *imageName = KQC_FORMAT(@"%@_%@", _resFrom,[imageNames lastObject]);
    
    if ([NSString kqc_isBlank:imageName]) {
        return nil;
    }
    return  [UIImage imageNamed:imageName];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.resFrom forKey:@"resFrom"];
    [aCoder encodeObject:self.imgPosition forKey:@"imgPosition"];
//    [aCoder encodeObject:self.image forKey:@"image"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.resFrom = [aDecoder decodeObjectForKey:@"resFrom"];
        self.imgPosition = [aDecoder decodeObjectForKey:@"imgPosition"];
//        self.image = [aDecoder decodeObjectForKey:@"image"];
    }
    return self;
}

@end
