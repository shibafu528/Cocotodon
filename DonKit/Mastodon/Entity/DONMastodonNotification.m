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

+ (NSValueTransformer *)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"follow": @(DONMastodonNotificationFollowType),
        @"follow_request": @(DONMastodonNotificationFollowRequestType),
        @"mention": @(DONMastodonNotificationMentionType),
        @"reblog": @(DONMastodonNotificationReblogType),
        @"favourite": @(DONMastodonNotificationFavoriteType),
        @"poll": @(DONMastodonNotificationPollType),
        @"status": @(DONMastodonNotificationStatusType),
    }];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

@end
