//
// Copyright (c) 2022 shibafu
//

#import "DONApiClient.h"
#import "DONMastodonSearchResults.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiSearchCompletionHandler)(NSURLSessionDataTask *_Nonnull task, DONMastodonSearchResults *_Nullable results, NSError *_Nullable error);

@interface DONApiClient (Search)

- (void)searchWithQuery:(NSString *)q requiresResolve:(BOOL)resolve completion:(nullable DONApiSearchCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
