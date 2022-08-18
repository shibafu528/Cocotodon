//
// Copyright (c) 2022 shibafu
//

#import <Cocoa/Cocoa.h>
#import "AutolayoutTextView.h"

NS_ASSUME_NONNULL_BEGIN

/// AutolayoutTextViewをIB上で配置するためのラッパーView
@interface AutolayoutTextViewWrapper : NSView

@property (nonatomic, readonly) AutolayoutTextView *textView;

- (instancetype)initWithFrame:(NSRect)frameRect NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (void)setAttributedString:(NSAttributedString *)attributedString;

@end

NS_ASSUME_NONNULL_END
