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

- (IBAction)reply:(id)sender;
- (IBAction)favorite:(id)sender;
- (IBAction)boost:(id)sender;
- (IBAction)favoriteAndBoost:(id)sender;
- (IBAction)copyURL:(id)sender;
- (IBAction)openInBrowser:(id)sender;
- (IBAction)report:(id)sender;

@end

