//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import "DONStatusVisibility.h"
#import "DONPicture.h"
#import "PostBoxAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostBoxDraft : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *spoilerText;
@property (nonatomic) DONStatusVisibility visibility;
@property (nonatomic, readonly) NSMutableArray<PostBoxAttachment*> *attachments;
@property (nonatomic, getter=isSensitive) BOOL sensitive;

@property (nonatomic, readonly, getter=isPostable) BOOL postable;
@property (nonatomic, readonly) NSInteger remainingCharacterCount;

- (void)insertObject:(PostBoxAttachment *)object inAttachmentsAtIndex:(NSUInteger)index;

- (void)removeObjectFromAttachmentsAtIndex:(NSUInteger)index;

- (void)removeAllAttachments;

@end

NS_ASSUME_NONNULL_END
