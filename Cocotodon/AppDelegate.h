//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>
#import <mruby.h>
#import "MRBPin.h"
#import "DONApiClient.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, readonly) DONApiClient *client;
@property (nonatomic, readonly) DONMastodonAccount *currentAccount;

@property (nonatomic, readonly) mrb_state *mrb;
@property (nonatomic, readonly) MRBPin *world;

@end

#define App ((AppDelegate*) [NSApplication sharedApplication].delegate)
