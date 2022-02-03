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
                            success:(nullable DONApiPostStatusSuccessCallback)success
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
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSError *error;
            DONStatus *status = [MTLJSONAdapter modelOfClass:DONStatus.class fromJSONDictionary:responseObject error:&error];
            if (!error) {
                success(task, status);
            }
            if (failure) {
                failure(task, error);
            }
        }
    }
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

- (NSURLSessionDataTask *)getStatus:(NSString *)identity
                            success:(DONApiGetStatusSuccessCallback)success
                            failure:(DONApiFailureCallback)failure {
    AFHTTPSessionManager *manager = self.manager;
    NSString *url = [NSString stringWithFormat:@"/api/v1/statuses/%@", identity];
    return [manager GET:url
             parameters:nil
                headers:self.defaultHeaders
               progress:nil
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSError *error;
            DONStatus *status = [MTLJSONAdapter modelOfClass:DONStatus.class fromJSONDictionary:responseObject error:&error];
            if (!error) {
                success(task, status);
            }
            if (failure) {
                failure(task, error);
            }
        }
    }
                failure:failure];
}

- (NSURLSessionDataTask *)getStatusContext:(NSString *)identity
                                   success:(DONApiGetStatusContextSuccessCallback)success
                                   failure:(DONApiFailureCallback)failure {
    AFHTTPSessionManager *manager = self.manager;
    NSString *url = [NSString stringWithFormat:@"/api/v1/statuses/%@/context", identity];
    return [manager GET:url
             parameters:nil
                headers:self.defaultHeaders
               progress:nil
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSError *error;
            DONStatusContext *context = [MTLJSONAdapter modelOfClass:DONStatusContext.class fromJSONDictionary:responseObject error:&error];
            if (!error) {
                success(task, context);
            }
            if (failure) {
                failure(task, error);
            }
        }
    }
                failure:failure];
}

- (NSURLSessionDataTask *)deleteStatus:(NSString *)identifier
                               success:(DONApiGetStatusSuccessCallback)success
                               failure:(DONApiFailureCallback)failure {
    AFHTTPSessionManager *manager = self.manager;
    NSString *url = [NSString stringWithFormat:@"/api/v1/statuses/%@", identifier];
    return [manager DELETE:url
                parameters:nil
                   headers:self.defaultHeaders
                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSError *error;
            DONStatus *status = [MTLJSONAdapter modelOfClass:DONStatus.class fromJSONDictionary:responseObject error:&error];
            if (!error) {
                success(task, status);
                return;
            }
            if (failure) {
                failure(task, error);
            }
        }
    }
                   failure:failure];
}

- (NSURLSessionDataTask *)bookmarkStatus:(NSString *)identifier
                   withCompletionHandler:(DONApiBookmarkStatusCompletionHandler)completionHandler {
    AFHTTPSessionManager *manager = self.manager;
    NSString *url = [NSString stringWithFormat:@"/api/v1/statuses/%@/bookmark", identifier];
    return [manager POST:url
              parameters:nil
                 headers:self.defaultHeaders
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completionHandler) {
            NSError *error;
            DONStatus *status = [MTLJSONAdapter modelOfClass:DONStatus.class fromJSONDictionary:responseObject error:&error];
            completionHandler(task, status, error);
        }
    }
                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completionHandler) {
            completionHandler(task, nil, error);
        }
    }];
}

@end
