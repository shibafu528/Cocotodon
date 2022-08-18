//
// Copyright (c) 2022 shibafu
//

#import "AutolayoutTextViewWrapper.h"

@interface AutolayoutTextViewWrapper ()

@property (nonatomic, readwrite) AutolayoutTextView *textView;

@end

@implementation AutolayoutTextViewWrapper

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.textView = [[AutolayoutTextView alloc] init];
    [self addSubview:self.textView];
    
    self.textView.editable = NO;
    self.textView.drawsBackground = NO;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.textView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.textView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
    NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    // Font
    [mutable addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]] range:NSMakeRange(0, attributedString.length)];
    
    // Paragraph style
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3;
    [mutable addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
    
    [self.textView.textStorage setAttributedString:mutable];
}

@end
