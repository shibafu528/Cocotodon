//
// Copyright (c) 2022 shibafu
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTabViewItem (WithVCAndLabel)

+ (instancetype)tabViewItemWithViewController:(nonnull NSViewController *)viewController label:(NSString *)label;

@end

NS_ASSUME_NONNULL_END
