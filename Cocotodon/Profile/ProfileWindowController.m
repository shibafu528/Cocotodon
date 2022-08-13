//
// Copyright (c) 2022 shibafu
//

#import "ProfileWindowController.h"

@interface ProfileWindowController () <NSWindowDelegate>

@end

@implementation ProfileWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)changeTab:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    NSTabViewController *vc = (NSTabViewController *) [self childViewControllerOfClass:NSTabViewController.class];
    vc.selectedTabViewItemIndex = control.selectedSegment;
}

- (NSViewController *)childViewControllerOfClass:(Class)aClass {
    NSSplitViewController *splitVC = (NSSplitViewController *) self.contentViewController;
    __block NSViewController *found = nil;
    [splitVC.childViewControllers enumerateObjectsUsingBlock:^(__kindof NSViewController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
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
