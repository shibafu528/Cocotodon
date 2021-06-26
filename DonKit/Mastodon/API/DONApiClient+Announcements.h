//
// Copyright (c) 2021 shibafu
//

#import "DONApiClient.h"
#import "DONMastodonAnnouncement.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiGetAnnouncementsSuccessCallback)(NSURLSessionDataTask *__nonnull task, NSArray<DONMastodonAnnouncement*> *__nonnull results);

@interface DONApiClient (Announcements)

- (NSURLSessionDataTask*) announcementsWithSuccess:(nullable DONApiGetAnnouncementsSuccessCallback)success
                                           failure:(nullable DONApiFailureCallback)failure;

@end

NS_ASSUME_NONNULL_END
