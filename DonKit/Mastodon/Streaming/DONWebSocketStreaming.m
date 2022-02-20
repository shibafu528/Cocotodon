//
// Copyright (c) 2020 shibafu
//

#import "DONWebSocketStreaming.h"

@interface DONWebSocketStreaming () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionWebSocketDelegate>

@property (nonatomic, readwrite) BOOL isConnected;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURL *endpoint;
@property (nonatomic) NSURLSessionWebSocketTask *task;
@property (nonatomic) NSTimer *pingTimer;
@property (nonatomic, weak) id <DONStreamingEventDelegate> delegate;
@property (nonatomic) BOOL sentConnectedEvent;

@end

@implementation DONWebSocketStreaming

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration endpoint:(NSURL *)endpoint delegate:(id<DONStreamingEventDelegate>)delegate {
    if (self = [super init]) {
        _isConnected = NO;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        _endpoint = endpoint;
        _task = nil;
        _pingTimer = nil;
        _delegate = delegate;
        _sentConnectedEvent = NO;
        _onConnected = nil;
    }
    return self;
}

- (void)dealloc {
    if (_task && _task.closeCode != NSURLSessionWebSocketCloseCodeInvalid) {
        [_task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeGoingAway reason:nil];
    }
}

- (void)connect {
    if (self.task && self.task.closeCode != NSURLSessionWebSocketCloseCodeInvalid) {
        [self disconnect];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.endpoint];
    // (for debug) ertona.net supports X-Disconnect-After https://ertona.net/about/more
    //[request setValue:@"5" forHTTPHeaderField:@"X-Disconnect-After"];
    self.task = [self.session webSocketTaskWithRequest:request];
    [self.task resume];
    [self continiousReceive];
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(ping:) userInfo:nil repeats:YES];
    self.isConnected = YES;
    
    if (self.onConnected) {
        self.onConnected(self.task);
    }
}

- (void)disconnect {
    if (!self.task) {
        return;
    }
    
    [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
}

- (void)ping:(NSTimer*)timer {
    [self.task sendPingWithPongReceiveHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"ws ping error: %@", error);
            return;
        }
        [self didConnect];
    }];
}

- (void)continiousReceive {
    [self.task receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error) {
        if (error) {
            [self.delegate donStreamingDidFailWithError:error];
            if (!self.isConnected || self.task.closeCode != NSURLSessionWebSocketCloseCodeInvalid) {
                // if connection was closed, break loop.
                return;
            }
        } else {
            [self didConnect];
            switch (message.type) {
                case NSURLSessionWebSocketMessageTypeData:
                    NSLog(@"Data received, ...why?: %@", message.data);
                    break;
                case NSURLSessionWebSocketMessageTypeString: {
                    NSError *err2 = nil;
                    NSDictionary<NSString*, id> *decode = [NSJSONSerialization JSONObjectWithData:[message.string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err2];
                    if (err2) {
                        [self.delegate donStreamingDidFailWithError:err2];
                        break;
                    }
                    
                    NSString *event = decode[@"event"];
                    NSString *payload = decode[@"payload"];
                    if ([event isEqualToString:@"update"]) {
                        [self didReceiveUpdate:payload];
                    } else if ([event isEqualToString:@"notification"]) {
                        [self didReveiceNotification:payload];
                    } else if ([event isEqualToString:@"delete"]) {
                        [self didReceiveDeletedID:payload];
                    } else if ([event isEqualToString:@"filters_changed"]) {
                        [self didReceiveFiltersChangedNotice:payload];
                    } else {
                        NSLog(@"Unknown event %@: %@", event, payload);
                    }
                    break;
                }
            }
        }
        [self continiousReceive];
    }];
}

- (void)didConnect {
    if (!self.sentConnectedEvent) {
        if ([self.delegate respondsToSelector:@selector(donStreamingDidConnect)]) {
            [self.delegate donStreamingDidConnect];
        }
        self.sentConnectedEvent = YES;
    }
}

- (void)didReceiveUpdate:(NSString*)payload {
    NSError *error = nil;
    id decodedPayload = [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        [self.delegate donStreamingDidFailWithError:error];
        return;
    }
    
    error = nil;
    DONStatus *status = [MTLJSONAdapter modelOfClass:DONStatus.class fromJSONDictionary:decodedPayload error:&error];
    if (error) {
        [self.delegate donStreamingDidFailWithError:error];
        return;
    }
    
    [self.delegate donStreamingDidReceiveUpdate:status];
}

- (void)didReveiceNotification:(NSString*)payload {
    NSError *error = nil;
    id decodedPayload = [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        [self.delegate donStreamingDidFailWithError:error];
        return;
    }
    
    error = nil;
    DONMastodonNotification *notify = [MTLJSONAdapter modelOfClass:DONMastodonNotification.class fromJSONDictionary:decodedPayload error:&error];
    if (error) {
        [self.delegate donStreamingDidFailWithError:error];
        return;
    }
    
    [self.delegate donStreamingDidReceiveNotification:notify];
}

- (void)didReceiveDeletedID:(NSString*)statusID {
    [self.delegate donStreamingDidReceiveDelete:statusID];
}

- (void)didReceiveFiltersChangedNotice:(NSString*)payload {
    // TODO: impl
    NSLog(@"ws filters_changed: %@", payload);
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"ws connection closed: (close code = %ld) %@", self.task.closeCode, error);
    self.isConnected = NO;
    self.sentConnectedEvent = NO;
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    if (error) {
        NSString *reason = [[NSString alloc] initWithData:self.task.closeReason encoding:NSUTF8StringEncoding];
        NSLog(@"ws close code & reason: %ld %@", self.task.closeCode, reason);
    }
    [self.delegate donStreamingDidCompleteWithCloseCode:self.task.closeCode error:error];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    NSLog(@"ws URLSession:didBecomeInvalidWithError:%@", error);
}

#pragma mark - NSURLSessionWebSocketDelegate

- (void)URLSession:(NSURLSession *)session webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode reason:(NSData *)reason {
    NSLog(@"ws URLSession:webSocketTask:didCloseWithCode:%ld:reason:", closeCode);
}

@end
