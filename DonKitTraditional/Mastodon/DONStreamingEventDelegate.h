//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DONStreamingEventDelegate <NSObject>

- (void)donStreamingDidReceiveUpdate:(DONStatus*)status;

- (void)donStreamingDidFailWithError:(NSError*)error;

- (void)donStreamingDidCompleteWithError:(NSError*)error;

@end

NS_ASSUME_NONNULL_END
