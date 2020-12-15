//
//  KQBOmsMatrixModel.m
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBOmsMatrixModel.h"

@implementation KQBOmsMatrixModel

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
    if ([NSString  kqc_isBlank:self.resId]) {
        return nil;
    }
    NSArray *imageNames = [self.resDiretory componentsSeparatedByString:@"/"];
    NSString *imageName = KQC_FORMAT(@"%@_%@", self.resId,[imageNames lastObject]);
    
    if ([NSString kqc_isBlank:imageName]) {
        return nil;
    }
    self.isCached = YES;
    return  [UIImage imageNamed:imageName];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    //    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.resFrom forKey:@"resFrom"];
    
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.resFrom = [aDecoder decodeObjectForKey:@"resFrom"];
    }
    return self;
}

@end

