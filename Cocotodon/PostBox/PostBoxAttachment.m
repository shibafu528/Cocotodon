//
// Copyright (c) 2022 shibafu
//

#import "PostBoxAttachment.h"

@interface PostBoxAttachment ()

@property (nonatomic, nullable, readwrite) DONPicture *picture;
@property (nonatomic, nullable, readwrite) DONMastodonAttachment *attachment;

@end

@implementation PostBoxAttachment

- (instancetype)initWithPicture:(DONPicture *)picture {
    if (self = [super init]) {
        _picture = picture;
    }
    return self;
}

- (instancetype)initWithAttachment:(DONMastodonAttachment *)attachment {
    if (self = [super init]) {
        _attachment = attachment;
    }
    return self;
}

- (NSImage *)thumbnail {
    if (self.picture) {
        return [[NSImage alloc] initWithData:self.picture.data];
    } else if (self.attachment) {
        return [[NSImage alloc] initWithContentsOfURL:self.attachment.previewURL];
    }
    return nil;
}

@end
