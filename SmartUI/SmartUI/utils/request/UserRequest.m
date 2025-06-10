//
//  UserRequest.m
//  Gateway_2_0
//
//  Created by zuo on 2020/9/25.
//  Copyright © 2020 Mile. All rights reserved.
//

#import "UserRequest.h"
#import "NSString+Common.h"
#import "NSString+AES128.h"
@implementation UserRequest


- (void)requestSuccess:(void (^)(id  _Nonnull dataDict))success fail:(void (^)(NSDictionary *dict))fail {
    [super requestSuccess:^(id  _Nonnull dataDict) {
        NSDictionary *dict = [[NSString AES128CBC_PKCS5Padding_DecryptString:dataDict key:[self getClientSecret]] mj_JSONObject] ?: @{};
        success(dict);
    } fail:^(NSDictionary * _Nonnull dict) {
        fail(dict);
    }];
}

-(NSString *)getClientSecret {
//    if ([UOURLHelper isTestEv]) {
        return @"Xo532neJitGpCMVr";
//    }
//    return @"R68VBxUs7Cv87VsN";
}


- (id)requestArgument {
    NSString *dateStr = @(@([[NSDate date] timeIntervalSince1970]*1000).integerValue).stringValue;
    NSString *channel = @"com.chinaunicom.WoApp";
    NSString *reqseq = kReqSeq;
    NSDictionary *headerDict = @{
        @"key":self.key,
        @"resTime":dateStr,
        @"reqSeq":reqseq,
        @"channel":channel,
        @"version":@"",
        @"sign":[[NSString stringWithFormat:@"%@%@%@%@%@",self.key,dateStr,reqseq,channel,@""] md5Str],
    };
    NSMutableDictionary *finalBodyDict = [NSMutableDictionary new];
    finalBodyDict[@"clientId"] = @"1001000001";
    finalBodyDict[@"param"] = [self getParamStr];
    return  @{
        @"header":headerDict,
        @"body":finalBodyDict,
    };
}

- (NSString *)getParamStr {
    NSString *paramStr = [[self.bodyDict mj_JSONString] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    paramStr = [NSString AES128CBC_PKCS5Padding_EncryptStrig:paramStr key:[self getClientSecret]];
    paramStr = [paramStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    paramStr = [paramStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return paramStr;
    
}

- (NSString *)requestUrl {
    return @"/woapi/dispatcher";
}

@end
