//
//  NSString+Encode.m
//  Gateway_2_0
//
//  Created by 夏明伟 on 2017/5/22.
//  Copyright © 2017年 Mile. All rights reserved.
//

#import "NSString+Encode.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Encode.h"
#import <GTMBase64/GTMBase64.h>

@implementation NSString (Encode)
- (NSString *)ZHWJSHA256{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes,(CC_LONG) data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}
- (NSString *)MD5_Low{
    const char *fooData = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    NSMutableString *saveResult = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    return [saveResult lowercaseString];
}

- (NSString *)base64{
    NSData *nsdata = [self
                      dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    return base64Encoded;
}

//- (NSString *)base64_decoding{
//    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self options:0];
//    NSString *decodedString = [[[NSString alloc] initWithData:[decodedData UTF8Data] encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
//
//    return decodedString;
//}


-(NSData*) hexToBytes {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

- (NSString *)encode_AES256_NOPaddingWithKey:(NSString *)key{
    //    ///用户SN
    //    NSString *sn = [[NSUserDefaults standardUserDefaults]objectForKey:@"LocalSN"];
    NSData *passData = [self dataUsingEncoding:NSUTF8StringEncoding ];
    NSData *encodePassData  = [passData hyb_AESEncrypt_NoPaddingWithKey:key];
    Byte *plainTextByte = (Byte *)[encodePassData bytes];
    NSMutableString *encodePass = [NSMutableString string];
    //字节以偶数位打印
    for(int i=0;i<[encodePassData length];i++){
        //        printf("%02x",plainTextByte[i]);
        [encodePass appendString:[NSString stringWithFormat:@"%02x",plainTextByte[i]]];
    }
//    MWLog(@"加密后：%@ sn:%@",encodePass,key);
    
    return encodePass;
}

- (NSString *)dncode_AES256_NOPaddingWithKey:(NSString *)key{
    
    NSData *testKeyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encodeData2 = [NSData dataWithBytes:[[self hexToBytes] bytes] length:[self hexToBytes].length];
    NSString *str2 = [[NSString alloc]initWithData:[encodeData2 AES256DecryptWithKeyValue:testKeyData] encoding:NSUTF8StringEncoding];
//    MWLog(@"解密：%@",str2);
    return str2;
}

/**
 3DES/CBC/PCKCS5Padding

 @param key 密钥
 @param operation 模式：加密还是解密
 @return 加密或者解密后的内容
 */
- (NSString *)mw_triple3DESUsingKey:(NSString *)key option:(CCOperation)operation{
    const void *vplainText;
    size_t plainTextBufferSize;
    if (operation == kCCDecrypt){//解密
        NSData *EncryptData = [GTMBase64 decodeData:[self dataUsingEncoding:NSUTF8StringEncoding]];
        plainTextBufferSize = [EncryptData length];
        vplainText = (const void *)[EncryptData bytes];
    } else{//加密
        NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [data length];
        vplainText = (const void *)[data bytes];
    }
    NSData *keyData = [self keyHandleWithKey:key];
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vkey = (const void *)[keyData bytes];//(const void *) [gkey UTF8String];

    ccStatus = CCCrypt(operation,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       nil, // iv 没有偏移量，置为nil
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    NSString *result;
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    if (operation == kCCDecrypt){
        result = [[NSString alloc] initWithData:myData
                                       encoding:NSUTF8StringEncoding];
    }else{
        result = [GTMBase64 stringByEncodingData:myData];
    }
    return result;
}

//补充方法
//16位MD5加密
+ (NSData *)MD5Digest:(NSData *)input {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input.bytes, (CC_LONG)input.length, result);
    return [[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}
// 24位 MD5
- (NSData *)keyHandleWithKey:(NSString *)key {
    //key 的处理，生成16位MD5
    NSData  *keyMd5Data = [NSString MD5Digest:[key dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableData *keyData = [NSMutableData dataWithData:keyMd5Data];
    [keyData setLength:24];
    [keyData replaceBytesInRange:NSMakeRange(16, 8) withBytes:[keyMd5Data bytes] length:8];
    return keyData;
}
@end


#pragma mark NSString URLEncoding
@implementation NSString (URLEncoding)

- (NSString *)urlEncode
{
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < self.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(self.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [self rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [self substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}


- (NSString*)urlDecode
{
    NSString *deplussed = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [deplussed stringByRemovingPercentEncoding];
#pragma clang diagnostic pop
}

@end


#pragma mark NSString JSON
@implementation NSString (JSON)

- (id)uo_objectFromJSONString
{
    NSData *JSONData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:JSONData
                                           options:0
                                             error:nil];
}

@end

static NSString *const kQuerySeparator  = @"&";
static NSString *const kQueryDivider    = @"=";
static NSString *const kQueryBegin      = @"?";
static NSString *const kFragmentBegin   = @"#";

@implementation NSString (URLQuery)

- (NSDictionary*)uo_URLQueryDictionary
{
    NSMutableDictionary *mute = @{}.mutableCopy;
    for (NSString *query in [self componentsSeparatedByString:kQuerySeparator]) {
        NSArray *components = [query componentsSeparatedByString:kQueryDivider];
        if (components.count == 0) {
            continue;
        }
        NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id value = nil;
        if (components.count == 1) {
            // key with no value
            value = [NSNull null];
        }
        if (components.count == 2) {
            value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // cover case where there is a separator, but no actual value
            value = [value length] ? value : [NSNull null];
        }
        if (components.count > 2) {
            NSString *prefixStr = [NSString stringWithFormat:@"%@=",components[0]];
            value = [[query substringFromIndex:prefixStr.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        if (value == nil || value == [NSNull null]) {
            continue;
        } else {
            mute[key] = value;
        }
    }
    return mute.count ? mute.copy : nil;
}

@end
