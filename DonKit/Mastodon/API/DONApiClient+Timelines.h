//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient.h"
#import "DONStatus.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiHomeTimelineSuccessCallback)(NSURLSessionDataTask *__nonnull task, NSArray<DONStatus*> *__nonnull results);

@interface DONApiClient (Timelines)

- (NSURLSessionDataTask*) homeTimeline:(nullable DONApiHomeTimelineSuccessCallback)success
                               failure:(nullable DONApiFailureCallback)failure;

- (NSURLSessionDataTask*) publicTimelineOnlyLocal:(BOOL)onlyLocal
                                          success:(nullable DONApiHomeTimelineSuccessCallback)success
                                          failure:(nullable DONApiFailureCallback)failure;

@end

NS_ASSUME_NONNULL_END
