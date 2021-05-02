//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DONStatusVisibility) {
    DONStatusPublic,
    DONStatusUnlisted,
    DONStatusPrivate,
    DONStatusDirect,
};

NSString* __nonnull NSStringFromStatusVisibility(DONStatusVisibility visibility);

DONStatusVisibility DONStatusVisibilityFromString(NSString *visibility);

NS_ASSUME_NONNULL_END
