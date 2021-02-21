//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient+Timelines.h"

@implementation DONApiClient (Timelines)

- (NSURLSessionDataTask *)homeTimeline:(nullable DONApiHomeTimelineSuccessCallback)success
                               failure:(nullable DONApiFailureCallback)failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"limit"] = @(100);
    AFHTTPSessionManager *manager = self.manager;
    return [manager GET:@"/api/v1/timelines/home"
             parameters:parameters
                headers:self.defaultHeaders
               progress:nil
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSError *error;
            NSArray<DONStatus*> *statuses = [MTLJSONAdapter modelsOfClass:DONStatus.class fromJSONArray:responseObject error:&error];
            if (!error) {
                success(task, statuses);
            }
            if (failure) {
                failure(task, error);
            }
        }
    }
                failure:failure];
}

- (NSURLSessionDataTask *)publicTimelineOnlyLocal:(BOOL)onlyLocal
                                          success:(nullable DONApiHomeTimelineSuccessCallback)success
                                          failure:(nullable DONApiFailureCallback)failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"local"] = [NSNumber numberWithBool:onlyLocal];
    parameters[@"limit"] = @(100);
    AFHTTPSessionManager *manager = self.manager;
    return [manager GET:@"/api/v1/timelines/public"
             parameters:parameters
                headers:self.defaultHeaders
               progress:nil
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSError *error;
            NSArray<DONStatus*> *statuses = [MTLJSONAdapter modelsOfClass:DONStatus.class fromJSONArray:responseObject error:&error];
            if (!error) {
                success(task, statuses);
            }
            if (failure) {
                failure(task, error);
            }
        }
    }
                failure:failure];
}

@end
