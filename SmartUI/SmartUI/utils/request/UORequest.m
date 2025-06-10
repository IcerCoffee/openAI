//
//  UORequest.m
//  Gateway_2_0
//
//  Created by zuo on 2020/1/8.
//  Copyright © 2020 Mile. All rights reserved.
//

#import "UORequest.h"
#import "NSString+Encode.h"
#import "NSString+Common.h"

@interface UORequest ()
@end

@implementation UORequest

+ (instancetype)requestKey:(NSString *)key bodyDict:(NSDictionary *)bodyDict {
    return [[self alloc] initWithKey:key bodyDict:bodyDict];
}

- (instancetype)initWithKey:(NSString *)key bodyDict:(NSDictionary *)bodyDict {
    if (self = [self init]) {
        self.key = key;
        self.bodyDict = bodyDict;
    }
    return self;
}

- (void)requestSuccess:(void (^)(id dataDict))success fail:(void (^)(NSDictionary *dict))fail {
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *rsp = request.responseObject[@"RSP"];
        NSString *logId = request.responseObject[@"LOGID"];
        NSString *code = rsp[@"RSP_CODE"];
        if ([code isEqualToString:@"1001"]|| [code isEqualToString:@"302"]) {
            NSLog(@"token expire !!!");
        }
        if ([code isEqualToString:@"10004"] || [code isEqualToString:@"10002"]) {
//            [self alertHomeExpire:code];
            NSLog(@"当前家庭已解散 || 您已被移出该家庭");
        }
        if ([code isEqualToString:@"0000"]) {
            success(rsp[@"DATA"]);
        } else {
            fail(request.responseObject);
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        fail(request.responseObject);
    }];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (id)requestArgument {
    NSString *dateStr = @(@([[NSDate date] timeIntervalSince1970]*1000).integerValue).stringValue;
    NSString *channel = @"woapp";
    NSString *reqseq = kReqSeq;
    NSDictionary *headerDict = @{
        @"key":self.key,
        @"resTime":dateStr,
        @"reqSeq":reqseq,
        @"channel":channel,
        @"version":@"",
        @"sign":[[NSString stringWithFormat:@"%@%@%@%@%@",self.key,dateStr,reqseq,channel,@""] md5Str],
    };
    return  @{
        @"header":headerDict,
        @"body":self.bodyDict,
    };
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return @{
        @"appversion":@"999.0.0",
        @"accesstoken":@"5500e9d7-4da1-4060-b3a6-13a4740c4ec5",
        @"x-encryption-type":@"AES",
        @"platform":@"2",
        @"appchannel":@"appstore",
        @"clientsign": [@"com.chinaunicom.WoApp" MD5_Low],
        @"cacherefresh":@"1"
    };
}

- (NSString *)baseUrl {
//    if ([UOURLHelper isTestEv]) {
        return @"https://test-iot.smartont.net";
//    }
//    return [UBTool changeBaseUrlWithKey:self.key];
//    return @"https://iotpservice.smartont.net";
}


@end
