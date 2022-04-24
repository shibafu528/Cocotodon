//
// Copyright (c) 2020 shibafu
//

#import "DONStatus.h"
#import "DONStatusContentParser.h"

@implementation DONStatus

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"identity": @"id",
        @"createdAt": @"created_at",
        @"account": @"account",
        @"sensitive": @"sensitive",
        @"spoilerText": @"spoiler_text",
        @"visibility": @"visibility",
        @"URI": @"uri",
        @"URL": @"url",
        @"content": @"content",
        @"reblog": @"reblog",
        @"mediaAttachments": @"media_attachments",
        @"emojis": @"emojis",
        @"poll": @"poll",
        @"favourited": @"favourited",
        @"editedAt": @"edited_at",
    };
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

+ (NSValueTransformer *)visibilityJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"public": @(DONStatusPublic),
        @"unlisted": @(DONStatusUnlisted),
        @"private": @(DONStatusPrivate),
        @"direct": @(DONStatusDirect),
    }];
}

+ (NSValueTransformer *)URIJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)mediaAttachmentsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONMastodonAttachment.class];
}

+ (NSValueTransformer *)emojisJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONEmoji.class];
}

+ (NSValueTransformer *)editedAtJSONTransformer {
    return [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                                          locale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

- (NSString *)expandContent {
    NSString *body = [self parseContentUsingParser];
    
    if (self.spoilerText.length) {
        return [self.spoilerText stringByAppendingFormat:@" | %@", body];
    } else {
        return body;
    }
}

- (NSAttributedString *)expandAttributedContent {
    DONStatusContentParser *parser = [[DONStatusContentParser alloc] initWithString:self.content];
    [parser parse];
    
    NSMutableAttributedString *body = [[NSMutableAttributedString alloc] initWithString:parser.textContent];
    [parser.anchors enumerateObjectsUsingBlock:^(DONStatusContentAnchor * _Nonnull anchor, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = anchor.range;
        NSString *href = anchor.href;
        if (!href.length) {
            href = [parser.textContent substringWithRange:range];
        }
        [body addAttribute:NSLinkAttributeName value:href range:range];
    }];
    
    if (self.spoilerText.length) {
        [body insertAttributedString:[[NSAttributedString alloc] initWithString:[self.spoilerText stringByAppendingString:@"\n\n"]] atIndex:0];
    }
    
    return body;
}

- (NSString *)plainContent {
    return [self parseContentUsingParser];
}

- (NSString *)parseContentUsingParser {
    DONStatusContentParser *parser = [[DONStatusContentParser alloc] initWithString:self.content];
    [parser parse];
    return parser.textContent;
}

- (NSString *)parseContentUsingNSAttributedString {
    NSError *error = nil;
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithData:[self.content dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]
                                                                                    options:@{
                                                                                        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
                                                                                    }
                                                                         documentAttributes:nil
                                                                                      error:&error];
    if (attributed) {
        [attributed addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]] range:NSMakeRange(0, attributed.length)];
        [attributed addAttribute:NSForegroundColorAttributeName value:[NSColor labelColor] range:NSMakeRange(0, attributed.length)];
    }
    
    NSString *body = attributed.string;
    if (error) {
        NSLog(@"Parse error in (%@): %@", self.URL, body);
        body = self.content;
    }
    
    return body;
}

- (DONStatus *)originalStatus {
    return self.reblog ? self.reblog : self;
}

- (mrb_value)mrubyValue:(mrb_state *)mrb {
    return [[MTLJSONAdapter JSONDictionaryFromModel:self error:nil] mrubyValue:mrb];
}

@end
