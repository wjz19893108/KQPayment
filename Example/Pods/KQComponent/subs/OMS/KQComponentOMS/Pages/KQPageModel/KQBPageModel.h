//
//  KQOmsPage.h
//  页面json文件解析出来的模型
//  kuaiQianbao
//
//  Created by pengkang on 16/3/8.
//
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, KQBPageStatus){
    KQBPageStatusNone = 0,
    KQBPageStatusFailed ,
    KQBPageStatusSuccess
};

@interface KQBPageModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *resourceId;    // 资源ID
@property (nonatomic, strong) NSString *pageNo;        // 配置页面编号
@property (nonatomic, assign) KQBPageStatus pageStatus;    // 资源ID
@property (nonatomic, strong) NSArray *contentArray;   // 页面section数组
@property (nonatomic, strong) NSString *pageInterface; // 页面接口
@end
