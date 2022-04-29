//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>
#import "DONStreamingEventDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface StreamingManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithClient:(DONApiClient *)client NS_DESIGNATED_INITIALIZER;

- (BOOL)isConnectedChannel:(NSString *)channel;

- (void)subscribeChannel:(NSString *)channel delegate:(id<DONStreamingEventDelegate>)delegate;

- (void)unsubscribeChannel:(NSString *)channel delegate:(id<DONStreamingEventDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
