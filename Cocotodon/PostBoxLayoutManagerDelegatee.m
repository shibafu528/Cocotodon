//
// Copyright (c) 2021 shibafu
//

#import "PostBoxLayoutManagerDelegatee.h"

@interface PostBoxLayoutManagerDelegatee ()

@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) CGFloat baselineOffset;

@end

@implementation PostBoxLayoutManagerDelegatee

- (instancetype)initWithTextView:(NSTextView *)textView {
    if (self = [super init]) {
        [self cacheMetricsForFont:textView.font layoutBy:textView.layoutManager];
        [textView addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)cacheMetricsForFont:(NSFont *)font layoutBy:(NSLayoutManager *)layoutManager {
    self.lineHeight = [layoutManager defaultLineHeightForFont:font];
    CGFloat baselineOffset = [layoutManager defaultBaselineOffsetForFont:font];
    self.baselineOffset = (self.lineHeight + baselineOffset - (font.ascender - font.capHeight)) / 2;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"font"]) {
        [self cacheMetricsForFont:change[NSKeyValueChangeNewKey] layoutBy:[object layoutManager]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSLayoutManagerDelegate

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldSetLineFragmentRect:(inout NSRect *)lineFragmentRect lineFragmentUsedRect:(inout NSRect *)lineFragmentUsedRect baselineOffset:(inout CGFloat *)baselineOffset inTextContainer:(NSTextContainer *)textContainer forGlyphRange:(NSRange)glyphRange {
    lineFragmentRect->size.height = self.lineHeight;
    lineFragmentUsedRect->size.height = self.lineHeight;
    *baselineOffset = self.baselineOffset;
    return YES;
}

@end
