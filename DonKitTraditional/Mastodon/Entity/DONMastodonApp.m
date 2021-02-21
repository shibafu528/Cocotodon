//
// Copyright (c) 2020 shibafu
//

#import "DONMastodonApp.h"

@implementation DONMastodonApp

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"clientId": @"client_id",
        @"clientSecret": @"client_secret",
        @"vapidKey": @"vapid_key",
    };
}

@end
