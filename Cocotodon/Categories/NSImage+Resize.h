//
// Copyright (c) 2021 shibafu
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (Resize)

- (instancetype)resizeToSize:(NSSize)size;

- (instancetype)resizeToScreenSize:(NSSize)size;

@end

NS_ASSUME_NONNULL_END
