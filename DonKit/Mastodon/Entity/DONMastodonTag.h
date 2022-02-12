//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents a hashtag used within the content of a status.
/// https://docs.joinmastodon.org/entities/tag/
@interface DONMastodonTag : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSURL *URL;

@end

NS_ASSUME_NONNULL_END
