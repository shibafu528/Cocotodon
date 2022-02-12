//
// Copyright (c) 2020 shibafu
//

#import "DONApiClient+Streaming.h"

NSString* const DONStreamingChannelUser = @"user";
NSString* const DONStreamingChannelPublic = @"public";
NSString* const DONStreamingChannelPublicLocal = @"public:local";

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
    return [self streamingViaWebSocketListenTo:DONStreamingChannelUser delegate:delegate];
}

- (DONWebSocketStreaming *)publicStreamingViaWebSocketWithDelegate:(id<DONStreamingEventDelegate>)delegate {
    return [self streamingViaWebSocketListenTo:DONStreamingChannelPublic delegate:delegate];
}

- (DONWebSocketStreaming *)localPublicStreamingViaWebSocketWithDelegate:(id<DONStreamingEventDelegate>)delegate {
    return [self streamingViaWebSocketListenTo:DONStreamingChannelPublicLocal delegate:delegate];
}

- (DONWebSocketStreaming *)streamingViaWebsocketSubscribeChannels:(NSArray<NSString *> *)channels delegate:(id<DONStreamingEventDelegate>)delegate {
    NSAssert(channels.count > 0, @"channels not specified");

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    // FIXME: 本来はGET /api/v1/instanceでエンドポイントのPrefixを得る必要がある
    NSURL *endpoint = [NSURL URLWithString:[NSString stringWithFormat:@"wss://%@/api/v1/streaming/?access_token=%@", self.host, self.accessToken]];
    DONWebSocketStreaming *connection = [[DONWebSocketStreaming alloc] initWithConfiguration:config endpoint:endpoint delegate:delegate];
    connection.onConnected = ^(NSURLSessionWebSocketTask * _Nonnull task) {
        [channels enumerateObjectsUsingBlock:^(NSString * _Nonnull channel, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *json = [NSString stringWithFormat:@"{\"type\":\"subscribe\",\"stream\":\"%@\"}", channel];
            NSURLSessionWebSocketMessage *message = [[NSURLSessionWebSocketMessage alloc] initWithString:json];
            [task sendMessage:message completionHandler:^(NSError * _Nullable error) {
                // TODO: 失敗したらリトライしたほうがいいと思う
                if (error) {
                    NSLog(@"ws streamingViaWebsocketSubscribeChannels(%@) error: %@", channel, error);
                    return;
                }
                NSLog(@"ws streamingViaWebsocketSubscribeChannels(%@) success", channel);
            }];
        }];
    };
    [connection connect];
    return connection;
}

@end
