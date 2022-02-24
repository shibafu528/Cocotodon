//
// Copyright (c) 2022 shibafu
//

#import "DONApiClient.h"
#import "DONMastodonNotification.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiNotificationsCompletionHandler)(NSURLSessionDataTask *_Nonnull task, NSArray<DONMastodonNotification *> *_Nullable results, NSError *_Nullable error);

@interface DONApiClient (Notifications)

- (void)notificationsWithCompletion:(nullable DONApiNotificationsCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
