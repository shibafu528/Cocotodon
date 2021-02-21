//
// Copyright (c) 2021 shibafu
//

#import "DONMastodonNotification.h"

@implementation DONMastodonNotification

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"identity": @"id",
        @"type": @"type",
        @"createdAt": @"created_at",
        @"account": @"account",
        @"status": @"status",
    };
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

@end
