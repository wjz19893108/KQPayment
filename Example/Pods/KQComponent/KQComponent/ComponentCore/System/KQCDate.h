//
//  KQDateUtils.h
//  kuaiQianbao
//
//  Created by xy on 16/1/11.
//
//

#import <Foundation/Foundation.h>

@interface KQCDate : NSObject

FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateSecond;                  // yyyyMMddHHmmss
FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateSecondWithSpace;         // yyyy-MM-dd HH:mm:ss
FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateSecondWithSpaceAndPoint; // yyyy.MM.dd HH:mm:ss

FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateMinuteWithSpace; // yyyy/MM/dd HH:mm

FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateYearAndMonth; // yyyy/MM
FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateYearAndMonthChineseCharacter; // yyyy年M月;

FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateMonthAndDay;  // MM/dd

FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateDay;          // yyyy/MM/dd;
FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateDayWithDash;  // yyyy-MM-dd

FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateMillisecond;  // @"yyyy-MM-dd HH:mm:ss.SSS"
FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateMillisecondWithSpace;  // @"yyyy-MM-dd HH:mm:ss SSS"

FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateMicroSecond;  //yyyyMMddHHmmssSSS

FOUNDATION_EXTERN NSString *const _Nonnull KQDateFormatAccurateYearMonthDayWithChinese;//@"yyyy年MM月dd日"
/**
 *  时间格式转换
 *
 *  @param srcFormat    待转换时间的格式
 *  @param srcDateStr   待转换时间字符串
 *  @param destFormat   目标格式
 *
 *  return  目标时间字符串
 */
+ (nullable NSString *)dateFormat:(NSString * __nonnull)srcFormat srcDate:(NSString * __nonnull)srcDateStr destFormat:(NSString * __nonnull)destFormat;

/**
 *  时间格式转换
 *
 *  @param srcDate      待转换时间
 *  @param destFormat   目标格式
 *
 *  return  目标时间字符串
 */
+ (nullable NSString *)dateFormat:(NSDate * __nonnull)srcDate destFormat:(NSString * __nonnull)destFormat;

/**
 *  时间格式转换
 *
 *  @param srcFormat    待转换时间的格式
 *  @param srcDateStr   待转换字符串
 *
 *  return  目标时间
 */
+ (nullable NSDate *)dateFormat:(NSString * __nonnull)srcFormat srcDate:(NSString * __nonnull)srcDateStr;

/**
 根据日期获取是星期几

 @param date 输入的日期
 @return 星期几
 */
+ (nullable NSString *)weekdayFromDate:(NSDate * __nonnull)date;

@end
