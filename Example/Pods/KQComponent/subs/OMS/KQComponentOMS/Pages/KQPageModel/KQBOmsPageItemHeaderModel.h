//
//  KQOmsPageItemHeaderModel.h
//  页面 section 头部
//  kuaiQianbao
//
//  Created by pengkang on 16/3/8.
//
//

#import <Foundation/Foundation.h>
#import "KQBOmsBaseModel.h"

@class KQBOmsImageModel;
@interface KQBOmsPageItemHeaderModel : KQBOmsBaseModel <NSCoding>

@property (nonatomic, strong) NSString *title;              // header标题
@property (nonatomic, strong) NSString *sectionHeader;              // header标题
@property (nonatomic, strong) NSString *resDescription;     // header描述
@property (nonatomic, strong) KQBOmsImageModel *item;       // headeritem数据模型
@property (nonatomic, strong) NSString *resFrom;            // 资源来源


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

