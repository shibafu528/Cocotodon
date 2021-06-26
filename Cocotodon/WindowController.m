//
// Copyright (c) 2021 shibafu
//

#import "WindowController.h"

@interface WindowController ()

@property (nonatomic, weak) IBOutlet NSSegmentedControl *toolbarAnnouncementItem;

@property (nonatomic) NSArray<DONMastodonAnnouncement*> *announcements;

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // HACK: Catalinaでビルドする場合、xibで設定したtoolbarStyleは無視されるため、コード上で設定が必要
    if (@available(macOS 11.0, *)) {
        self.window.toolbarStyle = NSWindowToolbarStyleExpanded;
    }
    
    [App.client announcementsWithSuccess:^(NSURLSessionDataTask * _Nonnull task, NSArray<DONMastodonAnnouncement *> * _Nonnull results) {
        self.announcements = results;
    }
                                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        WriteAFNetworkingErrorToLog(error);
    }];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"announcements"]) {
        NSViewController *vc = segue.destinationController;
        vc.representedObject = self.announcements;
    }
}

@end
