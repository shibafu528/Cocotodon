//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>
#import "DONWebSocketStreaming.h"

@interface TimelineViewController : NSViewController

@property (nonatomic, copy) AnyPromise* (^timelineReloader)(TimelineViewController *vc);
@property (nonatomic, copy) void (^subscribeStream)(id<DONStreamingEventDelegate> vc);
@property (nonatomic, copy) void (^unsubscribeStream)(id<DONStreamingEventDelegate> vc);
@property (nonatomic, copy) BOOL (^isConnectedStream)(id<DONStreamingEventDelegate> vc);
@property (nonatomic) BOOL dismissNotification DEPRECATED_ATTRIBUTE; // TODO: 通知の実装を別の場所に移動したら消す

- (IBAction)reply:(id)sender;
- (IBAction)favorite:(id)sender;
- (IBAction)boost:(id)sender;
- (IBAction)favoriteAndBoost:(id)sender;
- (IBAction)copyURL:(id)sender;
- (IBAction)openInBrowser:(id)sender;
- (IBAction)report:(id)sender;

@end

