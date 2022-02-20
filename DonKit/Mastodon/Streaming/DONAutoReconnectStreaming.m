//
// Copyright (c) 2022 shibafu
//

#import "DONAutoReconnectStreaming.h"

@interface DONAutoReconnectStreaming ()

@property (nonatomic) NSInteger retryCount;

@end

@implementation DONAutoReconnectStreaming

- (instancetype)initWithDelegate:(id<DONAutoReconnectStreamingDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _retryCount = 0;
    }
    return self;
}

- (void)donStreamingDidConnect {
    if ([self.delegate respondsToSelector:@selector(donStreamingDidConnect)]) {
        [self.delegate donStreamingDidConnect];
    }
    self.retryCount = 0; // reset retry counter
}

- (void)donStreamingDidReceiveUpdate:(nonnull DONStatus *)status {
    [self.delegate donStreamingDidReceiveUpdate:status];
}

- (void)donStreamingDidReceiveDelete:(NSString *)statusID {
    [self.delegate donStreamingDidReceiveDelete:statusID];
}

- (void)donStreamingDidReceiveNotification:(nonnull DONMastodonNotification *)notification {
    [self.delegate donStreamingDidReceiveNotification:notification];
}

- (void)donStreamingDidFailWithError:(nonnull NSError *)error {
    [self.delegate donStreamingDidFailWithError:error];
}

- (void)donStreamingDidCompleteWithCloseCode:(NSURLSessionWebSocketCloseCode)closeCode error:(NSError *)error {
    [self.delegate donStreamingDidCompleteWithCloseCode:(NSURLSessionWebSocketCloseCode)closeCode error:error];
    if (closeCode == NSURLSessionWebSocketCloseCodeNormalClosure) {
        // cancel retry
        self.retryCount = 0;
    } else {
        // try reconnect
        int timeToSleep = MIN(2 << self.retryCount, 60);
        self.retryCount += 1;
        NSLog(@"streaming finish with error. try reconnect after %d sec.", timeToSleep);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeToSleep * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.retryCount == 0) {
                // cancelled
                return;
            }
            [self.delegate donStreamingShouldReconnect:self];
        });
    }
}

@end
