//
// Copyright (c) 2022 shibafu
//

#import "TimelineTableView.h"

@implementation TimelineTableView

- (void)keyDown:(NSEvent *)event {
    if ([event.characters isEqualToString:@"j"]) {
        if (-1 < self.selectedRow && self.selectedRow < self.numberOfRows - 1) {
            NSInteger newIndex = self.selectedRow + 1;
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
            [self scrollRowToVisible:newIndex];
        }
    } else if ([event.characters isEqualToString:@"k"]) {
        if (self.selectedRow > 0) {
            NSInteger newIndex = self.selectedRow - 1;
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
            [self scrollRowToVisible:newIndex];
        }
    } else {
        [super keyDown:event];
    }
}

@end
