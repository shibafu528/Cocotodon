//
// Copyright (c) 2021 shibafu
//

#import "TimelineAvatarView.h"
@import QuartzCore.CATransaction;

@interface TimelineAvatarView ()

@property (nonatomic) CALayer *visibilityLayer;
@property (nonatomic) CALayer *secondaryImageLayer;

@end

@implementation TimelineAvatarView

- (void)awakeFromNib {
    self.wantsLayer = YES;
    self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawDuringViewResize;
    
    self.layer.minificationFilter = kCAFilterTrilinear;
    
    self.visibilityLayer = [CALayer layer];
    self.visibilityLayer.minificationFilter = kCAFilterTrilinear;
    [self.layer addSublayer:self.visibilityLayer];
    
    self.secondaryImageLayer = [CALayer layer];
    self.secondaryImageLayer.minificationFilter = kCAFilterTrilinear;
    [self.layer addSublayer:self.secondaryImageLayer];
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)updateLayer {
    [super updateLayer];
    
    [CATransaction begin];
    CATransaction.disableActions = YES;
    
    self.layer.contents = self.primaryImage;
    self.layer.cornerRadius = 6.0f;
    self.layer.contentsGravity = kCAGravityResizeAspectFill;

    NSImage *visibility = [self.class imageByVisibility:self.statusVisibility];
    if (visibility) {
        self.visibilityLayer.contents = visibility;
        self.visibilityLayer.hidden = NO;
        self.visibilityLayer.contentsGravity = kCAGravityResizeAspect;
        self.visibilityLayer.backgroundColor = NSColor.blackColor.CGColor;
        self.visibilityLayer.opacity = 0.8f;
        self.visibilityLayer.cornerRadius = 3.0f;
        {
            int size = 16;
            self.visibilityLayer.frame = NSMakeRect(2, CGRectGetHeight(self.layer.frame) - size - 4, size, size);
        }
    } else {
        self.visibilityLayer.hidden = YES;
    }
    
    if (self.secondaryImage) {
        self.secondaryImageLayer.hidden = NO;
        self.secondaryImageLayer.borderWidth = 1;
        self.secondaryImageLayer.borderColor = NSColor.grayColor.CGColor;
        self.secondaryImageLayer.backgroundColor = NSColor.controlBackgroundColor.CGColor;
        self.secondaryImageLayer.contents = self.secondaryImage;
        self.secondaryImageLayer.cornerRadius = 6.0f;
        self.secondaryImageLayer.contentsGravity = kCAGravityResizeAspect;
        self.secondaryImageLayer.masksToBounds = YES;
        {
            int size = MIN(CGRectGetHeight(self.layer.frame), 24);
            self.secondaryImageLayer.frame = NSMakeRect(CGRectGetWidth(self.layer.frame) - size, 0, size, size);
        }
    } else {
        self.secondaryImageLayer.hidden = YES;
    }
    
    [CATransaction commit];
}

- (void)setPrimaryImage:(NSImage *)primaryImage {
    _primaryImage = primaryImage;
    self.needsDisplay = YES;
}

- (void)setSecondaryImage:(NSImage *)secondaryImage {
    _secondaryImage = secondaryImage;
    self.needsDisplay = YES;
}

+ (NSImage*)imageByVisibility:(DONStatusVisibility)visibility {
    static dispatch_once_t unlistedOnceToken;
    static dispatch_once_t privateOnceToken;
    static dispatch_once_t directOnceToken;
    static NSImage *unlisted;
    static NSImage *private;
    static NSImage *direct;
    if (@available(macOS 11.0, *)) {
        switch (visibility) {
            case DONStatusUnlisted:
                dispatch_once(&unlistedOnceToken, ^{
                    unlisted = [self tintedImage:[NSImage imageWithSystemSymbolName:@"lock.open.fill" accessibilityDescription:nil]];
                });
                return unlisted;
            case DONStatusPrivate:
                dispatch_once(&privateOnceToken, ^{
                    private = [self tintedImage:[NSImage imageWithSystemSymbolName:@"lock.fill" accessibilityDescription:nil]];
                });
                return private;
            case DONStatusDirect:
                dispatch_once(&directOnceToken, ^{
                    direct = [self tintedImage:[NSImage imageWithSystemSymbolName:@"envelope.fill" accessibilityDescription:nil]];
                });
                return direct;
            default:
                return nil;
        }
    } else {
        return nil;
    }
}

+ (NSImage*)tintedImage:(NSImage*)image {
    [image lockFocus];
    [NSColor.whiteColor set];
    NSRectFillUsingOperation(NSMakeRect(0, 0, image.size.width, image.size.height), NSCompositingOperationSourceIn);
    [image unlockFocus];
    return image;
}

@end
