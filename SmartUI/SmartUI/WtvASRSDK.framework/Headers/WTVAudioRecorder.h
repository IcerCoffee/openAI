//
//  WTVAudioRecorder.h
//  WoTV
//
//  Created by 刘旭鹏 on 2025/4/9.
//  Copyright © 2025 zhanglinan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 录音完成会触发此Block
 data为录音文件
 audioTimeLength为录音总时长 现在默认 60s最大时长
 */
typedef void(^AudioRecorderFinishRecordingBlock)(NSData *data, NSUInteger audioTimeLength);

/**
 当录音开始时会触发此Block
 isRecording为是否成功启动录音
 */
typedef void(^AudioStartRecordingBlock)(BOOL isRecording);

/**
 当录音失败会触发此Block
 reason为录音错误信息
 */
typedef void(^AudioRecordingFailBlock)(NSString *reason);

/**
 当录音时候会持续触发此Block
 power是音量变化 取值 0.0～1.0
/ */
typedef void(^AudioSpeakPowerBlock)(float power);

@interface WTVAudioRecorder : NSObject

@property (nonatomic, copy) AudioRecorderFinishRecordingBlock audioRecorderFinishRecording;  //录音完成回调

@property (nonatomic, copy) AudioStartRecordingBlock audioStartRecording;                    //开始录音回调

@property (nonatomic, copy) AudioRecordingFailBlock audioRecordingFail;                      //录音失败回调

@property (nonatomic, copy) AudioSpeakPowerBlock audioSpeakPower;                            //音频值测量回调

+ (WTVAudioRecorder *)sharedInstance;

/**
 开始录音
 */
- (void)startRecording;

/**
 停止录音
 */
- (void)stopRecording;

@end

NS_ASSUME_NONNULL_END
