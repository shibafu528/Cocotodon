//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostBoxDraft : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *spoilerText;
@property (nonatomic) DONStatusVisibility visibility;
@property (nonatomic, readonly) NSMutableArray<DONPicture*> *pictures;
@property (nonatomic, getter=isSensitive) BOOL sensitive;

@property (nonatomic, readonly, getter=isPostable) BOOL postable;
@property (nonatomic, readonly) NSInteger remainingCharacterCount;

- (void)insertObject:(DONPicture *)object inPicturesAtIndex:(NSUInteger)index;

- (void)removeObjectFromPicturesAtIndex:(NSUInteger)index;

- (void)removeAllPictures;

@end

NS_ASSUME_NONNULL_END
