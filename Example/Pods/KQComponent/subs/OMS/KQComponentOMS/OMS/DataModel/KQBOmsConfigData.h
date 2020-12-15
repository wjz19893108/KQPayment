//
//  KQOmsReqModel.h
//  kuaiQianbao
//  报文索引类
//  Created by pengkang on 16/1/5.
//
//

#import <Foundation/Foundation.h>

@class ContentResourceInfo;
@class ContentCommonZipInfo;

@interface KQBOmsConfigData : NSObject<NSCoding>

@property (nonatomic, strong) NSString *resourceId;         //资源ID
@property (nonatomic, strong) NSString *resourceName;       //资源名称
@property (nonatomic, strong) NSString *resourceVersion;    //资源版本号
@property (nonatomic, strong) NSString *resourceUrl;        //资源链接
@property (nonatomic, strong) NSString *isIncrement;        //是否为增量更新
@property (nonatomic, strong) NSString *isCaseUser;         //是否区分用户
@property (nonatomic, strong) NSString *md5;                //资源文件MD5值
@property (nonatomic, strong) NSString *resStatus;          //资源下载、解压状态
@property (nonatomic, strong) NSString *resFrom;            //资源来源接口
@property (nonatomic, strong) NSString *resourceType;       //资源类型

//local path for resource
@property (nonatomic, strong) NSString *resourceDirectory;  //资源文件夹名称

/**
 *  根据M264返回内容初始化
 *  @param resourceInfo : OMS 返回的用户资源数据报文结构
 */
- (instancetype)initWithObj:(ContentResourceInfo *)resourceInfo;

/**
 *  根据M255返回内容初始化
 *  @param commonZip : OMS 返回的公共资源数据报文结构
 */
- (instancetype)initWithZip:(ContentCommonZipInfo *)commonZip;

@end
