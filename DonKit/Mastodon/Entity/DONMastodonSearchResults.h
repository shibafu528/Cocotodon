//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "DONMastodonAccount.h"
#import "DONStatus.h"
#import "DONMastodonTag.h"

NS_ASSUME_NONNULL_BEGIN

/// Represents the results of a search.
/// https://docs.joinmastodon.org/entities/results/
@interface DONMastodonSearchResults : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSArray<DONMastodonAccount *> *accounts;
@property (nonatomic, readonly) NSArray<DONStatus *> *statuses;
@property (nonatomic, readonly) NSArray<DONMastodonTag *> *hashtags;

@end

NS_ASSUME_NONNULL_END
