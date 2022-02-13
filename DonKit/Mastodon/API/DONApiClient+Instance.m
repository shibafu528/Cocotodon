//
// Copyright (c) 2022 shibafu
//

#import "DONApiClient+Instance.h"

@implementation DONApiClient (Instance)

- (void)customEmojisWithCompletion:(DONApiCustomEmojisCompletionHandler)completion {
    [self.manager GET:@"/api/v1/custom_emojis"
           parameters:nil
              headers:self.defaultHeaders
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if (completion) {
            NSError *error;
            NSArray<DONEmoji *> *results = [MTLJSONAdapter modelsOfClass:DONEmoji.class fromJSONArray:responseObject error:&error];
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
