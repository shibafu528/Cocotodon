//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>

@class PostBoxDraft;
@class DONPicture;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PostBoxBorderStyle) {
    PostBoxBorderStyleNone,
    PostBoxBorderStyleRect,
    PostBoxBorderStyleBottomLine,
};

@interface PostBox : NSControl

@property (nonatomic) PostBoxDraft *draft;
@property (nonatomic) IBInspectable PostBoxBorderStyle borderStyle;
@property (nonatomic) BOOL showSpoilerText;

@property (nonatomic) NSString *message;
@property (nonatomic) NSString *spoilerText;
@property (nonatomic) DONStatusVisibility visibility;
@property (nonatomic, readonly) NSArray<DONPicture*> *pictures;
@property (nonatomic, readonly, getter=isSensitive) BOOL sensitive;

- (void)attachPicture:(DONPicture*)picture;

- (void)clear;

- (void)focus;

- (void)setSelectedRange:(NSRange)charRange;

@end

NS_ASSUME_NONNULL_END
