//
// Copyright (c) 2021 shibafu
//

#import "AnnouncementTableCellView.h"

@interface AnnouncementTableCellView ()

@property (nonatomic, readwrite) AutolayoutTextView *textView;

@end

@implementation AnnouncementTableCellView

- (void)setContentAttributedString:(NSAttributedString *)string {
    NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    // Font
    [mutable addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]] range:NSMakeRange(0, string.length)];
    [mutable addAttribute:NSForegroundColorAttributeName value:[NSColor controlTextColor] range:NSMakeRange(0, string.length)];
    
    // Paragraph style
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [mutable addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, string.length)];
    
    [self.textView.textStorage setAttributedString:mutable];
}

#pragma mark - Overrides

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textView = [[AutolayoutTextView alloc] init];
    self.textView.editable = NO;
    self.textView.drawsBackground = NO;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.textColor = [NSColor controlTextColor];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.textView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.leadingAnchor constraintEqualToAnchor:self.textView.leadingAnchor constant:-2],
        [self.trailingAnchor constraintEqualToAnchor:self.textView.trailingAnchor constant:-2],
        [self.topAnchor constraintEqualToAnchor:self.textView.topAnchor constant:-6],
        [self.bottomAnchor constraintEqualToAnchor:self.textView.bottomAnchor constant:6],
    ]];
}

@end
