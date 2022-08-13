//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>
#import <mruby.h>
#import "MRBPin.h"
#import "DONApiClient.h"
#import "StreamingManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, readonly) DONApiClient *client;
@property (nonatomic, readonly) DONMastodonAccount *currentAccount;
@property (nonatomic, readonly) StreamingManager *streamingManager;

@property (nonatomic, readonly) mrb_state *mrb;
@property (nonatomic, readonly) MRBPin *world;

- (NSWindowController *)profileWindowControllerForAccount:(DONMastodonAccount *)account;
- (void)releaseProfileWindowController:(NSWindowController *)controller;

@end

#define App ((AppDelegate*) [NSApplication sharedApplication].delegate)
