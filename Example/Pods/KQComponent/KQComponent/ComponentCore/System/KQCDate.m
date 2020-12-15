//
//  KQDateUtils.m
//  kuaiQianbao
//
//  Created by xy on 16/1/11.
//
//

#import "KQCDate.h"

@implementation KQCDate

NSString *const KQDateFormatAccurateSecond          = @"yyyyMMddHHmmss";
NSString *const KQDateFormatAccurateSecondWithSpace = @"yyyy-MM-dd HH:mm:ss";
NSString *const KQDateFormatAccurateSecondWithSpaceAndPoint = @"yyyy.MM.dd HH:mm:ss";

NSString *const KQDateFormatAccurateMinuteWithSpace = @"yyyy/MM/dd HH:mm";

NSString *const KQDateFormatAccurateYearAndMonth = @"yyyy/MM";
NSString *const KQDateFormatAccurateYearAndMonthChineseCharacter = @"yyyy年M月";

NSString *const KQDateFormatAccurateMonthAndDay = @"MM/dd";

NSString *const KQDateFormatAccurateDay = @"yyyy/MM/dd";
NSString *const KQDateFormatAccurateDayWithDash = @"yyyy-MM-dd";

NSString *const KQDateFormatAccurateMillisecond = @"yyyy-MM-dd HH:mm:ss.SSS";
NSString *const KQDateFormatAccurateMillisecondWithSpace = @"yyyy-MM-dd HH:mm:ss SSS";

NSString *const KQDateFormatAccurateMicroSecond = @"yyyyMMddHHmmssSSS";
NSString *const KQDateFormatAccurateYearMonthDayWithChinese = @"yyyy年MM月dd日";

static NSMutableDictionary *DateFormatterDic = nil;
static NSCalendar *Calendar = nil;
static NSArray *WeekdayArray = nil;

+ (void)initialize{    
    if (!DateFormatterDic) {
        DateFormatterDic = [NSMutableDictionary dictionary];
    }
}

+ (NSDate *)dateFormat:(NSString *)srcFormat srcDate:(NSString *)srcDateStr{
    if ([NSString kqc_isBlank:srcFormat]
        || [NSString kqc_isBlank:srcDateStr]) {
        return nil;
    }
    
    NSDateFormatter *srcDateFormatter = [KQCDate dateFormatter:srcFormat];
    return [srcDateFormatter dateFromString:srcDateStr];
}

+ (NSString *)dateFormat:(NSDate *)srcDate destFormat:(NSString *)destFormat{
    if (!srcDate
        || [NSString kqc_isBlank:destFormat]) {
        return nil;
    }
    
    NSDateFormatter *destDateFormatter = [KQCDate dateFormatter:destFormat];
    NSString *destDataStr = [destDateFormatter stringFromDate:srcDate];
    return destDataStr;
}

+ (NSString *)dateFormat:(NSString *)srcFormat srcDate:(NSString *)srcDateStr destFormat:(NSString *)destFormat{
    NSDate *srcDate = [KQCDate dateFormat:srcFormat srcDate:srcDateStr];
    return [KQCDate dateFormat:srcDate destFormat:destFormat];
}

+ (NSTimeZone *)timeZone{
    return [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
}

+ (NSDateFormatter *)dateFormatter:(NSString *)format{
    NSDateFormatter *dateFormatter = DateFormatterDic[format];
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [KQCDate timeZone];
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.dateFormat = format;
        DateFormatterDic[format] = dateFormatter;
    }
    return dateFormatter;
}

+ (NSCalendar *)currentCalendar{
    if (!Calendar) {
        Calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        Calendar.timeZone = [KQCDate timeZone];
    }
    return Calendar;
}

+ (NSString *)weekdayFromDate:(NSDate *)date{
    if (!date) {
        return nil;
    }
    
    if (!WeekdayArray) {
        WeekdayArray = @[[NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
    }
    
    NSCalendar *calendar = [KQCDate currentCalendar];
    NSDateComponents *theComponents = [calendar components:NSCalendarUnitWeekday fromDate:date];
    
    if (theComponents.weekday >= WeekdayArray.count
        || theComponents.weekday < 0) {
        return nil;
    }
    return WeekdayArray[theComponents.weekday];
}

@end
