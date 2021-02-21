//
// Copyright (c) 2021 shibafu
//

#import "NSImage+Resize.h"

@implementation NSImage (Resize)

- (instancetype)resizeToSize:(NSSize)size {
    // https://stackoverflow.com/a/38442746
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:size.width
                             pixelsHigh:size.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    rep.size = size;
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [self drawInRect:NSMakeRect(0, 0, size.width, size.height)
            fromRect:NSZeroRect
           operation:NSCompositingOperationCopy
            fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSImage *newImage = [[NSImage alloc] initWithSize:size];
    [newImage addRepresentation:rep];
    
    return newImage;
}

- (instancetype)resizeToScreenSize:(NSSize)size {
    // https://stackoverflow.com/a/17396521
    NSImage *smallImage = [[NSImage alloc] initWithSize:size];
    [smallImage lockFocus];
    [self setSize:size];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [self drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, size.width, size.height) operation:NSCompositingOperationCopy fraction:1.0];
    [smallImage unlockFocus];
    return smallImage;
}

@end
