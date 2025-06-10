#import "UDPManager.h"
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>

NSString * const UDPManagerDidReceiveNotification = @"UDPManagerDidReceiveNotification";
NSString * const UDPManagerMessageKey = @"message";

@interface UDPManager ()
{
    int _socketFD;
    struct sockaddr_in _broadcastAddr;
    dispatch_queue_t _queue;
}
@end

@implementation UDPManager

+ (instancetype)sharedInstance {
    static UDPManager *mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.example.udp", DISPATCH_QUEUE_SERIAL);
        self.broadcastAddress = @"255.255.255.255";
    }
    return self;
}

- (void)setBroadcastAddress:(NSString *)broadcastAddress {
    _broadcastAddress = [broadcastAddress copy];
    memset(&_broadcastAddr, 0, sizeof(_broadcastAddr));
    _broadcastAddr.sin_len = sizeof(_broadcastAddr);
    _broadcastAddr.sin_family = AF_INET;
    _broadcastAddr.sin_port = htons(12306);
    inet_aton(_broadcastAddress.UTF8String, &_broadcastAddr.sin_addr);
}

- (void)startListening {
    if (_socketFD > 0) return;
    _socketFD = socket(AF_INET, SOCK_DGRAM, 0);
    if (_socketFD <= 0) {
        perror("socket");
        return;
    }
    int yes = 1;
    setsockopt(_socketFD, SOL_SOCKET, SO_BROADCAST, &yes, sizeof(yes));
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(12306);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind(_socketFD, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind");
        close(_socketFD);
        _socketFD = 0;
        return;
    }

    dispatch_async(_queue, ^{
        while (1) {
            char buf[1024];
            struct sockaddr_in from;
            socklen_t len = sizeof(from);
            ssize_t n = recvfrom(self->_socketFD, buf, sizeof(buf) - 1, 0, (struct sockaddr *)&from, &len);
            if (n > 0) {
                buf[n] = '\0';
                NSString *msg = [NSString stringWithUTF8String:buf];
                [[NSNotificationCenter defaultCenter] postNotificationName:UDPManagerDidReceiveNotification object:self userInfo:@{UDPManagerMessageKey: msg}];
            } else if (n < 0) {
                perror("recvfrom");
            }
        }
    });
}

- (void)sendMessage:(NSString *)message {
    if (_socketFD <= 0) {
        [self startListening];
    }
    const char *msg = [message UTF8String];
    ssize_t len = sendto(_socketFD, msg, strlen(msg), 0, (struct sockaddr *)&_broadcastAddr, sizeof(_broadcastAddr));
    if (len < 0) {
        perror("sendto");
    }
}

@end

