//
// Copyright (c) 2021 shibafu
//

#import "PostBoxSpoilerTextField.h"

@implementation PostBoxSpoilerTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [NSColor.separatorColor set];
    [path moveToPoint:NSMakePoint(0, self.bounds.size.height)];
    [path lineToPoint:NSMakePoint(self.bounds.size.width, self.bounds.size.height)];
    path.lineWidth = 1;
    [path stroke];
}

@end
