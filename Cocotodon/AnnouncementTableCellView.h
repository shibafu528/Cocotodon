//
// Copyright (c) 2021 shibafu
//

#import <Cocoa/Cocoa.h>
#import "AutolayoutTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnnouncementTableCellView : NSTableCellView

@property (nonatomic, readonly) AutolayoutTextView *textView;

- (void)setContentAttributedString:(NSAttributedString *)string;

@end

NS_ASSUME_NONNULL_END
