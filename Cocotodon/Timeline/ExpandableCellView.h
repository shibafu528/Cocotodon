//
// Copyright (c) 2021 shibafu
//

#import <Cocoa/Cocoa.h>
#import "AutolayoutTextView.h"
#import "DONMastodonAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExpandableCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSButton *favoriteButton;
@property (nonatomic, readonly) AutolayoutTextView *expandedText;
@property (nonatomic) DONStatus *status;
// TODO: status渡すことにしたので廃止したい
@property (nonatomic) NSArray<DONMastodonAttachment*> *attachments __attribute__((deprecated));
@property (nonatomic, getter=isExpanded) BOOL expanded;

@property (nonatomic, weak) IBOutlet id favoriteTarget;

- (void)setSummaryString:(NSAttributedString *)string;
- (void)setExpandedString:(NSAttributedString *)string;
- (void)setFavoriteState:(BOOL)state;

@end

NS_ASSUME_NONNULL_END
