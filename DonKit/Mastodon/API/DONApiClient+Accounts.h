//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient.h"
#import "DONMastodonAccount.h"
#import "DONStatus.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiVerifyCredentialsSuccessCallback)(NSURLSessionDataTask *__nonnull task, DONMastodonAccount *__nonnull account);
typedef void (^DONApiFavoritedStatusesCompletionHandler)(NSURLSessionDataTask *_Nonnull task, NSArray<DONStatus *> *_Nullable results, NSError *_Nullable error);
typedef void (^DONApiBookmarkedStatusesCompletionHandler)(NSURLSessionDataTask *_Nonnull task, NSArray<DONStatus *> *_Nullable results, NSError *_Nullable error);

@interface DONApiClient (Accounts)

- (NSURLSessionDataTask*)verifyCredentials:(nullable DONApiVerifyCredentialsSuccessCallback)success
                                   failure:(nullable DONApiFailureCallback)failure;

- (NSURLSessionDataTask*)reportAccount:(NSString*)accountId
                             relatesTo:(nullable NSArray<NSString*>*)statusIds
                               comment:(nullable NSString*)comment
                       forwardToRemote:(BOOL)forward
                               success:(nullable DONApiSuccessCallback)success
                               failure:(nullable DONApiFailureCallback)failure;

- (void)favoritedStatusesWithCompletion:(DONApiFavoritedStatusesCompletionHandler)completion;

- (void)bookmarkedStatusesWithCompletion:(DONApiFavoritedStatusesCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
