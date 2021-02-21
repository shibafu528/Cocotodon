//
// Copyright (c) 2020 shibafu
//

#import "NSString+ReplaceLineBreaks.h"

@implementation NSString (ReplaceLineBreaks)

- (NSString*)stringByReplacingLineBreaksWithString:(NSString*)replacement {
    return [[self stringByReplacingOccurrencesOfString:@"\u2028" withString:replacement]
            stringByReplacingOccurrencesOfString:@"\n" withString:replacement];
}

@end
