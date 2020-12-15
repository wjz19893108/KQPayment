//
//  KQBOmsPageHeaderModel.h
//  KQBusiness
//
//  Created by pengkang on 2017/2/22.
//  Copyright © 2017年 xy. All rights reserved.
//

#import "KQBOmsBaseModel.h"

@interface KQBPageHeaderTitle : NSObject<NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;

- (instancetype)initWithDic:(NSDictionary *)configDic;

@end

@interface KQBPageHeaderButton : NSObject<NSCoding>

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) NSString *jumpModel;
@property (nonatomic, strong) NSString *jumpTarget;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithDic:(NSDictionary *)configDic;

@end

@interface KQBPageHeaderBgImage : NSObject<NSCoding>

@property (nonatomic, strong) NSString *imgDiretory;
@property (nonatomic, strong) NSString *imgName;
@property (nonatomic, strong) NSString *imgUrl;

- (instancetype)initWithDic:(NSDictionary *)configDic;

@end

@interface KQBOmsPageHeaderModel : NSObject<NSCoding>

@property (nonatomic, strong) NSArray *titleInfo;
@property (nonatomic, strong) KQBPageHeaderButton *headerBtn;
@property (nonatomic, strong) KQBPageHeaderBgImage *bgImg;
@property (nonatomic, assign) BOOL isShowBtn;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) NSString *creditAmt;
@property (nonatomic, strong) NSString *unpaidAmt;
@property (nonatomic, strong) NSString *creditStatus;
@property (nonatomic, strong) NSString *tipInfo;

- (instancetype)initWithDic:(NSDictionary *)configDic;

@end
