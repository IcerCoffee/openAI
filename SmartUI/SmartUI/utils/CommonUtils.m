//
//  CommonUtils.m
//  SmartUI
//
//  Created by why on 2024/10/17.
//

#import "CommonUtils.h"
#import <CommonCrypto/CommonCrypto.h>
#import <WtvASRSDK/WtvASRSDK.h>
#import "UDPManager.h"
@implementation CommonUtils

+ (instancetype)sharedInstance{
    static CommonUtils *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CommonUtils alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:_sharedInstance selector:@selector(handleUDPMessage:) name:UDPManagerDidReceiveNotification object:nil];
    });
    return _sharedInstance;
}



-(void)updateDeviceNameWithCuei:(NSString *)cuei name:(NSString *)name complete:(void(^)(id result))result{
    NSLog(@"主工程发起修改设备信息请求 ： cuei:%@   -> updateName:%@",cuei,name);
    result(@{@"code":@"0000",@"MSG":@"操作成功"});
}



-(void)voiceRecognitionService:(NSURL *)fileUrl{
    NSData *data = [NSData dataWithContentsOfURL:fileUrl];
    
    [WTVASRTool wtvReqVoiceWithData:data finishBlock:^(BOOL isSuccess, NSString * _Nonnull msg, NSError * _Nonnull error) {
        if (isSuccess) {
            NSLog(@"识别的文字：%@",msg);
        }
    }];
}

// JS 调用此方法发送 UDP 广播
- (void)sendUDPMessage:(NSString *)message broadcastIP:(NSString *)ip {
    if (ip.length > 0) {
        [UDPManager sharedInstance].broadcastAddress = ip;
    }
    [[UDPManager sharedInstance] sendMessage:message];
}

- (void)handleUDPMessage:(NSNotification *)noti {
    NSString *msg = noti.userInfo[UDPManagerMessageKey];
    NSLog(@"Received UDP message: %@", msg);
}









-(NSDictionary *)getCurrentUser{
    return @{
        @"phone":@"155555555",
        @"name":@"Jhon Dameage"
    };
}

/// AES解密
/// - Parameters:
///   - base64String: AES解密字符串
///   - key: 密钥
+ (NSString *)decryptAES128WithBase64String:(NSString *)base64String key:(NSString *)key {
    // 将 base64 字符串解码为数据
        
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    if (cipherData == nil) {
        NSLog(@"Invalid base64 string");
        return nil;
    }
    
    // 初始化密钥和 IV
    char keyPtr[kCCKeySizeAES128 + 1]; // AES 128, 密钥长度是 16 字节
    bzero(keyPtr, sizeof(keyPtr)); // 清空密钥
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 初始化 IV（使用 16 字节的全零 IV，如果需要可更改）
    char iv[kCCBlockSizeAES128] = {0};  // 16 字节 IV 全零

    size_t numBytesDecrypted = 0;
    NSMutableData *decryptedData = [NSMutableData dataWithLength:cipherData.length + kCCBlockSizeAES128];
    
    // 执行 AES 解密
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, // 解密操作
                                          kCCAlgorithmAES128, // 使用 AES128 算法
                                          kCCOptionPKCS7Padding, // 使用 PKCS7 填充
                                          keyPtr, // 密钥
                                          kCCKeySizeAES128, // 密钥长度
                                          iv, // 初始化向量
                                          cipherData.bytes, // 密文
                                          cipherData.length, // 密文长度
                                          decryptedData.mutableBytes, // 解密后的数据
                                          decryptedData.length, // 解密缓冲区的最大长度
                                          &numBytesDecrypted); // 解密后的字节数
    
    if (cryptStatus == kCCSuccess) {
        // 解密成功，调整实际解密数据的长度
        decryptedData.length = numBytesDecrypted;
        // 将解密数据转为字符串
        NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        return decryptedString;
    } else {
        NSLog(@"Decryption failed with status: %d", cryptStatus);
        return nil;
    }
}



+ (BOOL)isIPhoneXseries {
    static NSInteger isIPhoneXseries = -1;
    if (isIPhoneXseries < 0) {
        if (@available(iOS 11.0, *)) {
            // 新建的window会被添加到[UIApplication sharedApplication].windows中
            // 放到autoreleasepool中减少新建window的生命周期，避免被外部使用
            @autoreleasepool {
                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                if (!window) {
                    window = [[UIWindow alloc] init];
                }
                isIPhoneXseries = window.safeAreaInsets.bottom > 0.01 ? 1 : 0;
            }
        } else {
            isIPhoneXseries = 0;
        }
    }
    return isIPhoneXseries > 0;
}


@end
