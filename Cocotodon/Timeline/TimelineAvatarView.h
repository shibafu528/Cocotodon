//
// Copyright (c) 2021 shibafu
//

#import <Cocoa/Cocoa.h>
#import "DONStatusVisibility.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineAvatarView : NSView

@property (nonatomic, nullable) IBInspectable NSImage *primaryImage;
@property (nonatomic, nullable) IBInspectable NSImage *secondaryImage;
@property (nonatomic) IBInspectable DONStatusVisibility statusVisibility;

@end

NS_ASSUME_NONNULL_END
