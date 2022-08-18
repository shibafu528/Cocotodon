//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient+Accounts.h"

@implementation DONApiClient (Accounts)

- (nonnull NSURLSessionDataTask *)verifyCredentials:(nullable DONApiVerifyCredentialsSuccessCallback)success
                                            failure:(nullable DONApiFailureCallback)failure {
    return [self.manager GET:@"/api/v1/accounts/verify_credentials"
                  parameters:nil
                     headers:self.defaultHeaders
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if (success) {
            success(task, [MTLJSONAdapter modelOfClass:DONMastodonAccount.class fromJSONDictionary:responseObject error:nil]);
        }
    }
                     failure:failure];
}

- (NSURLSessionDataTask *)reportAccount:(NSString *)accountId
                              relatesTo:(nullable NSArray<NSString *> *)statusIds
                                comment:(nullable NSString *)comment
                        forwardToRemote:(BOOL)forward
                                success:(nullable DONApiSuccessCallback)success
                                failure:(nullable DONApiFailureCallback)failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"account_id"] = accountId;
    if (statusIds) {
        params[@"status_ids"] = statusIds;
    }
    if (comment) {
        params[@"comment"] = comment;
    }
    if (forward) {
        params[@"forward"] = @YES;
    }
    
    return [self.manager POST:@"/api/v1/reports"
                   parameters:params
                      headers:self.defaultHeaders
                     progress:nil
                      success:success
                      failure:failure];
}

- (void)favoritedStatusesWithCompletion:(DONApiFavoritedStatusesCompletionHandler)completion {
    AFHTTPSessionManager *manager = self.manager;
    [manager GET:@"/api/v1/favourites"
      parameters:@{@"limit": @(100)}
         headers:self.defaultHeaders
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            NSError *error;
            NSArray<DONStatus*> *results = [MTLJSONAdapter modelsOfClass:DONStatus.class fromJSONArray:responseObject error:&error];
            completion(task, results, error);
        }
    }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(task, nil, error);
        }
    }];
}

- (void)bookmarkedStatusesWithCompletion:(DONApiFavoritedStatusesCompletionHandler)completion {
    AFHTTPSessionManager *manager = self.manager;
    [manager GET:@"/api/v1/bookmarks"
      parameters:@{@"limit": @(100)}
         headers:self.defaultHeaders
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            NSError *error;
            NSArray<DONStatus*> *results = [MTLJSONAdapter modelsOfClass:DONStatus.class fromJSONArray:responseObject error:&error];
            completion(task, results, error);
        }
    }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(task, nil, error);
        }
    }];
}

- (void)statusesByAccount:(NSString *)accountId withCompletion:(DONApiStatusesCompletionHandler)completion {
    AFHTTPSessionManager *manager = self.manager;
    [manager GET:[NSString stringWithFormat:@"/api/v1/accounts/%@/statuses", accountId]
      parameters:@{@"limit": @(100)}
         headers:self.defaultHeaders
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            NSError *error;
            NSArray<DONStatus*> *results = [MTLJSONAdapter modelsOfClass:DONStatus.class fromJSONArray:responseObject error:&error];
            completion(task, results, error);
        }
    }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(task, nil, error);
        }
    }];
}

@end
