//
// Copyright (c) 2021 shibafu
//

#import "DONEmoji.h"

@implementation DONEmoji

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"shortcode": @"shortcode",
        @"URL": @"url",
        @"staticURL": @"static_url",
        @"visibleInPicker": @"visible_in_picker",
        @"category": @"category",
    };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)staticURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
