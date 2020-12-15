//
//  KQBOmsTabModel.h
//  kuaiQianbao
//
//  Created by pengkang on 2016/9/29.
//
//
#import "KQBOmsBaseModel.h"

@interface KQBOmsTabItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *iconDiretory;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *iconHome;
@property (nonatomic, strong) UIImage  *image;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end


@interface KQBOmsTabModel : KQBOmsBaseModel <NSCoding>

@property (nonatomic, strong) NSString *tabIconName;
@property (nonatomic, strong) NSString *charactersColor;
@property (nonatomic, assign) BOOL isShowName;
@property (nonatomic, strong) KQBOmsTabItem *selectedItem;
@property (nonatomic, strong) KQBOmsTabItem *unselectedItem;

- (void)setResHome:(NSString *)resHome;

@end
