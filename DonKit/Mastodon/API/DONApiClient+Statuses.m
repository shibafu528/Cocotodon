//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient+Statuses.h"

@implementation DONApiClient (Statuses)

- (NSURLSessionDataTask*)postStatus:(nonnull NSString *)status
                            replyTo:(nullable NSString *)inReplyToId
                           mediaIds:(nullable NSArray<NSNumber *> *)mediaIds
                          sensitive:(BOOL)sensitive
                        spoilerText:(nullable NSString *)spoilerText
                         visibility:(DONStatusVisibility)visibility
                            success:(nullable DONApiSuccessCallback)success
                            failure:(nullable DONApiFailureCallback)failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"status"] = status;
    if (inReplyToId) {
        params[@"in_reply_to_id"] = inReplyToId;
    }
    if (mediaIds) {
        params[@"media_ids"] = mediaIds;
    }
    params[@"sensitive"] = @(sensitive);
    if (spoilerText && spoilerText.length != 0) {
        params[@"spoiler_text"] = spoilerText;
    }
    params[@"visibility"] = NSStringFromStatusVisibility(visibility);
    
    AFHTTPSessionManager *manager = self.manager;
    return [manager POST:@"/api/v1/statuses"
              parameters:params
                 headers:self.defaultHeaders
                progress:nil
                 success:success
                 failure:failure];
}

- (nonnull NSURLSessionDataTask *)postMedia:(nonnull DONPicture *)file
                                description:(nullable NSString *)description
                                    success:(nullable DONApiPostMediaSuccessCallback)success
                                    failure:(nullable DONApiFailureCallback)failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (description) {
        params[@"description"] = description;
    }
    
    AFHTTPSessionManager *manager = self.manager;
    return [manager POST:@"/api/v1/media" parameters:params headers:self.defaultHeaders
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:file.data
                                    name:@"file"
                                fileName:[@"media" stringByAppendingString:file.extension]
                                mimeType:file.mimeType];
    }
                progress:nil
                 success:^(NSURLSessionDataTask* task, id responseObject) {
        success(task, responseObject[@"id"]);
    }
                 failure:failure];
}

- (NSURLSessionDataTask *)favoriteStatus:(NSString *)identity
                                 success:(DONApiSuccessCallback)success
                                 failure:(DONApiFailureCallback)failure {
    AFHTTPSessionManager *manager = self.manager;
    NSString *url = [NSString stringWithFormat:@"/api/v1/statuses/%@/favourite", identity];
    return [manager POST:url
              parameters:nil
                 headers:self.defaultHeaders
                progress:nil
                 success:success
                 failure:failure];
}

- (NSURLSessionDataTask *)reblogStatus:(NSString *)identity
                               success:(DONApiSuccessCallback)success
                               failure:(DONApiFailureCallback)failure {
    AFHTTPSessionManager *manager = self.manager;
    NSString *url = [NSString stringWithFormat:@"/api/v1/statuses/%@/reblog", identity];
    return [manager POST:url
              parameters:nil
                 headers:self.defaultHeaders
                progress:nil
                 success:success
                 failure:failure];
}

@end
