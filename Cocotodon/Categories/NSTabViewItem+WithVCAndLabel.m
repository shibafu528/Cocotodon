//
// Copyright (c) 2022 shibafu
//

#import "NSTabViewItem+WithVCAndLabel.h"

@implementation NSTabViewItem (WithVCAndLabel)

+ (instancetype)tabViewItemWithViewController:(nonnull NSViewController *)viewController label:(NSString *)label {
    NSTabViewItem *item = [NSTabViewItem tabViewItemWithViewController:viewController];
    item.label = label;
    return item;
}

@end
