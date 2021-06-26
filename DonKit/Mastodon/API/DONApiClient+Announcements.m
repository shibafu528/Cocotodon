//
// Copyright (c) 2021 shibafu
//

#import "DONApiClient+Announcements.h"

@implementation DONApiClient (Announcements)

- (NSURLSessionDataTask *)announcementsWithSuccess:(DONApiGetAnnouncementsSuccessCallback)success
                                           failure:(DONApiFailureCallback)failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"with_dismissed"] = @YES;
    AFHTTPSessionManager *manager = self.manager;
    return [manager GET:@"/api/v1/announcements"
             parameters:parameters
                headers:self.defaultHeaders
               progress:nil
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSError *error;
            NSArray<DONMastodonAnnouncement*> *statuses = [MTLJSONAdapter modelsOfClass:DONMastodonAnnouncement.class fromJSONArray:responseObject error:&error];
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
