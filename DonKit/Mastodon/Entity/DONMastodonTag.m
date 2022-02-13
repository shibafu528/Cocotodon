//
// Copyright (c) 2022 shibafu
//

#import "DONMastodonTag.h"

@implementation DONMastodonTag

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"name": @"name",
        @"URL": @"url",
    };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
