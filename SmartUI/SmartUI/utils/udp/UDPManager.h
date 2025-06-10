#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Notification when a UDP message is received
extern NSString * const UDPManagerDidReceiveNotification;
/// Key for the message string inside the notification userInfo
extern NSString * const UDPManagerMessageKey;

@interface UDPManager : NSObject

+ (instancetype)sharedInstance;

/// Broadcast address, default 255.255.255.255
@property (nonatomic, copy) NSString *broadcastAddress;

/// Start listening on port 12306
- (void)startListening;

/// Send message to current broadcast address on port 12306
- (void)sendMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
