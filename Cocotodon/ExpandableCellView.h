//
// Copyright (c) 2021 shibafu
//

#import <Cocoa/Cocoa.h>
#import "AutolayoutTextView.h"
#import "DONMastodonAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExpandableCellView : NSTableCellView

@property (nonatomic, readonly) AutolayoutTextView *expandedText;
@property (nonatomic) NSArray<DONMastodonAttachment*> *attachments;
@property (nonatomic, getter=isExpanded) BOOL expanded;

- (void)setAttributedString:(NSAttributedString *)string;

@end

NS_ASSUME_NONNULL_END
