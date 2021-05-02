//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DONMastodonApp : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *clientId;
@property (nonatomic, copy, readonly) NSString *clientSecret;
@property (nonatomic, copy, readonly, nullable) NSString *vapidKey;

@end

NS_ASSUME_NONNULL_END
