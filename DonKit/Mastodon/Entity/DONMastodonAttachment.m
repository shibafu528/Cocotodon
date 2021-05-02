//
// Copyright (c) 2021 shibafu
//

#import "DONMastodonAttachment.h"

@implementation DONMastodonAttachment

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"identity": @"id",
        @"type": @"type",
        @"URL": @"url",
        @"previewURL": @"preview_url",
        @"remoteURL": @"remote_url",
        @"textURL": @"text_url",
        @"attachmentDescription": @"description",
        @"blurhash": @"url",
    };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)previewURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)remoteURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)textURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
