//
// Copyright (c) 2022 shibafu
//

#import "ProfileHeaderView.h"
@import QuartzCore.CATransaction;
@import CoreImage.CIFilter;

@interface ProfileHeaderView ()

@property (nonatomic) CALayer *headerLayer;
@property (nonatomic) CALayer *avatarLayer;

@end

@implementation ProfileHeaderView

- (void)awakeFromNib {
    self.wantsLayer = YES;
    self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawDuringViewResize;
    
    self.headerLayer = [CALayer layer];
    self.headerLayer.minificationFilter = kCAFilterTrilinear;
    self.headerLayer.contentsGravity = kCAGravityResizeAspectFill;
    self.headerLayer.masksToBounds = YES;
    [self.layer addSublayer:self.headerLayer];
    
    self.avatarLayer = [CALayer layer];
    self.avatarLayer.backgroundFilters = @[[CIFilter filterWithName:@"CIGaussianBlur"]];
    self.avatarLayer.borderWidth = 1.0f;
    self.avatarLayer.borderColor = NSColor.whiteColor.CGColor;
    self.avatarLayer.contentsGravity = kCAGravityResizeAspect;
    self.avatarLayer.cornerRadius = 6.0f;
    self.avatarLayer.minificationFilter = kCAFilterTrilinear;
    self.avatarLayer.masksToBounds = YES;
    self.avatarLayer.frame = NSMakeRect(20, 0, 64, 64);
    [self.layer addSublayer:self.avatarLayer];
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)updateLayer {
    [super updateLayer];
    
    [CATransaction begin];
    CATransaction.disableActions = YES;
    
    self.headerLayer.backgroundColor = NSColor.windowBackgroundColor.CGColor;
    self.headerLayer.contents = self.headerImage;
    self.headerLayer.frame = NSMakeRect(0, 20, CGRectGetWidth(self.layer.frame), CGRectGetHeight(self.layer.frame) - 20);
    self.avatarLayer.contents = self.avatarImage;
    
    [CATransaction commit];
}

- (void)setAvatarImage:(NSImage *)avatarImage {
    _avatarImage = avatarImage;
    self.needsDisplay = YES;
}

- (void)setHeaderImage:(NSImage *)headerImage {
    _headerImage = headerImage;
    self.needsDisplay = YES;
}

@end
