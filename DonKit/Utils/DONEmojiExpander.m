//
// Copyright (c) 2021 shibafu
//

#import "DONEmojiExpander.h"

@implementation DONEmojiExpander

+ (NSAttributedString *)expandFromAttributedString:(NSAttributedString *)string providedBy:(id<DONEmojiProvider>)provider {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    [provider.emojis enumerateObjectsUsingBlock:^(DONEmoji * _Nonnull emoji, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *shortcode = [NSString stringWithFormat:@":%@:", emoji.shortcode];
        NSRange range = NSMakeRange(NSNotFound, 0);
        while ((range = [str.string rangeOfString:shortcode]).location != NSNotFound) {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            NSFont *font = [str attribute:NSFontAttributeName atIndex:range.location longestEffectiveRange:nil inRange:range] ?: [NSFont systemFontOfSize:[NSFont systemFontSize]];
            CGFloat size = font.ascender + ABS(font.descender);
            attachment.bounds = NSMakeRect(0, font.descender, size, size);
            attachment.image = [[NSImage alloc] initWithContentsOfURL:emoji.URL];
            [str replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        }
    }];
    
    return str;
}

@end
