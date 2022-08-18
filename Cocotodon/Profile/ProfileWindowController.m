//
// Copyright (c) 2022 shibafu
//

#import "ProfileWindowController.h"

@interface ProfileWindowController () <NSWindowDelegate>

@end

@implementation ProfileWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)setAccount:(DONMastodonAccount *)account {
    _account = account;
    self.window.title = [NSString stringWithFormat:@"@%@", account.fullAcct];
    [self.splitViewController.childViewControllers enumerateObjectsUsingBlock:^(__kindof NSViewController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        vc.representedObject = account;
    }];
}

- (IBAction)changeTab:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    NSTabViewController *vc = (NSTabViewController *) [self childViewControllerOfClass:NSTabViewController.class];
    vc.selectedTabViewItemIndex = control.selectedSegment;
}

- (NSSplitViewController *)splitViewController {
    return (NSSplitViewController *) self.contentViewController;
}

- (NSViewController *)childViewControllerOfClass:(Class)aClass {
    __block NSViewController *found = nil;
    [self.splitViewController.childViewControllers enumerateObjectsUsingBlock:^(__kindof NSViewController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([vc isKindOfClass:aClass]) {
            found = vc;
            *stop = YES;
        }
    }];
    return found;
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    [App releaseProfileWindowController:self];
}

@end
