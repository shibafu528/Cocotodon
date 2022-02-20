//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import "DONMastodonNotification.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DONStreamingEventDelegate <NSObject>

- (void)donStreamingDidReceiveUpdate:(DONStatus*)status;

- (void)donStreamingDidReceiveDelete:(NSString*)statusID;

- (void)donStreamingDidReceiveNotification:(DONMastodonNotification*)notification;

- (void)donStreamingDidFailWithError:(NSError*)error;

- (void)donStreamingDidCompleteWithCloseCode:(NSURLSessionWebSocketCloseCode)closeCode error:(NSError * _Nullable)error;

@optional

- (void)donStreamingDidConnect;

@end

NS_ASSUME_NONNULL_END
