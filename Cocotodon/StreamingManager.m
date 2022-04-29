//
// Copyright (c) 2022 shibafu
//

#import "StreamingManager.h"
#import "DONAutoReconnectStreaming.h"

@interface StreamingSubscriptionSet : NSObject <DONAutoReconnectStreamingDelegate>

@property (nonatomic) DONWebSocketStreaming *stream;
@property (nonatomic) NSString *channel;
@property (nonatomic) DONAutoReconnectStreaming *autoReconnect;
@property (nonatomic) NSHashTable<id<DONStreamingEventDelegate>> *subscriptions;

- (NSUInteger)count;

- (void)subscribeWithDelegate:(nonnull id<DONStreamingEventDelegate>)delegate;

- (BOOL)unsubscribeWithDelegate:(nonnull id<DONStreamingEventDelegate>)delegate;

@end

@implementation StreamingSubscriptionSet

- (instancetype)init {
    if (self = [super init]) {
        _subscriptions = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return self;
}

- (NSUInteger)count {
    return self.subscriptions.count;
}

- (void)subscribeWithDelegate:(nonnull id<DONStreamingEventDelegate>)delegate {
    [self.subscriptions addObject:delegate];
}

- (BOOL)unsubscribeWithDelegate:(nonnull id<DONStreamingEventDelegate>)delegate {
    if ([self.subscriptions containsObject:delegate]) {
        [self.subscriptions removeObject:delegate];
        return YES;
    } else {
        return NO;
    }
}

- (void)donStreamingDidReceiveUpdate:(nonnull DONStatus *)status {
    [self.subscriptions.allObjects enumerateObjectsUsingBlock:^(id<DONStreamingEventDelegate> _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate donStreamingDidReceiveUpdate:status];
    }];
}

- (void)donStreamingDidReceiveDelete:(nonnull NSString *)statusID {
    NSLog(@"[StreamingSubscription] '%@': delete %@", self.channel, statusID);
    [self.subscriptions.allObjects enumerateObjectsUsingBlock:^(id<DONStreamingEventDelegate> _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate donStreamingDidReceiveDelete:statusID];
    }];
}

- (void)donStreamingDidReceiveStatusUpdate:(nonnull DONStatus *)status {
    NSLog(@"[StreamingSubscription] '%@': status update %@", self.channel, status.identity);
    [self.subscriptions.allObjects enumerateObjectsUsingBlock:^(id<DONStreamingEventDelegate> _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate donStreamingDidReceiveStatusUpdate:status];
    }];
}

- (void)donStreamingDidCompleteWithCloseCode:(NSURLSessionWebSocketCloseCode)closeCode error:(NSError * _Nullable)error {
    NSLog(@"[StreamingSubscription] '%@': close %ld", self.channel, closeCode);
    [self.subscriptions.allObjects enumerateObjectsUsingBlock:^(id<DONStreamingEventDelegate> _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate donStreamingDidCompleteWithCloseCode:closeCode error:error];
    }];
}

- (void)donStreamingDidFailWithError:(nonnull NSError *)error {
    NSLog(@"[StreamingSubscription] '%@': error %@", self.channel, error);
    [self.subscriptions.allObjects enumerateObjectsUsingBlock:^(id<DONStreamingEventDelegate> _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate donStreamingDidFailWithError:error];
    }];
}

- (void)donStreamingDidReceiveNotification:(nonnull DONMastodonNotification *)notification {
    NSLog(@"[StreamingSubscription] '%@': notification", self.channel);
    [self.subscriptions.allObjects enumerateObjectsUsingBlock:^(id<DONStreamingEventDelegate> _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate donStreamingDidReceiveNotification:notification];
    }];
}

- (void)donStreamingShouldReconnect:(DONAutoReconnectStreaming *)autoReconnect {
    NSLog(@"[StreamingSubscription] '%@': reconnect", self.channel);
    [self.stream connect];
}

@end

#pragma mark -

@interface StreamingManager ()

@property (nonatomic, readonly) DONApiClient *client;
@property (nonatomic) NSMutableDictionary<NSString *, StreamingSubscriptionSet *> *subscriptions;

@end

@implementation StreamingManager

- (instancetype)initWithClient:(DONApiClient *)client {
    if (self = [super init]) {
        _client = client;
        _subscriptions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isConnectedChannel:(NSString *)channel {
    __auto_type subs = self.subscriptions[channel];
    if (!subs) {
        return NO;
    }
    
    return subs.stream.isConnected;
}

- (void)subscribeChannel:(NSString *)channel delegate:(id<DONStreamingEventDelegate>)delegate {
    // FIXME: 可能ならMastodon 3.3.0+のmuxを使いたい
    __auto_type subs = self.subscriptions[channel];
    if (!subs) {
        subs = [[StreamingSubscriptionSet alloc] init];
        self.subscriptions[channel] = subs;
        
        DONAutoReconnectStreaming *autoReconnect = [[DONAutoReconnectStreaming alloc] initWithDelegate:subs];
        DONWebSocketStreaming *stream = [self.client streamingViaWebSocketListenTo:channel delegate:autoReconnect];
        subs.stream = stream;
        subs.channel = channel;
        subs.autoReconnect = autoReconnect;
    }
    
    [subs subscribeWithDelegate:delegate];
    
    NSLog(@"[StreamingManager] '%@': subscribed from %@. %lu subscription(s) now.", channel, delegate, subs.count);
}

- (void)unsubscribeChannel:(NSString *)channel delegate:(id<DONStreamingEventDelegate>)delegate {
    __auto_type subs = self.subscriptions[channel];
    if (!subs) {
        return;
    }
    
    if ([subs unsubscribeWithDelegate:delegate] && subs.count == 0) {
        [subs.stream disconnect];
        [self.subscriptions removeObjectForKey:channel];
    }
    
    NSLog(@"[StreamingManager] '%@': unsubscribed from %@, %lu subscription(s) now.", channel, delegate, subs.count);
}

@end
