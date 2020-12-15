//
//  KQOmsPageModel.h
//  kuaiQianbao
//  页面配置中某个section
//
//  Created by pengkang on 16/3/8.
//
//

#import <Foundation/Foundation.h>
#import "KQBOmsPageItemHeaderModel.h"
@interface KQBOmsPageModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *contentType;                    //  页面section类型
@property (nonatomic, strong) NSString *position;                       //  资源order
@property (nonatomic, strong) KQBOmsPageItemHeaderModel *itemHeader;    //  页面section heaeder
@property (nonatomic, strong) NSArray *items;                           //  页面section中的内容数组
@property (nonatomic, strong) NSString *resHome;                        //  资源根目录
@property (nonatomic, strong) NSString *resFrom;                        //  资源来源
@property (nonatomic, strong) NSString *isDisAfterLogin;                //  登录后是否显示

/**
 *  解析json文件中的配置信息
 *  @param configDic : zip 包中config文件的内容
 *  @param resHome : 资源本地根目录
 *  @param resFrom : 资源来源
 */
- (instancetype)initWithDic:(NSDictionary *)configDic
                    resHome:(NSString *)resHome
                    resFrom:(NSString *)resFrom;

@end
