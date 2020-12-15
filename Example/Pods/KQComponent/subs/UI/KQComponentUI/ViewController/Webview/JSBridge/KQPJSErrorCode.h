//
//  KQCJSErrorCode.h
//  KQProtocol
//
//  Created by pengkang on 2016/12/7.
//  Copyright © 2016年 xy. All rights reserved.
//

#ifndef KQPJSErrorCode_h
#define KQPJSErrorCode_h

//错误码
#define ERROR_CODE_UNKOWN                               @"00"          //未知异常
#define ERROR_CODE_NETWORK                              @"1000"        //网络异常
#define ERROR_CODE_FUNCTION_NOT_FOUND                   @"2000"        //未找到相关方法
#define ERROR_CODE_LOCATION                             @"3000"        //无法获得定位信息
#define ERROR_CODE_LOCATION_NOT_PROVIDER                @"3001"        //GPS定位开个未打开
#define ERROR_CODE_LOCATION_NOT_AUTHORITY               @"3002"        //没有获得定位权限
#define ERROR_CODE_LOCATION_TIMEOUT                     @"3003"        //定位超时
#define ERROR_CODE_TEL                                  @"4000"        //无法拨打电话
#define ERROR_CODE_SELECT_CONTACT_CANCEL                @"6000"        //用户取消操作
#define ERROR_CODE_NO_CONTACT                           @"7000"        //没有读取通讯录权限
/*统一支付*/
#define ERROR_CODE_PAY                                  @"5000"       //未知原因，如错误码为nil
#define ERROR_CODE_PAY_CALL_FAILED                      @"5001"       //M251接口失败
#define ERROR_CODE_PAY_WRONG_ORDER_STATUS               @"5002"       //M251返回的数据错误
#define ERROR_CODE_PAY_FAILED                           @"5003"       //M250接口失败
#define ERROR_CODE_PAY_APPUNINSTALL_OR_LOWVERSION       @"5004"       //App没有安装或版本过低(未使用)
#define ERROR_CODE_PAY_LOST_PARAM                       @"5005"       //参数不全
#define ERROR_CODE_PAY_SIGN_ERROR                       @"5006"       //验证签名错误
#define ERROR_CODE_PAY_RISK_FAILED                      @"5007"       //M271接口失败 无下单情况
#define ERROR_CODE_USER_CANCEL                          @"99"         //用户取消操作
/*统一支付*/
#define ERROR_CODE_LOGIN_ERROR                          @"9000"       //登录失败

// 错误信息
#define ERROR_MSG_UNKOWN                     @"未知异常"
#define ERROR_MSG_NETWORK                    @"网络异常"
#define ERROR_MSG_FUNCTION_NOT_FOUND         @"未找到相关方法"
#define ERROR_MSG_LOCATION                   @"无法获得定位信息"
#define ERROR_MSG_LOCATION_NOT_PROVIDER      @"GPS定位开关未打开"
#define ERROR_MSG_LOCATION_NOT_AUTHORITY     @"没有获得定位权限"
#define ERROR_MSG_LOCATION_TIMEOUT           @"定位超时"
#define ERROR_MSG_TEL                        @"无法拨打电话"
#define ERROR_MSG_SELECT_CONTACT_CANCEL      @"用户取消操作"
#define ERROR_MSG_NO_CONTACT_PRO             @"没有读取通讯录权限"
#define ERROR_MSG_PAY                        @"支付失败"
#define ERROR_MSG_PAY_CALL_FAILED            @"调用失败"
#define ERROR_MSG_PAY_WRONG_ORDER_STATUS     @"订单状态错误"
#define ERROR_MSG_PAY_FAILED                 @"支付失败"
#define ERROR_MSG_USER_CANCEL                @"用户取消操作"
#define ERROR_MSG_LOGIN_ERROR                @"登录失败"

#define FEIFAN_CODE_SUCCESS                     @"100"          //成功
#define FEIFAN_CODE_USER_CANCEL                 @"200"          //取消
#define FEIFAN_ERROR_CODE_PAY                   @"300"          //支付失败

#endif /* KQPJSErrorCode_h */
