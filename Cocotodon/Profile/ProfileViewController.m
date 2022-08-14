//
// Copyright (c) 2022 shibafu
//

#import "ProfileViewController.h"
#import "ProfileHeaderView.h"

@interface ProfileViewController ()

@property (nonatomic, weak) IBOutlet ProfileHeaderView *headerView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    self.headerView.avatarImage = nil;
    self.headerView.headerImage = nil;
    
    DONMastodonAccount *account = (DONMastodonAccount *) representedObject;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        if (!account.headerStatic) {
            return;
        }
        NSImage *header = [[NSImage alloc] initWithContentsOfURL:account.headerStatic];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf.headerView.headerImage = header;
            }
        });
    });
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        if (!account.avatarStatic) {
            return;
        }
        NSImage *avatar = [[NSImage alloc] initWithContentsOfURL:account.avatarStatic];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf.headerView.avatarImage = avatar;
            }
        });
    });
}

@end
