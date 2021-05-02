//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient.h"

@interface DONApiClient ()
@end

@implementation DONApiClient

- (nonnull instancetype)initWithHost:(nonnull NSString *)host {
    return [self initWithHost:host accessToken:nil];
}

- (nonnull instancetype)initWithHost:(nonnull NSString *)host
                         accessToken:(nullable NSString *)accessToken {
    if (self = [super init]) {
        _host = host;
        _accessToken = accessToken;
        
        NSURL *baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/", host]];
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    }
    return self;
}

- (nonnull NSDictionary *)defaultHeaders { 
    return @{
        @"Authorization": [NSString stringWithFormat:@"Bearer %@", self.accessToken]
    };
}

@end
