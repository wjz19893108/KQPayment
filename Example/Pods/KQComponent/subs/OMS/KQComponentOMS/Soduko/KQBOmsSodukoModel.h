//
//  KQBOmsSodukoModel.h
//  kuaiQianbao
//
//  Created by pengkang on 16/9/15.
//
//
#import "KQBOmsBaseModel.h"

@interface KQBOmsSodukoModel : KQBOmsBaseModel <NSCoding>

@property (nonatomic, strong) NSString *functionName;
@property (nonatomic, strong) NSString *isMore;
@property (nonatomic, strong) NSString *operationStatus;
@property (nonatomic, strong) NSString *promotionText;
@property (nonatomic, strong) NSString *lifeAppAbbrName;
@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSString *resDesc;
@property (nonatomic, strong) NSString *index;

@end
