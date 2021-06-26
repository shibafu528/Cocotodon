//
// Copyright (c) 2021 shibafu
//

#import "DONMastodonAnnouncementReaction.h"

@implementation DONMastodonAnnouncementReaction

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"name": @"name",
        @"count": @"count",
        @"me": @"me",
        @"URL": @"url",
        @"staticURL": @"static_url",
    };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)staticURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
