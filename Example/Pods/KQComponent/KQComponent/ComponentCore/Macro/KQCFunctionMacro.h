//
//  KQFunctionMacro.h
//  KQCore
//
//  Created by xy on 2016/10/13.
//  Copyright © 2016年 xy. All rights reserved.
//

#ifndef KQCFunctionMacro_h
#define KQCFunctionMacro_h

#define KQC_NON_NIL(str) ([NSString kqc_isBlank:str] ? @"" : str)

#ifdef DEBUG
    #ifndef DLog
        #   define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
    #endif
    #ifndef ELog
        #   define ELog(err) {if(err) DLog(@"%@", err)}
    #endif
#else
    #ifndef DLog
        #   define DLog(...)
    #endif
    #ifndef ELog
        #   define ELog(err)
    #endif
#endif

#ifndef DEBUG
#    define NSLog(...)
#endif

#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(classname)     \
\
+ (nullable classname*) shared##classname;

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
+ (classname *)shared##classname \
{ \
static classname *instance = nil;\
static dispatch_once_t predicate;\
dispatch_once(&predicate, ^{\
instance = [[self alloc] init];\
});\
\
return instance; \
} \

#define KQC_FORMAT(format, args...) [NSString stringWithFormat:format, args]

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)

#define KQC_SELF_WEAK(type)  __weak typeof(type) weak##type = type;
#define KQC_SELF_STRONG(type)  __strong typeof(type) type = weak##type;

#endif /* KQFunctionMacro_h */
