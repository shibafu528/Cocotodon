//
// Copyright (c) 2022 shibafu
//

#import "DONApiClient+Notifications.h"

@implementation DONApiClient (Notifications)

- (void)notificationsWithCompletion:(DONApiNotificationsCompletionHandler)completion {
    AFHTTPSessionManager *manager = self.manager;
    [manager GET:@"/api/v1/notifications"
      parameters:@{@"limit": @(100)}
         headers:self.defaultHeaders
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            NSError *error;
            NSArray<DONMastodonNotification*> *results = [MTLJSONAdapter modelsOfClass:DONMastodonNotification.class fromJSONArray:responseObject error:&error];
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
