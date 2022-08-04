//
// Copyright (c) 2022 shibafu
//

#import "NotificationViewController.h"
#import "NotificationCellView.h"
#import "DONAutoReconnectStreaming.h"
#import "ThreadWindow.h"
#import "MainWindowController.h"

@interface NotificationViewController () <NSTableViewDelegate, NSTableViewDataSource, DONStreamingEventDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic) BOOL subscribedStream;

@property (nonatomic) NSArray<DONMastodonNotification *> *notifications;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notifications = @[];
    
    [App.streamingManager subscribeChannel:DONStreamingChannelUser delegate:self];
    self.subscribedStream = YES;
    
    [self reload:nil];
}

/// イベント発生時に操作対象となっている行を判定し、行番号を返す
- (NSInteger)targetRowInAction:(id)sender {
    if ([sender isKindOfClass:NSMenuItem.class] && [((NSMenuItem*) sender).menu.identifier isEqualToString:@"context"]) {
        return self.tableView.clickedRow;
    } else {
        return self.tableView.selectedRow;
    }
}

#pragma mark - DONAutoReconnectStreamingDelegate

- (void)donStreamingDidReceiveUpdate:(DONStatus *)status {}

- (void)donStreamingDidReceiveDelete:(NSString *)statusID {}

- (void)donStreamingDidReceiveNotification:(DONMastodonNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.notifications = [@[notification] arrayByAddingObjectsFromArray:self.notifications];
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideDown];
    });
}

- (void)donStreamingDidReceiveStatusUpdate:(DONStatus *)status {}

- (void)donStreamingDidFailWithError:(NSError *)error {
    NSLog(@"ws error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateToolbarStreamingItem];
    });
}

- (void)donStreamingDidCompleteWithCloseCode:(NSURLSessionWebSocketCloseCode)closeCode error:(NSError *)error {
    NSLog(@"ws close: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateToolbarStreamingItem];
    });
}

- (void)updateToolbarStreamingItem {
    NSString *sym = self.subscribedStream && [App.streamingManager isConnectedChannel:DONStreamingChannelUser] ? @"bolt.fill" : @"bolt.slash";
    MainWindowController *wc = (MainWindowController*) self.view.window.windowController;
    [wc.toolbarStreamingItem setImage:[NSImage imageWithSystemSymbolName:sym accessibilityDescription:nil] forSegment:0];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NotificationCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    DONMastodonNotification *notification = self.notifications[row];
    
    NSSize size = view.avatarView.fittingSize;
    NSSize fittingSize = NSMakeSize(size.width, size.width);
    view.avatarView.primaryImage = [[[NSImage alloc] initWithContentsOfURL:notification.account.avatar] resizeToScreenSize:fittingSize];
    
    switch (notification.type) {
        case DONMastodonNotificationFollowType:
            view.summaryField.stringValue = [NSString stringWithFormat:@"@%@ さんにフォローされました", notification.account.fullAcct];
            break;
        case DONMastodonNotificationFollowRequestType:
            view.summaryField.stringValue = [NSString stringWithFormat:@"@%@ さんからフォローリクエストが届いています", notification.account.fullAcct];
            break;
        case DONMastodonNotificationMentionType:
            view.summaryField.stringValue = [NSString stringWithFormat:@"💬 @%@ さんからの返信", notification.account.fullAcct];
            view.detailField.stringValue = notification.status.expandContent;
            view.avatarView.statusVisibility = notification.status.visibility;
            break;
        case DONMastodonNotificationReblogType:
            view.summaryField.stringValue = [NSString stringWithFormat:@"🔁 @%@ さんにブーストされました", notification.account.fullAcct];
            view.detailField.stringValue = notification.status.expandContent;
//            view.avatarView.statusVisibility = notification.status.visibility;
            break;
        case DONMastodonNotificationFavoriteType:
            view.summaryField.stringValue = [NSString stringWithFormat:@"⭐️ @%@ さんにふぁぼられました", notification.account.fullAcct];
            view.detailField.stringValue = notification.status.expandContent;
//            view.avatarView.statusVisibility = notification.status.visibility;
            break;
        case DONMastodonNotificationPollType:
            view.summaryField.stringValue = @"🗳 投票が終了しました";
            view.detailField.stringValue = notification.status.expandContent;
            view.avatarView.statusVisibility = notification.status.visibility;
            break;
        case DONMastodonNotificationStatusType:
            view.summaryField.stringValue = [NSString stringWithFormat:@"📥 @%@ さんの新しいトゥート", notification.account.fullAcct];
            view.detailField.stringValue = notification.status.expandContent;
            view.avatarView.statusVisibility = notification.status.visibility;
            break;
        case DONMastodonNotificationUpdateType:
            view.summaryField.stringValue = [NSString stringWithFormat:@"✏️ @%@ さんが投稿を編集しました", notification.account.fullAcct];
            view.detailField.stringValue = notification.status.expandContent;
            view.avatarView.statusVisibility = notification.status.visibility;
            break;
        default: {
            view.summaryField.stringValue = [NSString stringWithFormat:@"不明な通知 (%@)", notification.rawType];
            NSMutableString *detail = [NSMutableString stringWithFormat:@"@%@", notification.account.fullAcct];
            if (notification.status) {
                [detail appendString:@"\n"];
                [detail appendString:notification.status.expandContent];
            }
            view.detailField.stringValue = detail;
            break;
        }
    }
    
    return view;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.notifications.count;
}

#pragma mark - Actions

- (IBAction)reload:(id)sender {
    __weak typeof(self) weakSelf = self;
    [App.client notificationsWithCompletion:^(NSURLSessionDataTask * _Nonnull task, NSArray<DONMastodonNotification *> * _Nullable results, NSError * _Nullable error) {
        if (error) {
            WriteAFNetworkingErrorToLog(error);
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.notifications = results;
        [strongSelf.tableView reloadData];
    }];
}

- (IBAction)openThread:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONMastodonNotification *notify = self.notifications[row];
    if (!notify.status) {
        return;
    }
    ThreadWindow *window = [[ThreadWindow alloc] initWithStatusID:notify.status.originalStatus.identity];
    NSPoint mouseLocation = NSEvent.mouseLocation;
    [window setFrameTopLeftPoint:NSMakePoint(mouseLocation.x - 8, mouseLocation.y - 8)];
    [window makeKeyAndOrderFront:self];
}

@end
