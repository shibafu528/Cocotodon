//
// Copyright (c) 2022 shibafu
//

#import "TableCellViewInversionHelper.h"

@interface TableCellViewInversionHelper ()

@property (nonatomic, readonly) NSDictionary<NSAttributedStringKey, id> *linkNormalAttributes;
@property (nonatomic, readonly) NSDictionary<NSAttributedStringKey, id> *linkEmphasizedAttributes;

@end

@implementation TableCellViewInversionHelper

- (instancetype)init {
    if (self = [super init]) {
        _linkNormalAttributes = @{
            NSForegroundColorAttributeName: [NSColor controlTextColor],
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSCursorAttributeName: [NSCursor pointingHandCursor]
        };
        _linkEmphasizedAttributes = @{
            NSForegroundColorAttributeName: [NSColor alternateSelectedControlTextColor],
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSCursorAttributeName: [NSCursor pointingHandCursor]
        };
    }
    return self;
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle toTextView:(NSTextView *)textView {
    // https://stackoverflow.com/q/9149138
    // https://stackoverflow.com/q/29859224
    switch (backgroundStyle) {
        case NSBackgroundStyleNormal:
            textView.textColor = [NSColor controlTextColor];
            textView.linkTextAttributes = self.linkNormalAttributes;
            break;
        case NSBackgroundStyleEmphasized:
            textView.textColor = [NSColor alternateSelectedControlTextColor];
            textView.linkTextAttributes = self.linkEmphasizedAttributes;
            break;
    }
}

@end
