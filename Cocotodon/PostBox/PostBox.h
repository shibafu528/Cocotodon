//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>
#import "PostBoxDraft.h"
#import "PostBoxAutocompleteDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PostBoxBorderStyle) {
    PostBoxBorderStyleNone,
    PostBoxBorderStyleRect,
    PostBoxBorderStyleBottomLine,
};

@interface PostBox : NSControl <PostBoxAutocompleteDelegate>

@property (nonatomic) PostBoxDraft *draft;
@property (nonatomic) IBInspectable PostBoxBorderStyle borderStyle;
@property (nonatomic) BOOL showSpoilerText;
@property (nonatomic) BOOL posting;

- (void)attachPicture:(DONPicture*)picture;

- (void)clear;

- (void)focus;

- (void)setSelectedRange:(NSRange)charRange;

@end

NS_ASSUME_NONNULL_END
