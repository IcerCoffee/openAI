//
//  NSString+Common.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "NSString+Emojize.h"

@interface NSString (Common)

-(NSString *)mw_dateWithFormat_MM_dd_HH_mm_string;
- (NSDate *)date_FromeString;
+ (NSString *)userAgentStr;

- (NSString *)URLEncoding;
- (NSString *)URLDecoding;
- (NSString *)md5Str;

- (NSURL *)urlWithCodePath;
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width;
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width crop:(BOOL)needCrop;
- (NSURL *)urlImageWithCodePathResizeToView:(UIView *)view;


- (NSString *)stringByRemoveHtmlTag;
+ (NSString *)handelRef:(NSString *)ref path:(NSString *)path;


- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (BOOL)containsEmoji;

- (NSString *)emotionMonkeyName;

+ (NSString *)sizeDisplayWithByte:(CGFloat)sizeOfByte;

- (NSString *)stringByRemoveSpecailCharacters;
- (NSString *)trimWhitespace;
- (BOOL)isEmpty;
- (BOOL)isEmptyOrListening;
//判断是否为整形
- (BOOL)isPureInt;
//判断是否为浮点形
- (BOOL)isPureFloat;
//判断是否是手机号码或者邮箱
//- (BOOL)isPhoneNo;
//判断手机号码格式是否正确

//判断是否为中文字符
- (BOOL)isChineseCharacters;
//判断是否为表情
- (BOOL)isEqualToStringemoji;

- (NSString *)noEmoji;

- (BOOL)valiMobile;

/**
 判断验证码
 */
- (BOOL)checkVertify;
- (BOOL)checkWoPassword;
- (BOOL)uo_checkPassword;
- (BOOL)checkOldPassword;
- (BOOL)checkSetPassword;
- (BOOL)uo_checkPassword_isNumberOrAZ;
- (BOOL)isNumberWithDian;
- (BOOL)isNumberWithX;
- (BOOL)checkLoginPasswordLength;
//身份证号校验
+ (BOOL)checkIdValid:(NSString *)value;
//+ (BOOL)judgeIdentityStringValid:(NSString *)value;
/**
 限制最长字节数（UTF8）
 */
- (BOOL)utf8Bytes_confineMaxLength:(int)maxLength;

- (BOOL)isEmail;
- (BOOL)isGK;
- (BOOL)isUrl;
- (BOOL)urlValidation:(NSString *)string;
+ (NSDictionary *)parameterWithURL:(NSURL *)url;
+ (NSDictionary *)parameterWithString:(NSString *)urlString;
- (NSDictionary *)decodeParams;

- (NSRange)rangeByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
- (NSRange)rangeByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet;

- (NSString *)stringByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet;

//转换拼音
- (NSString *)transformToPinyin;

//是否包含语音解析的图标
- (BOOL)hasListenChar;

//- (BOOL)hasSubString:(NSString *)sub;
/**
 远程数据处理 字典转json
 */
+ (NSString *)dictionnaryObjectToString:(NSDictionary *)object;

/**
    本地数据处理
 */
//+ (NSDictionary *)localDataPars:(id)response;
+(NSDictionary *)localData_Paras:(id)reponse;
/**
 获取路由器的IP地址
 @return 路由器IP
 */
+ (NSString *)routerIp;
- (BOOL)settingIPCHeck;

//判断是不是纯数字
- (BOOL)isNumberCaractor;

- (BOOL)valiUserPhone;
- (BOOL )checkTelNum;
- (BOOL)checkTelCodeNum;
//消息处理
- (NSString *)stringWithCode;

+ (NSString *)speed_Translation:(CGFloat)speed;
+ (NSString *)traffic_Translation:(CGFloat )traffic;

+ (NSString*) getTheCorrectNum:(NSString*)tempString;

+(NSString*)getDefaultWiFiWork;

- (BOOL)isTesuChara;
- (NSString *)isTelPhone;
@end
