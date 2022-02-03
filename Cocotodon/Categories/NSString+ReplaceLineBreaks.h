//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ReplaceLineBreaks)

- (NSString*)stringByReplacingLineBreaksWithString:(NSString*)replacement;

- (NSString *)stringByRemovingLineBreaksAndJoinedByString:(NSString *)separator;

@end

NS_ASSUME_NONNULL_END
