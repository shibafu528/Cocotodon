//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient.h"
#import "DONMastodonAccount.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiVerifyCredentialsSuccessCallback)(NSURLSessionDataTask *__nonnull task, DONMastodonAccount *__nonnull account);

@interface DONApiClient (Accounts)

- (NSURLSessionDataTask*)verifyCredentials:(nullable DONApiVerifyCredentialsSuccessCallback)success
                                   failure:(nullable DONApiFailureCallback)failure;

- (NSURLSessionDataTask*)reportAccount:(NSString*)accountId
                             relatesTo:(nullable NSArray<NSString*>*)statusIds
                               comment:(nullable NSString*)comment
                       forwardToRemote:(BOOL)forward
                               success:(nullable DONApiSuccessCallback)success
                               failure:(nullable DONApiFailureCallback)failure;

@end

NS_ASSUME_NONNULL_END
