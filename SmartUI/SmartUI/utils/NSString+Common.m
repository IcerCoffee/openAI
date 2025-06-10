//
//  NSString+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "NSString+Common.h"
#import <CommonCrypto/CommonDigest.h>
//#import "RegexKitLite.h"
#import "sys/utsname.h"

#include <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <arpa/inet.h>

@implementation NSString (Common)

-(NSString *)mw_dateWithFormat_MM_dd_HH_mm_string
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] ];
    NSDate *date =[dateFormat dateFromString:self];
    [dateFormat setDateFormat:@"MM-dd HH:mm"];
    NSString *dateStr = [dateFormat stringFromDate:date];
    return dateStr;
}

- (NSDate *)date_FromeString{
    //转换时间格式
    NSDateFormatter *df = [[NSDateFormatter alloc] init];//格式化
    
    [df setDateFormat:@"HH:mm"];
    
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] ];
    
    NSDate *date =[[NSDate alloc]init];
    
    date =[df dateFromString:self];
    
//    str = [NSString stringWithFormat:@"%@",date];
    return date;
}

+ (NSString *)userAgentStr{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], deviceString, [[UIDevice currentDevice] systemVersion], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f)];
}

- (NSString *)URLEncoding
{
    NSString * result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
                                                                                              (CFStringRef)self,
                                                                                              NULL,
                                                                                              CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                              kCFStringEncodingUTF8 ));
    return result;
}
- (NSString *)URLDecoding
{
    NSMutableString * string = [NSMutableString stringWithString:self];
    [string replaceOccurrencesOfString:@"+"
                            withString:@" "
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, [string length])];
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)md5Str
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

- (NSURL *)urlImageWithCodePathResizeToView:(UIView *)view{
    return [self urlImageWithCodePathResize:[[UIScreen mainScreen] scale]*CGRectGetWidth(view.frame)];
}

+ (NSString *)handelRef:(NSString *)ref path:(NSString *)path{
    if (ref.length <= 0 && path.length <= 0) {
        return nil;
    }
    
    NSMutableString *result = [NSMutableString new];
    if (ref.length > 0) {
        [result appendString:ref];
    }
    if (path.length > 0) {
        [result appendFormat:@"%@%@", ref.length > 0? @"/": @"", path];
    }
    return [result URLEncoding];
}
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    CGSize resultSize = CGSizeZero;
    if (self.length <= 0) {
        return resultSize;
    }
    resultSize = [self boundingRectWithSize:size
                                    options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                 attributes:@{NSFontAttributeName: font}
                                    context:nil].size;
    resultSize = CGSizeMake(MIN(size.width, ceilf(resultSize.width)), MIN(size.height, ceilf(resultSize.height)));
    return resultSize;
}

- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    return [self getSizeWithFont:font constrainedToSize:size].height;
}
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    return [self getSizeWithFont:font constrainedToSize:size].width;
}

-(BOOL)containsEmoji{
    if (!self || self.length <= 0) {
        return NO;
    }
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

- (NSString *)noEmoji {
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];

    NSString* result = [expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];

    return result;
}


+ (NSString *)sizeDisplayWithByte:(CGFloat)sizeOfByte{
    NSString *sizeDisplayStr;
    if (sizeOfByte < 1024) {
        sizeDisplayStr = [NSString stringWithFormat:@"%.2f bytes", sizeOfByte];
    }else{
        CGFloat sizeOfKB = sizeOfByte/1024;
        if (sizeOfKB < 1024) {
            sizeDisplayStr = [NSString stringWithFormat:@"%.2f KB", sizeOfKB];
        }else{
            CGFloat sizeOfM = sizeOfKB/1024;
            if (sizeOfM < 1024) {
                sizeDisplayStr = [NSString stringWithFormat:@"%.2f M", sizeOfM];
            }else{
                CGFloat sizeOfG = sizeOfKB/1024;
                sizeDisplayStr = [NSString stringWithFormat:@"%.2f G", sizeOfG];
            }
        }
    }
    return sizeDisplayStr;
}

