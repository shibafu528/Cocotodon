//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>
#import "DONPicture.h"
#import "DONMastodonAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostBoxAttachment : NSObject

@property (nonatomic, nullable, readonly) DONPicture *picture;
@property (nonatomic, nullable, readonly) DONMastodonAttachment *attachment;

- (instancetype)init __attribute__((unavailable("init is not available")));

- (instancetype)initWithPicture:(DONPicture *)picture;

- (instancetype)initWithAttachment:(DONMastodonAttachment *)attachment;

- (NSImage *)thumbnail;

@end

NS_ASSUME_NONNULL_END
