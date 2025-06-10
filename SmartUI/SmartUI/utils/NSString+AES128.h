//
//  NSString+AES128.h
//  ceshi
//
//  Created by hushuangfei on 16/7/23.
//  Copyright © 2016年 胡双飞. All rights reserved.
//  AES/CBC/PKCS5Padding 

#import <Foundation/Foundation.h>

@interface NSString (AES128)

/**
 *  加密
 *
 *  @param string 需要加密的string
 *  @param key    公钥
 *
 *  @return 加密后的字符串
 */
+ (NSString *)AES128CBC_PKCS5Padding_EncryptStrig:(NSString *)string key:(NSString*)key;

/**
 *  解密
 *
 *  @param string 加密的字符串
 *  @param key    钥匙（公钥）
 *
 *  @return 解密后的内容
 */
+ (NSString *)AES128CBC_PKCS5Padding_DecryptString:(NSString *)string key:(NSString *)key;

+ (NSString *)md5SwiftSting:(NSString *)str ;

//加密
+ (NSString *)AES128CBC_PKCS5Padding_EncryptStrig:(NSString *)string key:(NSString*)key iv:(NSString *)iv;

//解密
+ (NSString *)AES128CBC_PKCS5Padding_DecryptString:(NSString *)string key:(NSString *)key iv:(NSString *)iv;

- (NSString *)md5Str;
@end
