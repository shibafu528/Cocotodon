//
// Copyright (c) 2021 shibafu
//

#import "ExpandableCellView.h"

@interface ExpandableCellView ()

@property (nonatomic, readwrite) AutolayoutTextView *expandedText;
@property (nonatomic) NSView *expandedContainer;
@property (nonatomic) NSStackView *attachmentsContainer;
@property (nonatomic) NSLayoutConstraint *attachmentsContainerTopSpacingConstraint;
@property (nonatomic) NSLayoutConstraint *attachmentsContainerTopNonSpacingConstraint;

@property (nonatomic) NSDictionary<NSAttributedStringKey, id> *linkNormalAttributes;
@property (nonatomic) NSDictionary<NSAttributedStringKey, id> *linkEmphasizedAttributes;

@end

@implementation ExpandableCellView

#pragma mark - Public

- (void)setAttachments:(NSArray<DONMastodonAttachment *> *)attachments {
    _attachments = attachments;
    
    [self.attachmentsContainer.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.attachmentsContainer removeArrangedSubview:view];
        [view removeFromSuperview];
    }];
    
    if (attachments.count == 0) {
        [NSLayoutConstraint activateConstraints:@[self.attachmentsContainerTopNonSpacingConstraint]];
        [NSLayoutConstraint deactivateConstraints:@[self.attachmentsContainerTopSpacingConstraint]];
    } else {
        [NSLayoutConstraint activateConstraints:@[self.attachmentsContainerTopSpacingConstraint]];
        [NSLayoutConstraint deactivateConstraints:@[self.attachmentsContainerTopNonSpacingConstraint]];
    }
    
    [attachments enumerateObjectsUsingBlock:^(DONMastodonAttachment * _Nonnull attachment, NSUInteger idx, BOOL * _Nonnull stop) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:attachment.previewURL];
        if (!image) {
            image = [NSImage imageNamed:NSImageNameCaution];
        }
        
        NSButton *view = [NSButton buttonWithImage:image target:self action:@selector(clickThumbnail:)];
        view.tag = idx;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.imageScaling = NSImageScaleProportionallyDown;
        view.imagePosition = NSImageOnly;
        view.bordered = NO;
        [view setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
        [view setContentCompressionResistancePriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
        [self.attachmentsContainer addArrangedSubview:view];
        [view.heightAnchor constraintEqualToConstant:72.0f].active = YES;
    }];
}

- (void)setExpanded:(BOOL)expanded {
    if (_expanded == expanded) {
        return;
    }
    
    _expanded = expanded;
    [self updateExpandConstraints];
}

- (void)setSummaryString:(NSAttributedString *)string {
    NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    // Font
    [mutable addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]] range:NSMakeRange(0, string.length)];
    
    // Paragraph style
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    style.allowsDefaultTighteningForTruncation = NO;
    [mutable addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, string.length)];
    
    self.textField.attributedStringValue = mutable;
}

- (void)setExpandedString:(NSAttributedString *)string {
    NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    // Font
    [mutable addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]] range:NSMakeRange(0, string.length)];
    
    // Paragraph style
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [mutable addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, string.length)];
    
    [self.expandedText.textStorage setAttributedString:mutable];
}

- (void)setFavoriteState:(BOOL)state {
    if (state) {
        self.favoriteButton.image = [NSImage imageWithSystemSymbolName:@"star.fill" accessibilityDescription:nil];
        self.favoriteButton.contentTintColor = NSColor.systemYellowColor;
    } else {
        self.favoriteButton.image = [NSImage imageWithSystemSymbolName:@"star" accessibilityDescription:nil];
        self.favoriteButton.contentTintColor = NSColor.tertiaryLabelColor;
    }
}

#pragma mark - Actions

- (IBAction)favorite:(id)sender {
    [self.favoriteTarget performSelector:@selector(favoriteStatus:) withObject:self.status];
}

