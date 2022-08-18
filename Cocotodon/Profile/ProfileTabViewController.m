//
// Copyright (c) 2022 shibafu
//

#import "ProfileTabViewController.h"
#import "TimelineViewController.h"

@interface ProfileTabViewController ()

@end

@implementation ProfileTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    DONMastodonAccount *account = (DONMastodonAccount *) representedObject;
    NSInteger currentTabIndex = self.selectedTabViewItemIndex;
    
    // remove tabs
    [self.tabViewItems enumerateObjectsWithOptions:NSEnumerationReverse
                                        usingBlock:^(__kindof NSTabViewItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTabViewItem:item];
    }];
    
    // create tabs
    TimelineViewController *timelineVC = [[TimelineViewController alloc] init];
    timelineVC.timelineReloader = ^AnyPromise *(TimelineViewController *vc) {
        return DONPromisify(^(DONPromisifyCompletionHandler _Nonnull completionHandler) {
            [App.client statusesByAccount:account.identity withCompletion:completionHandler];
        });
    };
    [self addTabViewItem:[NSTabViewItem tabViewItemWithViewController:timelineVC label:@"投稿"]];
    
    self.selectedTabViewItemIndex = currentTabIndex;
}

@end
