//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "DONMastodonAccount.h"
#import "DONStatus.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DONMastodonNotificationType) {
    DONMastodonNotificationFollowType = 1,
    DONMastodonNotificationFollowRequestType,
    DONMastodonNotificationMentionType,
    DONMastodonNotificationReblogType,
    DONMastodonNotificationFavoriteType,
    DONMastodonNotificationPollType,
    DONMastodonNotificationStatusType,
};

@interface DONMastodonNotification : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSString *identity;
@property (nonatomic, readonly) DONMastodonNotificationType type;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) DONMastodonAccount *account;
@property (nonatomic, readonly, nullable) DONStatus *status;

@end

NS_ASSUME_NONNULL_END
