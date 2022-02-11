//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>
#import "DONAutoReconnectStreamingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface DONAutoReconnectStreaming : NSObject <DONStreamingEventDelegate>

@property (nonatomic, weak) id<DONAutoReconnectStreamingDelegate> delegate;

- (instancetype)init __attribute__((unavailable("init is not available")));

- (instancetype)initWithDelegate:(id<DONAutoReconnectStreamingDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
