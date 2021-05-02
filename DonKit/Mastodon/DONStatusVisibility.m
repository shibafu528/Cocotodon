//
// Copyright (c) 2020 shibafu
//

#import "DONStatusVisibility.h"

NSString* __nonnull NSStringFromStatusVisibility(DONStatusVisibility visibility) {
    switch (visibility) {
        case DONStatusPublic:
            return @"public";
            break;
        case DONStatusUnlisted:
            return @"unlisted";
            break;
        case DONStatusPrivate:
            return @"private";
            break;
        case DONStatusDirect:
            return @"direct";
            break;
    }
    return @"";
}

DONStatusVisibility DONStatusVisibilityFromString(NSString *visibility) {
    if ([visibility isEqualToString:@"public"]) {
        return DONStatusPublic;
    } else if ([visibility isEqualToString:@"unlisted"]) {
        return DONStatusUnlisted;
    } else if ([visibility isEqualToString:@"private"]) {
        return DONStatusPrivate;
    } else if ([visibility isEqualToString:@"direct"]) {
        return DONStatusDirect;
    }
    return -1;
}
