//
// Copyright (c) 2021 shibafu
//

#import "ClickableImageView.h"

@implementation ClickableImageView

- (void)mouseDown:(NSEvent *)event {
    if ([self.target respondsToSelector:self.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
    }
}

- (void)resetCursorRects {
    [super resetCursorRects];
    [self addCursorRect:self.frame cursor:NSCursor.pointingHandCursor];
}

@end
