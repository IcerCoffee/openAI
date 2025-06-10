//
//  NSString+Base64After3DES.h
//  WoHome
//
//  Created by EastElsoft on 2018/3/19.
//  Copyright © 2018年 AnatoleZho. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    WHEncrypt,
    WHDecrypt,
} WH3DesCCOpreationType;

@interface NSString (Base64After3DES)

/**
 *  3DES加密并转Base64
 *
 *  @param plainText        要加密的字符串
 *  @param type 系统固定参数: kCCEncrypt
 *  @param key              自己设定的秘钥
 *
 *  @return 3DES加密后并转Base64的字符串
 */
+ (NSString*)TripleDES:(NSString*)plainText encryptOrDecrypt:(WH3DesCCOpreationType)type key:(NSString*)key; // 这个分类需要注意-fno-objc-arc的问题(需要给这个分类的.m和GTMBase64.m添加)


/**
 3DES/CBC/PCKCS5Padding
 
 @param key 密钥
 @param type 模式：加密还是解密
 @return 加密或者解密后的内容
 */
- (NSString *)mw_triple3DESUsingKey:(NSString *)key option:(WH3DesCCOpreationType)type;




/**
 判断是不是九宫格
 @return YES(是九宫格拼音键盘)
 */
- (BOOL)isNineKeyBoard;

/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)hasEmoji:(NSString*)string;

+(BOOL)isContainsEmoji:(NSString *)string;

//判断是不是纯数字
- (BOOL)isNumberCaractor;

-(BOOL)cueiMethod;
@end
