//
//  NSData+Encode.h
//  Gateway_2_0
//
//  Created by 夏明伟 on 2017/5/22.
//  Copyright © 2017年 Mile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encode)
- (NSData *)hyb_AESEncrypt_NoPaddingWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKeyValue:(NSData *)key;

- (NSData *)UTF8Data;

@end
