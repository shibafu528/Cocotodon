//
// Copyright (c) 2021 shibafu
//

#import "DONMastodonNotification.h"

@implementation DONMastodonNotification

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"identity": @"id",
        @"rawType": @"type",
        @"createdAt": @"created_at",
        @"account": @"account",
        @"status": @"status",
    };
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

- (DONMastodonNotificationType)type {
    NSNumber *value = @{
        @"follow": @(DONMastodonNotificationFollowType),
        @"follow_request": @(DONMastodonNotificationFollowRequestType),
        @"mention": @(DONMastodonNotificationMentionType),
        @"reblog": @(DONMastodonNotificationReblogType),
        @"favourite": @(DONMastodonNotificationFavoriteType),
        @"poll": @(DONMastodonNotificationPollType),
        @"status": @(DONMastodonNotificationStatusType),
        @"update": @(DONMastodonNotificationUpdateType),
    }[self.rawType];
    if (value) {
        return value.intValue;
    } else {
        return DONMastodonNotificationUnknown;
    }
}

@end
