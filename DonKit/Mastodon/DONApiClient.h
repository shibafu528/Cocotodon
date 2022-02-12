//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiSuccessCallback)(NSURLSessionDataTask *__nonnull task, id __nullable responseObject);
typedef void (^DONApiFailureCallback)(NSURLSessionDataTask *__nullable task, NSError *__nullable error);

@interface DONApiClient : NSObject

@property (nonatomic, copy, readonly) NSString *host;
@property (nonatomic, copy, readonly) NSString *accessToken;
@property (nonatomic, readonly) AFHTTPSessionManager *manager;

- (instancetype) init __attribute__((unavailable("init is not available")));

- (instancetype) initWithHost:(NSString*)host;

- (instancetype) initWithHost:(NSString*)host
                  accessToken:(nullable NSString*)accessToken NS_DESIGNATED_INITIALIZER;

- (NSDictionary*) defaultHeaders;

@end

NS_ASSUME_NONNULL_END

#import "API/DONApiClient+Accounts.h"
#import "API/DONApiClient+Apps.h"
#import "API/DONApiClient+Search.h"
#import "API/DONApiClient+Statuses.h"
#import "API/DONApiClient+Timelines.h"
#import "API/DONApiClient+Streaming.h"
