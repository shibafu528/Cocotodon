//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient+Streaming.h"

@implementation DONApiClient (Streaming)

- (DONWebSocketStreaming *)streamingViaWebSocketListenTo:(NSString *)stream delegate:(id<DONStreamingEventDelegate>)delegate {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    // FIXME: 本来はGET /api/v1/instanceでエンドポイントのPrefixを得る必要がある
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:@"wss://%@/api/v1/streaming/?stream=%@&access_token=%@", self.host, stream, self.accessToken]];
    DONWebSocketStreaming *connection = [[DONWebSocketStreaming alloc] initWithConfiguration:config endpoint:endpoint delegate:delegate];
    [connection connect];
    return connection;
}

- (DONWebSocketStreaming *)userStreamingViaWebSocketWithDelegate:(id<DONStreamingEventDelegate>)delegate {
    return [self streamingViaWebSocketListenTo:@"user" delegate:delegate];
}

- (DONWebSocketStreaming *)publicStreamingViaWebSocketWithDelegate:(id<DONStreamingEventDelegate>)delegate {
    return [self streamingViaWebSocketListenTo:@"public" delegate:delegate];
}

- (DONWebSocketStreaming *)localPublicStreamingViaWebSocketWithDelegate:(id<DONStreamingEventDelegate>)delegate {
    return [self streamingViaWebSocketListenTo:@"public:local" delegate:delegate];
}

@end