#pragma mark - Overrides

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.linkNormalAttributes = @{
        NSForegroundColorAttributeName: [NSColor controlTextColor],
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
        NSCursorAttributeName: [NSCursor pointingHandCursor]
    };
    self.linkEmphasizedAttributes = @{
        NSForegroundColorAttributeName: [NSColor alternateSelectedControlTextColor],
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
        NSCursorAttributeName: [NSCursor pointingHandCursor]
    };
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textField setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                                   forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.textField setContentCompressionResistancePriority:749
                                                   forOrientation:NSLayoutConstraintOrientationVertical];
    self.expandedText = [[AutolayoutTextView alloc] init];
    self.expandedText.editable = NO;
    self.expandedText.drawsBackground = NO;
    self.expandedText.textContainer.lineFragmentPadding = 0;
    self.expandedText.linkTextAttributes = self.linkNormalAttributes;
    self.expandedText.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.expandedContainer = [[NSView alloc] initWithFrame:CGRectZero];
    self.expandedContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.expandedContainer.hidden = YES;
    [self.expandedContainer setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                                     forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.expandedContainer setContentCompressionResistancePriority:751
                                                     forOrientation:NSLayoutConstraintOrientationVertical];
    [self.expandedContainer addSubview:self.expandedText];
    
    self.attachmentsContainer = [[NSStackView alloc] initWithFrame:CGRectZero];
    self.attachmentsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.attachmentsContainer.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    self.attachmentsContainer.alignment = NSLayoutAttributeWidth;
    self.attachmentsContainer.distribution = NSStackViewDistributionFillEqually;
    [self.attachmentsContainer setContentHuggingPriority:NSLayoutPriorityDefaultLow
                                          forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.attachmentsContainer setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
                                                        forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.attachmentsContainer setContentCompressionResistancePriority:NSLayoutPriorityDefaultHigh
                                                        forOrientation:NSLayoutConstraintOrientationVertical];
    [self.expandedContainer addSubview:self.attachmentsContainer];
    
    [self addSubview:self.expandedContainer];
    
    self.attachmentsContainerTopSpacingConstraint = [self.attachmentsContainer.topAnchor constraintEqualToAnchor:self.expandedText.bottomAnchor constant:6.0f];
    self.attachmentsContainerTopNonSpacingConstraint = [self.attachmentsContainer.topAnchor constraintEqualToAnchor:self.expandedText.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [self.expandedText.leadingAnchor constraintEqualToAnchor:self.expandedContainer.leadingAnchor],
        [self.expandedText.trailingAnchor constraintEqualToAnchor:self.expandedContainer.trailingAnchor],
        [self.expandedText.topAnchor constraintEqualToAnchor:self.expandedContainer.topAnchor],
        self.attachmentsContainerTopSpacingConstraint,
        [self.attachmentsContainer.leadingAnchor constraintEqualToAnchor:self.expandedContainer.leadingAnchor],
        [self.attachmentsContainer.trailingAnchor constraintEqualToAnchor:self.expandedContainer.trailingAnchor],
        [self.attachmentsContainer.bottomAnchor constraintEqualToAnchor:self.expandedContainer.bottomAnchor],
    ]];
    
    [self updateExpandConstraints];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    // https://stackoverflow.com/q/9149138
    // https://stackoverflow.com/q/29859224
    [super setBackgroundStyle:backgroundStyle];
    switch (backgroundStyle) {
        case NSBackgroundStyleNormal:
            self.expandedText.textColor = [NSColor controlTextColor];
            self.expandedText.linkTextAttributes = self.linkNormalAttributes;
            break;
        case NSBackgroundStyleEmphasized:
            self.expandedText.textColor = [NSColor alternateSelectedControlTextColor];
            self.expandedText.linkTextAttributes = self.linkEmphasizedAttributes;
            break;
    }
}

#pragma mark - Private

- (void)updateExpandConstraints {
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
        if (constraint.firstItem == self.textField || constraint.secondItem == self.textField ||
            constraint.firstItem == self.expandedContainer || constraint.secondItem == self.expandedContainer) {
            constraint.active = NO;
        }
    }];
    
    NSView *target = nil;
    if (self.expanded) {
        target = self.expandedContainer;
        self.expandedContainer.hidden = NO;
        self.textField.hidden = YES;
    } else {
        target = self.textField;
        self.textField.hidden = NO;
        self.expandedContainer.hidden = YES;
    }
    [NSLayoutConstraint activateConstraints:@[
        [target.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:2],
        [target.trailingAnchor constraintEqualToAnchor:self.favoriteButton.leadingAnchor constant:-2],
        [target.topAnchor constraintEqualToAnchor:self.topAnchor constant:4],
        [target.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4],
    ]];
}

- (void)clickThumbnail:(NSControl*)sender {
    NSInteger index = sender.tag;
    if (index < 0 || self.attachments.count <= index) {
        return;
    }
    
    DONMastodonAttachment *attachment = self.attachments[index];
    if ([attachment.type isEqualToString:@"image"]) {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        NSWindowController *wc = [storyboard instantiateControllerWithIdentifier:@"previewWindow"];
        wc.contentViewController.representedObject = self.attachments[index];
        [wc showWindow:self];
    } else {
        NSURL *url = attachment.remoteURL ? attachment.remoteURL : attachment.URL;
        [NSWorkspace.sharedWorkspace openURL:url];
    }
}

@end
