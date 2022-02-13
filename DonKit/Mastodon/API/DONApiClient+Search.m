//
// Copyright (c) 2022 shibafu
//

#import "DONApiClient+Search.h"

@implementation DONApiClient (Search)

- (void)searchWithQuery:(NSString *)q requiresResolve:(BOOL)resolve completion:(DONApiSearchCompletionHandler)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"q"] = q;
    params[@"resolve"] = @(resolve);
    
    AFHTTPSessionManager *manager = self.manager;
    [manager GET:@"/api/v2/search"
      parameters:params
         headers:self.defaultHeaders
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            NSError *error;
            DONMastodonSearchResults *results = [MTLJSONAdapter modelOfClass:DONMastodonSearchResults.class fromJSONDictionary:responseObject error:&error];
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
