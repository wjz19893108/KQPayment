//
//  KQBOmsCreditProductModel.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQBOmsCreditProductModel : NSObject

@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) NSString *labelInfo;
@property (nonatomic, strong) NSString *itemUrl;
@property (nonatomic, strong) NSString *logoImage;
@property (nonatomic, strong) NSString *productCode;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *headerName;
@property (nonatomic, strong) NSString *amountDesc;
@property (nonatomic, strong) NSString *subtitleIcon;


- (instancetype)initWithDic:(NSDictionary *)configDic;

- (instancetype)initWithResponse:(ContentProductItem *)product;

@end


