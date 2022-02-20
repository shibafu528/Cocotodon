//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DONAutoReconnectStreaming;

@protocol DONAutoReconnectStreamingDelegate <DONStreamingEventDelegate>

- (void)donStreamingShouldReconnect:(DONAutoReconnectStreaming *)autoReconnect;

@end

NS_ASSUME_NONNULL_END
