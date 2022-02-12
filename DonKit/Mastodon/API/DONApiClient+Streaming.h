//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient.h"
#import "DONWebSocketStreaming.h"
#import "DONStreamingEventDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// Home timeline and notifications
extern NSString* const DONStreamingChannelUser;
/// All public statuses
extern NSString* const DONStreamingChannelPublic;
/// All local statuses
extern NSString* const DONStreamingChannelPublicLocal;

@interface DONApiClient (Streaming)

- (DONWebSocketStreaming*) streamingViaWebSocketListenTo:(NSString*)stream delegate:(nullable id <DONStreamingEventDelegate>)delegate;

- (DONWebSocketStreaming*) userStreamingViaWebSocketWithDelegate:(nullable id <DONStreamingEventDelegate>)delegate;

- (DONWebSocketStreaming*) publicStreamingViaWebSocketWithDelegate:(nullable id <DONStreamingEventDelegate>)delegate;

- (DONWebSocketStreaming*) localPublicStreamingViaWebSocketWithDelegate:(nullable id <DONStreamingEventDelegate>)delegate;

/// requires Mastodon 3.3.0+
- (DONWebSocketStreaming*) streamingViaWebsocketSubscribeChannels:(NSArray<NSString*> *)channels delegate:(nullable id<DONStreamingEventDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
