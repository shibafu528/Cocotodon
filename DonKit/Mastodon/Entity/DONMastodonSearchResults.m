//
// Copyright (c) 2022 shibafu
//

#import "DONMastodonSearchResults.h"

@implementation DONMastodonSearchResults

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"accounts": @"accounts",
        @"statuses": @"statuses",
        @"hashtags": @"hashtags",
    };
}

+ (NSValueTransformer *)accountsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONMastodonAccount.class];
}

+ (NSValueTransformer *)statusesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONStatus.class];
}

+ (NSValueTransformer *)hashtagsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONMastodonTag.class];
}

@end
