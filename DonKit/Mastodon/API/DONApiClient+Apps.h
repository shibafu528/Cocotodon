//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient.h"
#import "DONMastodonApp.h"
#import "DONMastodonAccessToken.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString* const DONDefaultRedirectTo;

typedef void (^DONApiCreateAppSuccessCallback)(NSURLSessionDataTask *__nonnull task, DONMastodonApp *__nonnull app);
typedef void (^DONApiObtainAccessTokenSuccessCallback)(NSURLSessionDataTask *__nonnull task, DONMastodonAccessToken *__nonnull accessToken);

@interface DONApiClient (Apps)

- (NSURLSessionDataTask*) createApp:(NSString*)clientName
                         redirectTo:(NSString*)redirectTo
                             scopes:(nullable NSString*)scopes
                            website:(nullable NSString*)website
                            success:(nullable DONApiCreateAppSuccessCallback)success
                            failure:(nullable DONApiFailureCallback)failure;

- (NSURL*) authorizeURL:(NSString*)clientId
             redirectTo:(NSString*)redirectTo
                 scopes:(nullable NSString*)scopes;

- (NSURLSessionDataTask*) obtainAccessToken:(NSString*)clientId
                               clientSecret:(NSString*)clientSecret
                                 redirectTo:(NSString*)redirectTo
                                     scopes:(nullable NSString*)scopes
                                       code:(NSString*)code
                                  grantType:(nullable NSString*)grantType
                                    success:(nullable DONApiObtainAccessTokenSuccessCallback)success
                                    failure:(nullable DONApiFailureCallback)failure;

@end

NS_ASSUME_NONNULL_END
