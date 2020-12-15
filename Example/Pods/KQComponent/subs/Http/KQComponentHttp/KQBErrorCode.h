//
//  KQBErrorCode.h
//  KQBusiness
//
//  Created by tianqy on 2017/4/10.

#ifndef KQBErrorCode_h
#define KQBErrorCode_h

//M071
#define ERROR_CODE_M071_PWD_FAILED                  @"R071P51Z"      //支付密码错误
#define ERROR_CODE_M071_PWD_FROZEN                  @"R071P52Z"      //支付密码锁定

//M083
#define ERROR_CODE_PHONE_UNBAND                     @"R083P41Z"      //手机未绑定

//M172
#define ERROR_CODE_PRODUCT_NON_NULL                 @"R172P51Z"      //产品编号不能为空
#define ERROR_CODE_PRODUCT_INFO_NONEXISTENCE        @"R172P52Z"      //产品信息不存在
#define ERROR_CODE_PRODUCT_NON_TRANSFER             @"R172P53Z"      //产品不允许转出
#define ERROR_CODE_UN_IN_TRANSFER                   @"R172P54Z"      //不在转让期
#define ERROR_CODE_RESULTS_INFORMATION              @"R172P55Z"      //产品当前进行结息处理
#define ERROR_CODE_FREEZZ_TRANSFER                  @"R172P56Z"      //受让成功某产品后,N天内不能转让,此时可取
#define ERROR_CODE_TRANSFER_BLACKLIST               @"R172P57Z"      //该产品的黑名单中,不能转让

//M233
#define ERROR_CODE_AUTH_CODE_VOER_DUE               @"R233P53Z"      //验证码过期

//M250
#define ERROR_CODE_PAY_PWD_ERROR                    @"H02P57Z"        //支付密码错误
#define ERROR_CODE_PAY_PWD_LOCK                     @"H02P58Z"        //支付密码锁定
#define ERROR_CODE_M250_CVV2_FAILED                 @"H02P59Z"        //cvv2错误
#define ERROR_CODE_M250_SWITCH_PAY_METHOD           @"H02P60Z"        //更改支付方式
#define ERROR_CODE_M250_CARD_INFO_FAILED            @"H02P61Z"        //卡信息错误
#define ERROR_CODE_M250_UNIONPAY_INVALID            @"H02P62Z"        //未开通银联在线支付
#define ERROR_CODE_M250_UNBINDCARD                  @"H02P63Z"        //解绑银行卡

//M268
#define ERROR_CODE_NEED_ALERT                       @"R268P53Z"      //需要弹框显示错误
#define ERROR_CODE_M268_R49                         @"R268P56Z"      //验证码已发送，直接使用上次token


//M269
#define ERROR_CODE_M269_LG                          @"R269P62Z"    //需要弹框显示错误
#define ERROR_CODE_M269_01                          @"R269P57Z"    //需要弹框显示错误
#define ERROR_CODE_M269_02                          @"R269P59Z"
#define ERROR_CODE_M269_03                          @"R269P60Z"
#define ERROR_CODE_M269_04                          @"R269P61Z"
#define ERROR_CODE_M269_0000                        @"R269P63Z"    //实名认证成功,绑卡失败

//M293
#define ERROR_CODE_M293_R49                         @"C01P02Z"      //验证码已发送，直接使用上次token

//M310
#define ERROR_CODE_M310_R49                         @"C03P03Z"      //验证码已发送，直接使用上次token

//M317
#define ERROR_CODE_FEIFANTONG_EXIST                 @"C55P55Z"      //飞凡通账号存在
#define ERROR_CODE_KQACCOUNT_EXIST                  @"C05P06Z"      //快钱账号存在
#define ERROR_CODE_FEIFAN_EXIST                     @"C55P57Z"      //飞凡账号存在
#define ERROR_CODE_RELEVANCE_CARD_EXIST             @"C05P04Z"      //关联卡存在

//M319
#define ERROR_CODE_M319_R49                         @"C07P05Z"      //统一账户合并接口

//M320
#define ERROR_CODE_RISK_CALL_CENTER                 @"I07P58Z"      //风控提示框（去客服）
#define ERROR_CODE_RISK_CALL_2_CENTER               @"I07P59Z"      //风控提示框（去客服）
#define ERROR_CODE_SMS_VERIFY                       @"I07P60Z"      //短信验证
#define ERROR_CODE_2_SMS_VERIFY                     @"I07P62Z"      //短信验证
#define ERROR_CODE_SECURITY_ISSUE                   @"I07P61Z"      //安全问题
#define ERROR_CODE_ACCOUNT_EXCEPTION                @"I07P57Z"      //用户状态异常

//M323
#define ERROR_CODE_OVER_TIMES                       @"C08P03Z"      //超过次数

//M325
#define ERROR_CODE_SHOW_TIP                         @"C09P02Z"      //显示对话框提示
#define ERROR_CODE_2_SHOW_TIP                       @"C09P03Z"      //显示对话框提示
#define ERROR_CODE_IDEN_FAILED                      @"C09P04Z"      //认证失败
#define ERROR_CODE_ID_OVER_DUE                      @"C09P05Z"      //身份证照信息已过期，请确保您上传的身份证照在有效期内

//M326
#define ERROR_CODE_UN_REAL_NAME                     @"H12P52Z"      //未实名
#define ERROR_CODE_UN_ID_UPLOAD                     @"H12P53Z"      //未上传身份证
#define ERROR_CODE_ACCOUNT_UPGRADE                  @"H12P54Z"      //账户升级
#define ERROR_CODE_FACE_IDEN                        @"H12P55Z"      //人脸识别

//M341
#define ERROR_CODE_PAY_PWD_FAILED                   @"H14P53Z"      //支付密码不正确
#define ERROR_CODE_PAY_PWD_FROZEN                   @"H14P54Z"      //支付密码被冻结
#define ERROR_CODE_M341_CVV2_FAILED                 @"H14P57Z"      //cvv2错误
#define ERROR_CODE_M341_SWITCH_PAY_METHOD           @"H14P58Z"      //更改支付方式
#define ERROR_CODE_M341_CARD_INFO_FAILED            @"H14P59Z"      //卡信息错误

//M352
#define ERROR_UNION_PAY_PWD_ERROR                    @"H15P02Z"        //支付密码错误
#define ERROR_UNION_PAY_PWD_LOCK                     @"H15P03Z"        //支付密码锁定
//M004
#define ERROR_CODE_M004_R49                         @"R004P51Z"     //验证码已发送，直接使用上次token

#endif /* KQBErrorCode_h */

