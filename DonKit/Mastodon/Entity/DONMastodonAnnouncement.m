//
// Copyright (c) 2021 shibafu
//

#import "DONMastodonAnnouncement.h"
#import "DONStatusContentParser.h"

@implementation DONMastodonAnnouncement

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"identity": @"id",
        @"content": @"content",
        @"startsAt": @"starts_at",
        @"endsAt": @"ends_at",
        @"allDay": @"all_day",
        @"publishedAt": @"published_at",
        @"updatedAt": @"updated_at",
        @"read": @"read",
        @"emojis": @"emojis",
        @"reactions": @"reactions",
    };
}

+ (NSValueTransformer *)startsAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

+ (NSValueTransformer *)endsAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

+ (NSValueTransformer *)publishedAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

+ (NSValueTransformer *)emojisJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONEmoji.class];
}

+ (NSValueTransformer *)reactionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONMastodonAnnouncementReaction.class];
}

- (NSAttributedString *)expandAttributedContent {
    DONStatusContentParser *parser = [[DONStatusContentParser alloc] initWithString:self.content];
    [parser parse];
    
    NSMutableAttributedString *body = [[NSMutableAttributedString alloc] initWithString:parser.textContent];
    [parser.linkRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull value, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = value.rangeValue;
        [body addAttribute:NSLinkAttributeName value:[parser.textContent substringWithRange:range] range:range];
    }];
    
    return body;
}

@end
