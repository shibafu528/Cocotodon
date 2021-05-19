//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient.h"
#import "../DONStatusVisibility.h"
#import "DONPicture.h"
#import "DONStatusContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiPostMediaSuccessCallback)(NSURLSessionDataTask *__nonnull task, NSNumber *__nonnull mediaId);
typedef void (^DONApiGetStatusSuccessCallback)(NSURLSessionDataTask *__nonnull task, DONStatus *__nonnull result);
typedef void (^DONApiGetStatusContextSuccessCallback)(NSURLSessionDataTask *__nonnull task, DONStatusContext *__nonnull result);

@interface DONApiClient (Statuses)

- (NSURLSessionDataTask*) postStatus:(NSString*)status
                             replyTo:(nullable NSString*)inReplyToId
                            mediaIds:(nullable NSArray<NSNumber*>*)mediaIds
                           sensitive:(BOOL)sensitive
                         spoilerText:(nullable NSString*)spoilerText
                          visibility:(DONStatusVisibility)visibility
                             success:(nullable DONApiSuccessCallback)success
                             failure:(nullable DONApiFailureCallback)failure;

- (NSURLSessionDataTask*) postMedia:(DONPicture*)file
                        description:(nullable NSString*)description
                            success:(nullable DONApiPostMediaSuccessCallback)success
                            failure:(nullable DONApiFailureCallback)failure;

- (NSURLSessionDataTask*) favoriteStatus:(NSString*)identity
                                 success:(nullable DONApiSuccessCallback)success
                                 failure:(nullable DONApiFailureCallback)failure;

- (NSURLSessionDataTask*) reblogStatus:(NSString*)identity
                               success:(nullable DONApiSuccessCallback)success
                               failure:(nullable DONApiFailureCallback)failure;

- (NSURLSessionDataTask*) getStatus:(NSString*)identity
                            success:(nullable DONApiGetStatusSuccessCallback)success
                            failure:(nullable DONApiFailureCallback)failure;

- (NSURLSessionDataTask*) getStatusContext:(NSString*)identity
                                   success:(nullable DONApiGetStatusContextSuccessCallback)success
                                   failure:(nullable DONApiFailureCallback)failure;

@end

NS_ASSUME_NONNULL_END
