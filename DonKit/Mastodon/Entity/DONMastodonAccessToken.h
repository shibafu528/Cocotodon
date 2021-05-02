//
// Copyright (c) 2020 shibafu
//

#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DONMastodonAccessToken : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *accessToken;
@property (nonatomic, copy, readonly) NSString *tokenType;
@property (nonatomic, copy, readonly) NSString *scope;
@property (nonatomic, copy, readonly) NSNumber *createdAt;

@end

NS_ASSUME_NONNULL_END
