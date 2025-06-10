//
//  CommonUtils.h
//  SmartUI
//
//  Created by why on 2024/10/17.
//

#import <Foundation/Foundation.h>
#import <insideSDK/InsideSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonUtils : NSObject <InsideSDKProtocol>

+(instancetype)sharedInstance;

+ (NSString *)decryptAES128WithBase64String:(NSString *)base64String key:(NSString *)key;

-(void)voiceRecognitionService:(NSURL *)fileUrl;
@end

NS_ASSUME_NONNULL_END
