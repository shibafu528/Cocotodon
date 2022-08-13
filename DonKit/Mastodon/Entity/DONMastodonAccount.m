//
// Copyright (c) 2020 shibafu
//

#import "DONMastodonAccount.h"

@implementation DONMastodonAccount

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"identity": @"id",
        @"username": @"username",
        @"acct": @"acct",
        @"note": @"note",
        @"URL": @"url",
        @"avatar": @"avatar",
        @"avatarStatic": @"avatar_static",
        @"header": @"header",
        @"headerStatic": @"header_static",
    };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)avatarJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)avatarStaticJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (NSString *)fullAcct {
    if ([self.acct containsString:@"@"]) {
        return self.acct;
    } else {
        return [NSString stringWithFormat:@"%@@%@", self.acct, [self.URL host]];
    }
}

@end
