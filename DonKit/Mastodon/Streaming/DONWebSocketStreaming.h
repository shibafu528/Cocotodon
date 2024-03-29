//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import "DONStreamingEventDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONWebSocketConnectedCallback)(NSURLSessionWebSocketTask *task);

@interface DONWebSocketStreaming : NSObject

@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, nullable, copy) DONWebSocketConnectedCallback onConnected;

- (instancetype) init __attribute__((unavailable("init is not available")));

- (instancetype) initWithConfiguration:(NSURLSessionConfiguration*)configuration endpoint:(NSURL*)endpoint delegate:(id <DONStreamingEventDelegate>)delegate;

- (void) connect;

- (void) disconnect;

@end

NS_ASSUME_NONNULL_END
