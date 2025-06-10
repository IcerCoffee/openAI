//
//  UORequest.h
//  Gateway_2_0
//
//  Created by zuo on 2020/1/8.
//  Copyright © 2020 Mile. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface UORequest : YTKRequest
@property (copy, nonatomic) NSString *key;
@property (strong, nonatomic) NSDictionary *bodyDict;
+ (instancetype)requestKey:(NSString *)key bodyDict:(NSDictionary *)bodyDict;
- (void)requestSuccess:(void (^)(id dataDict))success fail:(void (^)(NSDictionary *dict))fail;
@end

NS_ASSUME_NONNULL_END
