//
//  UIImageView+KQBAddition.m
//  KQBusiness
//
//  Created by xy on 2016/11/1.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "UIImageView+OMS.h"
#import "KQBImageManager.h"
#import "KQBOmsImageModel.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (KQOMS)

const NSString *KQBBankIconAddress = @"https://www.99bill.com/mobsup/static/bank/bank-icon/images/";

- (void)setBankIcon:(NSString *)iconName{
    [self sd_setImageWithURL:[NSURL URLWithString:KQC_FORMAT(@"%@%@.png", KQBBankIconAddress, iconName)]];
    
}

- (void)setBankIcon:(NSString *)iconName downImgSuccess:(void(^)(UIImage *image))success{
    [self sd_setImageWithURL:[NSURL URLWithString:KQC_FORMAT(@"%@%@.png", KQBBankIconAddress, iconName)] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error && image) {
            success(image);
        }
    }];
}

- (void)setOMSIcon:(NSString *)omsImageId {
    KQBOmsImageModel *omsModel = [ImageManager getImageByPosition:omsImageId];
    if (omsModel.image) {
        self.image = omsModel.image;
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:omsModel.resUrl] placeholderImage:[UIImage imageNamed:omsImageId]?:[UIImage imageNamed:@"defaultPlaceholder"] ];
    }
}

@end
