//
//  WTVASRTool.h
//  WTVVttSDK
//
//  Created by 刘旭鹏 on 2025/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTVASRTool : NSObject

/**
 @param voiceData 录制的二进制文件
 
 @param block
 isSuccess 这次请求是否成功 如果成功
 isSuccess == YES ;msg == 识别内容;
 isSuccess == NO  ;msg == 请求返回的错误信息;
 error就是本次网络请求失败 返回的是网路请求的错误信息
 */
+ (void)wtvReqVoiceWithData:(NSData *)voiceData
                finishBlock:(void (^)(BOOL isSuccess, NSString *msg, NSError *error))block;

@end

NS_ASSUME_NONNULL_END
