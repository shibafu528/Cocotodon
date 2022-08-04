//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "DONMastodonAccount.h"
#import "DONStatus.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DONMastodonNotificationType) {
    DONMastodonNotificationUnknown,
    DONMastodonNotificationFollowType,
    DONMastodonNotificationFollowRequestType,
    DONMastodonNotificationMentionType,
    DONMastodonNotificationReblogType,
    DONMastodonNotificationFavoriteType,
    DONMastodonNotificationPollType,
    DONMastodonNotificationStatusType,
    DONMastodonNotificationUpdateType
};

@interface DONMastodonNotification : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSString *identity;
@property (nonatomic, readonly) NSString *rawType;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) DONMastodonAccount *account;
@property (nonatomic, readonly, nullable) DONStatus *status;

- (DONMastodonNotificationType)type;

@end

NS_ASSUME_NONNULL_END
