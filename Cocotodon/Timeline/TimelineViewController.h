//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>
#import "DONWebSocketStreaming.h"

@interface TimelineViewController : NSViewController

@property (nonatomic, copy) AnyPromise* (^timelineReloader)(TimelineViewController *vc);
@property (nonatomic, copy) DONWebSocketStreaming* (^streamingInitiator)(id<DONStreamingEventDelegate> vc);
@property (nonatomic) BOOL dismissNotification;

- (IBAction)reply:(id)sender;
- (IBAction)favorite:(id)sender;
- (IBAction)boost:(id)sender;
- (IBAction)favoriteAndBoost:(id)sender;
- (IBAction)copyURL:(id)sender;
- (IBAction)openInBrowser:(id)sender;
- (IBAction)report:(id)sender;

@end

