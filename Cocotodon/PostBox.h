//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>
#import "DONPicture.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PostBoxBorderStyle) {
    PostBoxBorderStyleNone,
    PostBoxBorderStyleRect,
    PostBoxBorderStyleBottomLine,
};

@interface PostBox : NSControl

@property (nonatomic) IBInspectable PostBoxBorderStyle borderStyle;
@property (nonatomic) BOOL showSpoilerText;
@property (nonatomic, readonly, getter=isSensitive) BOOL sensitive;

- (NSString *)message;

- (void)setMessage:(NSString *)message;

- (DONStatusVisibility)visibility;

- (void)setVisibility:(DONStatusVisibility)visibility;

- (NSArray<DONPicture*>*)pictures;

- (void)attachPicture:(DONPicture*)picture;

- (NSString *)spoilerText;

- (void)setSpoilerText:(NSString *)spoilerText;

- (void)clear;

- (void)focus;

- (void)setSelectedRange:(NSRange)charRange;

@end

NS_ASSUME_NONNULL_END
