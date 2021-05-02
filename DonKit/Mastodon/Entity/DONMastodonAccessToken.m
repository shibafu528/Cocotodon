//
// Copyright (c) 2020 shibafu
//

#import "DONMastodonAccessToken.h"

@implementation DONMastodonAccessToken

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"accessToken": @"access_token",
        @"tokenType": @"token_type",
        @"scope": @"scope",
        @"createdAt": @"created_at",
    };
}

@end
