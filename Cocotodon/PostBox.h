//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>
#import "DONPicture.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostBox : NSControl

- (NSString *)message;

- (void)setMessage:(NSString *)message;

- (DONStatusVisibility)visibility;

- (void)setVisibility:(DONStatusVisibility)visibility;

- (NSArray<DONPicture*>*)pictures;

- (void)clear;

- (void)focus;

- (void)setSelectedRange:(NSRange)charRange;

@end

NS_ASSUME_NONNULL_END
