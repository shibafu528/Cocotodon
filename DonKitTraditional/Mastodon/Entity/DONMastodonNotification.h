//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "DONMastodonAccount.h"
#import "DONStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface DONMastodonNotification : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSString *identity;
@property (nonatomic, readonly) NSString *type; // TODO: Enumにする?
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) DONMastodonAccount *account;
@property (nonatomic, readonly, nullable) DONStatus *status;

@end

NS_ASSUME_NONNULL_END
