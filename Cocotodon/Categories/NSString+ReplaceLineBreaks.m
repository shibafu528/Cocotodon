//
// Copyright (c) 2020 shibafu
//

#import "NSString+ReplaceLineBreaks.h"

@implementation NSString (ReplaceLineBreaks)

- (NSString*)stringByReplacingLineBreaksWithString:(NSString*)replacement {
    return [[self stringByReplacingOccurrencesOfString:@"\u2028" withString:replacement]
            stringByReplacingOccurrencesOfString:@"\n" withString:replacement];
}

- (NSString *)stringByRemovingLineBreaksAndJoinedByString:(NSString *)separator {
    static NSMutableCharacterSet *trimCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trimCharacterSet = [NSMutableCharacterSet whitespaceCharacterSet];
        [trimCharacterSet addCharactersInString:@"\u200B\u200C\u200D\uFEFF"];
    });
    
    NSMutableString *result = [NSMutableString stringWithCapacity:self.length];
    NSArray<NSString *> *lines = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != 0) {
            [result appendString:separator];
        }
        [result appendString:[str stringByTrimmingCharactersInSet:trimCharacterSet]];
    }];
    return result;
}

@end
