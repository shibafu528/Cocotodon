//
// Copyright (c) 2021 shibafu
//

#import "DONStatusContext.h"

@implementation DONStatusContext

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"ancestors": @"ancestors",
        @"descendants": @"descendants",
    };
}

+ (NSValueTransformer *)ancestorsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONStatus.class];
}

+ (NSValueTransformer *)descendantsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:DONStatus.class];
}

@end
