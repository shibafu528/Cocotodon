//
// Copyright (c) 2021 shibafu
//

#import "PostBoxDraft.h"
#import <twitter_text/twitter-text-umbrella.h>

@implementation PostBoxDraft

- (instancetype)init {
    if (self = [super init]) {
        _message = @"";
        _spoilerText = @"";
        _visibility = DONStatusPublic;
        _attachments = [NSMutableArray array];
        _sensitive = NO;
    }
    return self;
}

- (BOOL)isPostable {
    return self.message.length != 0 || self.attachments.count != 0;
}

+ (NSSet *)keyPathsForValuesAffectingIsPostable {
    return [NSSet setWithObjects:@"message", @"attachments", nil];
}

- (NSInteger)remainingCharacterCount {
    NSInteger count = [TwitterText tweetLength:self.message];
    if (count <= 500) {
        return 500 - count;
    } else {
        return -(count - 500);
    }
}

+ (NSSet *)keyPathsForValuesAffectingRemainingCharacterCount {
    return [NSSet setWithObject:@"message"];
}

- (void)insertObject:(PostBoxAttachment *)object inAttachmentsAtIndex:(NSUInteger)index {
    [self.attachments insertObject:object atIndex:index];
}

- (void)removeObjectFromAttachmentsAtIndex:(NSUInteger)index {
    [self.attachments removeObjectAtIndex:index];
}

- (void)removeAllAttachments {
    [self willChangeValueForKey:@"attachments"];
    [self.attachments removeAllObjects];
    [self didChangeValueForKey:@"attachments"];
}

@end
