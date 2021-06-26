//
// Copyright (c) 2021 shibafu
//

#import "AnnouncementViewController.h"
#import "AnnouncementTableCellView.h"
#import "DONEmojiExpander.h"

@interface AnnouncementViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@end

@implementation AnnouncementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    AnnouncementTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    DONMastodonAnnouncement *announcement = ((NSArray<DONMastodonAnnouncement*>*)self.representedObject)[row];
    if (announcement) {
        view.contentAttributedString = [DONEmojiExpander expandFromAttributedString:announcement.expandAttributedContent providedBy:announcement];
    }
    return view;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [(NSArray*)self.representedObject count];
}

@end
