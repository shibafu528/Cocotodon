//
// Copyright (c) 2020 shibafu
//

#import "NSString+DONExtension.h"

@implementation NSString (DONExtension)

- (NSUInteger)characterCount {
    // Original: https://github.com/twitter/twitter-text/
    
    NSUInteger length = self.length;
    NSUInteger adjustedLength = length;

    if (length != 0) {
        UniChar buffer[length];
        [self getCharacters:buffer range:NSMakeRange(0, length)];

        for (NSUInteger i = 0; i < length; i++) {
            UniChar chr = buffer[i];
            if (CFStringIsSurrogateHighCharacter(chr)) {
                if (i + 1 < length) {
                    UniChar pair = buffer[i + 1];
                    if (CFStringIsSurrogateLowCharacter(pair)) {
                        adjustedLength--;
                        i++;
                    }
                }
            }
        }
    }
    
    return adjustedLength;
}

@end
