//
// Copyright (c) 2022 shibafu
//

#import "NotificationViewController.h"
#import "NotificationCellView.h"

@interface NotificationViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic) NSArray<DONMastodonNotification *> *notifications;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notifications = @[];
    
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
        default:
            NSLog(@"ws unknown notification type!");
            NSLog(@"ws notification: %@", notification);
            break;
    }
    
    return view;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.notifications.count;
}

@end