- (NSString *)stringByRemoveSpecailCharacters{
    static NSCharacterSet *specailCharacterSet;
    if (!specailCharacterSet) {
        NSMutableString *specailCharacters = @"\u2028\u2029".mutableCopy;
        specailCharacterSet = [NSCharacterSet characterSetWithCharactersInString:specailCharacters];
    }
    return [[self componentsSeparatedByCharactersInSet:specailCharacterSet] componentsJoinedByString:@""];
}

- (NSString *)trimWhitespace
{
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}

- (BOOL)isEmpty
{
    return [[self trimWhitespace] isEqualToString:@""];
}

- (BOOL)isEmptyOrListening{
    return [self isEmpty] || [self hasListenChar];
}

//判断是否为整形
- (BOOL)isPureInt{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形
- (BOOL)isPureFloat{
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
//判断是否是手机号码
- (BOOL)isPhoneNo{
//    NSString *phoneRegex = @"1[3|5|7|8|][0-9]{9}";
    NSString *phoneRegex = @"[0-9]{1,15}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}
//判断手机号码格式是否正确 ^[1][358][0-9]{9}$
//- (BOOL)valiMobile{
//    NSString *mobile = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
//    if (mobile.length != 11)
//    {
//        return NO;
//    }else{
//        /**
//         * 移动号段正则表达式
//         */
//        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}|(1703)\\d{7}|(1706)\\d{7}$";
//        /**
//         * 联通号段正则表达式
//         */
//        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(171)|(18[5,6]))\\d{8}|(1709)\\d{7}|(1704)\\d{7}|(1707)\\d{7}|(1708)\\d{7}$";
//        /**
//         * 电信号段正则表达式
//
//         */
//        NSString *CT_NUM = @"^((133)|(153)|(177)|(173)|(18[0,1,9]))\\d{8}|(170[0-2])\\d{7}$";
//        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
//        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
//        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
//        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
//        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
//        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
//        if (isMatch1 || isMatch2 || isMatch3) {
//            return YES;
//        }else{
//            return NO;
//        }
//    }
//}
- (BOOL)valiMobile{
    NSString *mobile = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11){
        return NO;
    }else{
        NSString *phoneRegex = @"^1[3-9][0-9]{9}$";
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        if (isMatch2) {
            return YES;
        }else{
            return NO;
        }
    }
}

- (BOOL)valiUserPhone{
    NSString *phoneRegex = @"[0-9]{7,15}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
    
}

- (BOOL)checkVertify{
    NSString *verRegex = @"[0-9]{6}";
    NSPredicate *verTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", verRegex];
    return [verTest evaluateWithObject:self];
    
}
- (BOOL )checkTelNum{
    NSString *verRegex = @"[0-9]{7,8}";
    NSPredicate *telNum = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", verRegex];
    return [telNum evaluateWithObject:self];
}

- (BOOL)checkTelCodeNum{
    NSString *verRegex = @"[0-9]{3,4}";
    NSPredicate *telNum = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", verRegex];
    return [telNum evaluateWithObject:self];
}

#pragma 正则匹配用户密码8-20位数字字母特殊符号
- (BOOL)uo_checkPassword {
    NSString *pattern = @"^(?![a-zA-Z]+$)(?![A-Z0-9]+$)(?![A-Z\\W_]+$)(?![a-z0-9]+$)(?![a-z\\W_]+$)(?![0-9\\W_]+$)[a-zA-Z0-9\\W_]{8,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}
- (BOOL)checkSetPassword{
    NSString *pattern = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[`~.!@_#$%^&*()+=|{}':;',\\[\\]<>?~！@#￥%……&*（）——+|{}【】‘；：’。，、？])[A-Za-z\\d`~.!@_#$%^&*()+=|{}':;',\\[\\]<>?~！@#￥%……&*（）——+|{}【】‘；：’。，、？]{8,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

- (BOOL)checkOldPassword {
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)(?![`~!@#$%^&*()+=|{}':;',\\[\\]<>?~！@#￥%……&*（）——+|{}【】‘；：’。，、？]+$)[a-zA-Z0-9`~!@#$%^&*()+=|{}':;',\\[\\]<>?~！@#￥%……&*（）——+|{}【】‘；：’。，、？]{6,20}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

-(BOOL)checkLoginPasswordLength{
    if (self.length >= 6) {
        return YES;
    }
    return NO;
}

#pragma mark - 正则匹配输入校验字符
- (BOOL)uo_checkPassword_isNumberOrAZ{
    NSString * regex = @"^[A-Za-z0-9`~!@#$%^&*()+=|{}':;',\\[\\]<>?~！@#￥%……&*（）——+|{}【】‘；：’。，、？]$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    
    return isMatch;
}
- (BOOL)settingIPCHeck{
    NSString * regex = @"^[0-9.:]$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

- (BOOL)isEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
- (BOOL)isGK{
    NSString *gkRegex = @"[A-Z0-9a-z-_]{3,32}";
    NSPredicate *gkTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", gkRegex];
    return [gkTest evaluateWithObject:self];
}
- (BOOL)isUrl{
    if(self == nil)
        return NO;
    NSString *url;
//    if (self.length>4 && [[self substringToIndex:4] isEqualToString:@"www."]) {
//        url = [NSString stringWithFormat:@"http://%@",self];
//    }else {
//        url = self;
//    }
    NSString *urlRegex = @"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://((((25[0-5]|2[0-4]\\d|1?\\d?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1?\\d?\\d))|([0-9a-z_!~*'()-]*\\.?))([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.([a-z]{2,6})(:[0-9]{1,4})?([a-zA-Z/?_=]*)\\.\\w{1,5}";
    
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
    
}


+ (NSDictionary *)parameterWithURL:(NSURL *)url {
    return [self parameterWithString:url.absoluteString];
}

+ (NSDictionary *)parameterWithString:(NSString *)urlString {
    NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlString];
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];
    return parm;
}

- (NSDictionary *)decodeParams {
    NSArray *firstArr = [self componentsSeparatedByString:@"?"];
    NSArray *secondArr = [firstArr[1] componentsSeparatedByString:@"&"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < secondArr.count; i ++) {
        NSArray *thirdArr = [secondArr[i] componentsSeparatedByString:@"="];
        [dic setObject:thirdArr[1] forKey:thirdArr[0]];
    }
    return [dic copy];
}



/**
 
 * 网址正则验证 1或者2使用哪个都可以
 
 *
 
 *  @param string 要验证的字符串
 
 *
 
 *  @return 返回值类型为BOOL
 
 */

//- (BOOL)urlValidation:(NSString *)string {
//    
//    NSError *error;
//    // 正则1
////     =@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
//    // 正则2 (http[s]{0,1}|ftp)://
//    
//    NSString *regulaStr =@"([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
//    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
//                                                                          options:NSRegularExpressionCaseInsensitive
//                                                                            error:&error];
//    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
//
//    for (NSTextCheckingResult *match in arrayOfAllMatches){
////        NSString* substringForMatch = [string substringWithRange:match.range];
//        MWLog(@"匹配");
//        return YES;
//    }
//    return NO;
//    
//}

- (NSRange)rangeByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet{
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    for (location = 0; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }
    return NSMakeRange(location, length - location);
}
- (NSRange)rangeByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet{
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    for (length = [self length]; length > 0; length--) {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    return NSMakeRange(location, length - location);
}

- (NSString *)stringByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet {
    return [self substringWithRange:[self rangeByTrimmingLeftCharactersInSet:characterSet]];
}

- (NSString *)stringByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet {
    return [self substringWithRange:[self rangeByTrimmingRightCharactersInSet:characterSet]];
}

//转换拼音
- (NSString *)transformToPinyin {
    if (self.length <= 0) {
        return self;
    }
    NSString *tempString = [self mutableCopy];
    CFStringTransform((CFMutableStringRef)tempString, NULL, kCFStringTransformToLatin, false);
    tempString = (NSMutableString *)[tempString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    tempString = [tempString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [tempString uppercaseString];
}

//是否包含语音解析的图标
- (BOOL)hasListenChar{
    BOOL hasListenChar = NO;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    for (length = [self length]; length > 0; length--) {
        if (charBuffer[length -1] == 65532) {//'\U0000fffc'
            hasListenChar = YES;
            break;
        }
    }
    return hasListenChar;
}

//- (BOOL)hasSubString:(NSString *)sub{
//    if([self isKindOfClass:[NSString class]]  && [self rangeOfString:sub].location !=NSNotFound) {
//        return YES;
//    }else{
//        return NO;
//    }
//}

//判断是不是纯数字
- (BOOL)isNumberCaractor{
    //是否是纯数字
    NSString * regex  = @"^[0-9]*$";
    NSPredicate * pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch   = [pred evaluateWithObject:self];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
    
}

- (BOOL)isNumberWithDian{
//    ^\d+(?:\.\d+)?$
    NSString *regex = @"^[0-9.]*$";
    NSPredicate * pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch   = [pred evaluateWithObject:self];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
}
- (BOOL)isNumberWithX{
    NSString *regex = @"^[0-9Xx]*$";
    NSPredicate * pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch   = [pred evaluateWithObject:self];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
}

//正则匹配用户身份证号15或18位
+ (BOOL)checkIdValid:(NSString *)value {
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length =0;
    if (!value) {
        return NO;
    }else {
        length = value.length;
        //不满足15位和18位，即身份证错误
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray = @[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    // 检测省份身份行政区代码
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO; //标识省份代码是否正确
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return NO;
    }
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;

    int year =0;
    //分为15位、18位身份证进行校验
    switch (length) {
        case 15:
            //获取年份对应的数字
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                //创建正则表达式 NSRegularExpressionCaseInsensitive：不区分字母大小写的模式
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }
            //使用正则表达式匹配字符串 NSMatchingReportProgress:找到最长的匹配字符串后调用block回调
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}(19|20)[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}(19|20)[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            
            if(numberofMatch >0) {
                //1：校验码的计算方法 身份证号码17位数分别乘以不同的系数。从第一位到第十七位的系数分别为：7－9－10－5－8－4－2－1－6－3－7－9－10－5－8－4－2。将这17位数字和系数相乘的结果相加。
                
                int S = [value substringWithRange:NSMakeRange(0,1)].intValue*7 + [value substringWithRange:NSMakeRange(10,1)].intValue *7 + [value substringWithRange:NSMakeRange(1,1)].intValue*9 + [value substringWithRange:NSMakeRange(11,1)].intValue *9 + [value substringWithRange:NSMakeRange(2,1)].intValue*10 + [value substringWithRange:NSMakeRange(12,1)].intValue *10 + [value substringWithRange:NSMakeRange(3,1)].intValue*5 + [value substringWithRange:NSMakeRange(13,1)].intValue *5 + [value substringWithRange:NSMakeRange(4,1)].intValue*8 + [value substringWithRange:NSMakeRange(14,1)].intValue *8 + [value substringWithRange:NSMakeRange(5,1)].intValue*4 + [value substringWithRange:NSMakeRange(15,1)].intValue *4 + [value substringWithRange:NSMakeRange(6,1)].intValue*2 + [value substringWithRange:NSMakeRange(16,1)].intValue *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                
                //2：用加出来和除以11，看余数是多少？余数只可能有0－1－2－3－4－5－6－7－8－9－10这11个数字
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 3：获取校验位
                //4：检测ID的校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;
                }else {
                    return NO;
                }
                
            }else {
                return NO;
            }
        default:
            return NO;
    }
}


////身份证号校验   411522199301020659
//- (BOOL)judgeIdentityStringValid:(NSString *)identityString {
//
//    if (identityString.length != 18) return NO;
//    // 正则表达式判断基本 身份证号是否满足格式
//    NSString *regex = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X|x)$";
//    //  NSString *regex = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
//    NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
//    //如果通过该验证，说明身份证格式正确，但准确性还需计算
//    if(![identityStringPredicate evaluateWithObject:identityString]) return NO;
//
//    //** 开始进行校验 *//
//
//    //将前17位加权因子保存在数组里
//    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
//
//    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
//    NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
//
//    //用来保存前17位各自乖以加权因子后的总和
//    NSInteger idCardWiSum = 0;
//    for(int i = 0;i < 17;i++) {
//        NSInteger subStrIndex = [[identityString substringWithRange:NSMakeRange(i, 1)] integerValue];
//        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
//        idCardWiSum+= subStrIndex * idCardWiIndex;
//    }
//    //计算出校验码所在数组的位置
//    NSInteger idCardMod=idCardWiSum%11;
//    //得到最后一位身份证号码
//    NSString *idCardLast= [identityString substringWithRange:NSMakeRange(17, 1)];
//    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
//    if(idCardMod==2) {
//        if(![idCardLast isEqualToString:@"X"]&& ![idCardLast isEqualToString:@"x"]) {
//            return NO;
//        }
//    }
//    else{
//        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
//        if(![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
//            return NO;
//        }
//    }
//    return YES;
//}

- (BOOL)isTesuChara{
    
    
    NSString *regex = @"[a-zA-Z\\d\u4e00-\u9fa5]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

//判断是否为中文字符或特殊字符
- (BOOL)isChineseCharacters{
    NSString *str = self;
    int b = 0;
    for(int i=0; i< [str length]; i++){
        int  a = [str characterAtIndex:i];
        if ( a > 0x4e00 && a < 0x9fff) {
            b = 1000;
        }
    }
    if (b==1000 || [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1) {
        return NO;
    }else{
       return YES;
    }
}

- (BOOL)utf8Bytes_confineMaxLength:(int)maxLength{
    //---字节处理
    NSInteger bytesCount = strlen([self UTF8String]);
    if (bytesCount > maxLength) {
        return YES;
    }
    return NO;
}

/**
 远程数据处理
 */
+ (NSString *)dictionnaryObjectToString:(NSDictionary *)object {
    NSError *error = nil;
    NSData *stringData =
    [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
//    NSString *jsonString = [object JSONString];
    // 字典对象用系统JSON序列化之后的data，转UTF-8后的jsonString里面会包含"\n"及" "，需要替换掉
//    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    return jsonString;
}

// 本地数据处理
//+ (NSDictionary *)localDataPars:(id)response{
//    NSData *resData = [[NSData alloc] initWithData:[response object]];
//    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil]; //解析
//    NSMutableDictionary *localDic = [NSMutableDictionary dictionary];
//    [localDic setValuesForKeysWithDictionary:resultDic];
//    MWLog(@"网关返回数据：%@",resultDic);
//    if (resultDic[@"return_Parameter"]) {
//        NSDictionary *rootDic =[ NSJSONSerialization JSONObjectWithData:[[resultDic[@"return_Parameter"] base64_decoding] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//        MWLog(@"return_Parameter:%@",rootDic);
//        NSString *status = [NSString stringWithFormat:@"%@",rootDic[@"Status"]];
//        NSMutableDictionary *subDic = [NSMutableDictionary dictionary];
//        [subDic setValuesForKeysWithDictionary:rootDic];
//        subDic[@"Status"] = status;
//        
//        [localDic setObject:subDic forKey:@"return_Parameter"];
//    }else{
//        MWLog(@"******本地数据解析,未返回return_Parameter******");
//    }
//    return localDic;
//}

//+(NSDictionary *)localData_Paras:(id)reponse{
//    NSDictionary *resultDic = [reponse mj_JSONObject];
//    NSMutableDictionary *resultRoot = [NSMutableDictionary dictionaryWithDictionary:resultDic];
//    if (resultDic[@"Result"]) {
//        [resultRoot setValue:[resultDic[@"Result"] stringValue] forKey:@"Result"];
//        NSDictionary *parmer = [[resultDic[@"return_Parameter"] base64_decoding] mj_JSONObject];
//        
//        NSMutableDictionary *parmerRoot = [NSMutableDictionary dictionaryWithDictionary:parmer];
//        if (parmer[@"Status"]) {
//            [parmerRoot setValue:[parmer[@"Status"]stringFormat] forKey:@"Status"];
//        }else{
//           [parmerRoot setValue:@"1111" forKey:@"Status"];
//        }
//        [resultRoot setValue:parmerRoot forKey:@"return_Parameter"];
//    }else{
//       [resultRoot setValue:@"1111" forKey:@"Result"];
//    }
//    
//    return resultRoot;
//}


//+ (NSString *) routerIp {
//    
//    NSString *localDevice_ip = nil;
//    NSString *address = @"error";
//    struct ifaddrs *interfaces = NULL;
//    struct ifaddrs *temp_addr = NULL;
//    int success = 0;
//    // retrieve the current interfaces - returns 0 on success
//    success = getifaddrs(&interfaces);
//    if (success == 0)
//    {
//        // Loop through linked list of interfaces
//        temp_addr = interfaces;
//        //*/
//        while(temp_addr != NULL)
//        /*/
//         int i=255;
//         while((i--)>0)
//         //*/
//        {
//            if(temp_addr->ifa_addr->sa_family == AF_INET)
//            {
//                // Check if interface is en0 which is the wifi connection on the iPhone
//                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
//                {
//                    // Get NSString from C String //ifa_addr
//                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
//                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
//                    
//                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
//                    
//                    //routerIP----192.168.1.255 广播地址
//                    MWLog(@"broadcast address--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
//                    //--192.168.1.106 本机地址
//                    MWLog(@"local device ip--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
//                    localDevice_ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
//                    //--255.255.255.0 子网掩码地址
//                    MWLog(@"netmask--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
//                    //--en0 端口地址
//                    MWLog(@"interface--%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
//                    
//                }
//                
//            }
//            
//            temp_addr = temp_addr->ifa_next;
//        }
//    }
//    // Free memory
//    freeifaddrs(interfaces);
//    in_addr_t i =inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
//    in_addr_t* x =&i;
//    
//    
//    unsigned char *s=getdefaultgateway(x);
//    NSString *ip = [[NSString alloc]init];
//    if (s[3] ==0) {
//        ip=[NSString stringWithFormat:@"%d.%d.%d.1",s[0],s[1],s[2]];
//    }else{
//        ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
//    }
//    MWLog(@"路由器地址-----%@",ip);
//    
//    if (ip &&localDevice_ip && [[localDevice_ip substringToIndex:5] isEqualToString:[ip substringToIndex:5]]) {
//        return ip;
//    }else if(localDevice_ip){
//        NSArray *deviceipArr = [localDevice_ip componentsSeparatedByString:@"."];
//        return [NSString stringWithFormat:@"%@.%@.%@.%@",deviceipArr[0],deviceipArr[1],deviceipArr[2],@"1"];
//    }
//
//    return ip;
//}
//消息处理
//- (NSString *)stringWithCode{
//    if ([[self stringFormat] isEqualToString:@"0001"]) {
//        return @"成功";
//    }else if ([[self stringFormat] isEqualToString:@"0002"]) {
//        return @"失败";
//    }else if ([[self stringFormat] isEqualToString:@"0003"]) {
//        return @"入参缺失";
//    }else if ([[self stringFormat] isEqualToString:@"0004"]) {
//        return @"服务器异常";
//    }else if ([[self stringFormat] isEqualToString:@"0005"]) {
//        return @"服务器异常";
//    }else if ([[self stringFormat] isEqualToString:@"0100"]) {
//        return @"用户已存在";
//    }else if ([[self stringFormat] isEqualToString:@"0101"]) {
//        return @"用户名不合法";
//    }else if ([[self stringFormat] isEqualToString:@"0102"]) {
//        return @"手机号或密码错误";
//    }else if ([[self stringFormat] isEqualToString:@"0103"]) {
//        return @"用户权限异常";
//    }else if ([[self stringFormat] isEqualToString:@"0104"]) {
//        return @"密码不合法";
//    }else if ([[self stringFormat] isEqualToString:@"0105"]) {
//        return @"手机号不合法";
//    }else if ([[self stringFormat] isEqualToString:@"0106"]) {
//        return @"邮箱不合法";
//    }else if ([[self stringFormat] isEqualToString:@"0201"]) {
//        return @"网关异常";
//    }else if ([[self stringFormat] isEqualToString:@"0202"]) {
//        return @"网关已解绑";
//    }else if ([[self stringFormat] isEqualToString:@"0203"]) {
//        return @"插件已卸载";
//    }
//    return @"网络连接超时";
//}

+ (NSString *)speed_Translation:(CGFloat)speed{
    if (speed>=1024 *1024) {
         return  [NSString stringWithFormat:@"%.1fGB/s",speed/(1024.0*1024.0)];
    }else if (speed >=1024*1000){
       return  [NSString stringWithFormat:@"%.1fGB/s",speed/1024.0];
    }else if (speed>=1024){
       return  [NSString stringWithFormat:@"%.1fMB/s",speed/1024.0];
    }else if(speed >=1000){
       return  [NSString stringWithFormat:@"%.1fMB/s",speed/1024.0];
    }
    return [NSString stringWithFormat:@"%.1fKB/s",speed];
}

+ (NSString *)traffic_Translation:(CGFloat )traffic{
    if (traffic>=1024 *1024) {
        return  [NSString stringWithFormat:@"%.2fGB",traffic/(1024.0*1024.0)];
    }else if (traffic >=1024*1000){
        return  [NSString stringWithFormat:@"%.2fGB",traffic/1024.0];
    }else if (traffic>=1024){
        return  [NSString stringWithFormat:@"%.2fMB",traffic/1024.0];
    }else if(traffic >=1000){
        return  [NSString stringWithFormat:@"%.2fMB",traffic/1024.0];
    }
    return [NSString stringWithFormat:@"%.2fKB",traffic];
}


//+ (NSString*) getTheCorrectNum:(NSString*)tempString{
//    if (tempString && tempString.length>1) {
//        while ([tempString hasPrefix:@"0"]){
//            tempString = [tempString substringFromIndex:1];
//            MWLog(@"去掉之后的tempString:%@",tempString);
//        }
//    }
//    return tempString;
//}
//跳转系统设置
+(NSString*)getDefaultWiFiWork{
    return  UIApplicationOpenSettingsURLString;
}

//如果没达到指定日期，返回-1，刚好是这一时间，返回0，否则返回1
+ (int )compareHaveToday{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *dateTime=[formatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [formatter dateFromString:dateTime];
    NSLog(@"---------- currentDate == %@",currentDate);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSDate *date = [dateFormatter dateFromString:@"22-08-2018-000000"];
    
    return [self compareOneDay:currentDate withAnotherDay:date];
}
+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;
    
}

- (NSString *)isTelPhone {
    NSString * str = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL isPhone = [str hasPrefix:@"1"];
    if (!isPhone) {
        return self;
    }
    NSMutableString * phone = [NSMutableString stringWithString:str];
    if (phone.length <= 3) {
        
    } else if (phone.length <= 7) {
        [phone insertString:@" " atIndex:3];
    } else if (phone.length <= 11) {
        [phone insertString:@" " atIndex:7];
        [phone insertString:@" " atIndex:3];
    }
    return phone;
}

@end
