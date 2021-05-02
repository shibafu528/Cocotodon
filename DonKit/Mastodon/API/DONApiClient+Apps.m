//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient+Apps.h"

NSString* const DONDefaultRedirectTo = @"urn:ietf:wg:oauth:2.0:oob";

@implementation DONApiClient (Apps)

- (nonnull NSURLSessionDataTask *)createApp:(nonnull NSString *)clientName
                                 redirectTo:(nonnull NSString *)redirectTo
                                     scopes:(nullable NSString *)scopes
                                    website:(nullable NSString *)website
                                    success:(nullable DONApiCreateAppSuccessCallback)success
                                    failure:(nullable DONApiFailureCallback)failure{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"client_name"] = clientName;
    params[@"redirect_uris"] = redirectTo;
    if (scopes) {
        params[@"scopes"] = scopes;
    }
    if (website) {
        params[@"website"] = website;
    }
    
    AFHTTPSessionManager *manager = self.manager;
    return [manager POST:@"/api/v1/apps" parameters:params headers:nil progress:nil
                 success:^(NSURLSessionDataTask *task, id response) {
        if (success) {
            success(task, [MTLJSONAdapter modelOfClass:DONMastodonApp.class fromJSONDictionary:response error:nil]);
        }
    }
                 failure:failure];
}

- (nonnull NSURL *)authorizeURL:(nonnull NSString *)clientId
                        redirectTo:(nonnull NSString *)redirectTo
                            scopes:(nullable NSString *)scopes {
    NSURLComponents *url = [[NSURLComponents alloc] init];
    url.scheme = @"https";
    url.host = self.host;
    url.path = @"/oauth/authorize";
    
    NSArray<NSURLQueryItem*> *params = @[
        [NSURLQueryItem queryItemWithName:@"client_id" value:clientId],
        [NSURLQueryItem queryItemWithName:@"redirect_uri" value:redirectTo],
        [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
    ];
    if (scopes) {
        params = [params arrayByAddingObject:[NSURLQueryItem queryItemWithName:@"scope" value:scopes]];
    }
    url.queryItems = params;

    return [url URL];
}

- (nonnull NSURLSessionDataTask *)obtainAccessToken:(nonnull NSString *)clientId
                                       clientSecret:(nonnull NSString *)clientSecret
                                         redirectTo:(nonnull NSString *)redirectTo
                                             scopes:(nullable NSString *)scopes
                                               code:(nonnull NSString *)code
                                          grantType:(nullable NSString *)grantType
                                            success:(nullable DONApiObtainAccessTokenSuccessCallback)success
                                            failure:(nullable DONApiFailureCallback)failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"client_id"] = clientId;
    params[@"client_secret"] = clientSecret;
    params[@"redirect_uri"] = redirectTo;
    if (scopes) {
        params[@"scope"] = scopes;
    }
    params[@"code"] = code;
    params[@"grant_type"] = grantType ?: @"authorization_code";
    
    AFHTTPSessionManager *manager = self.manager;
    return [manager POST:@"/oauth/token" parameters:params headers:nil progress:nil
                 success:^(NSURLSessionDataTask *task, id response) {
        if (success) {
            success(task, [MTLJSONAdapter modelOfClass:DONMastodonAccessToken.class fromJSONDictionary:response error:nil]);
        }
    }
                 failure:failure];
}

@end
