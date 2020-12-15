//
//  KQHttpMacro.h
//  kuaiQianbao
//
//  Created by xy on 15/8/16.
//
//

#ifndef KQCHttpMacro_h
#define KQCHttpMacro_h

#define kNetWorkErrorNotConnectKey                  @"FFFF"
#define kNetWorkErrorParseFailedKey                 @"FFFE"
#define kNetWorkErrorConnectTimeOutKey              @"FFFD"
#define kNetWorkErrorConnectFailedKey               @"FFFC"
#define kNetWorkErrorLocalParamErrorFailedKey       @"FFFB"
#define kNetWorkErrorUploadFailedKey                @"FFFG"
#define kNetWorkErrorVerifyServerSignFailedKey      @"FFFA"
#define kNetWorkErrorSecureKeyInvaildKey            @"RLOST"
#define kNetWorkErrorVerifySignKey                  @"52"
#define kNetWorkErrorLocalSignErrorKey              @"53"
#define kNetWorkErrorLocalSecureKeyErrorKey         @"54"
#define kNetWorkErrorUserCancelKey                  @"FFFZ"


/**
 网络请求成功回调

 @param response 网络返回值
 */
typedef void(^KQNetworkSuccessBlock)(id response);

/**
 网络请求失败回调

 @param errorCode 错误码
 @param errorMessage 错误描述
 @param response 网络返回值
 */
typedef void(^KQNetworkFailedBlock)(NSString *errorCode, NSString *errorMessage, id response);

#endif
