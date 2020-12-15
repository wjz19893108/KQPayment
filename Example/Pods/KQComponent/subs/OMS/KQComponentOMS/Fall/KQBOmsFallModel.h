//
//  KQBOmsFallModel.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/28.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBOmsBaseModel.h"

@interface KQBOmsFallModel : NSObject<NSCoding>

@property (nonatomic, assign) NSInteger itemId;         
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *imageDefaultId;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *creditSort;
@property (nonatomic, strong) NSString *productTag;
@property (nonatomic, strong) NSString *isStages;
@property (nonatomic, strong) NSString *stagesApp;

- (instancetype)initWithResponse:(ContentResult *)product;

- (instancetype)initWithDic:(NSDictionary *)configDic;

@end
