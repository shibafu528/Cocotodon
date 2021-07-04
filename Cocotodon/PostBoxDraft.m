//
// Copyright (c) 2021 shibafu
//

#import "PostBoxDraft.h"

@implementation PostBoxDraft

- (instancetype)init {
    if (self = [super init]) {
        _message = @"";
        _spoilerText = @"";
        _visibility = DONStatusPublic;
        _pictures = [NSMutableArray array];
        _sensitive = NO;
    }
    return self;
}

- (BOOL)isPostable {
    return self.message.characterCount != 0 || self.pictures.count != 0;
}

+ (NSSet *)keyPathsForValuesAffectingIsPostable {
    return [NSSet setWithObjects:@"message", @"pictures", nil];
}

- (NSInteger)remainingCharacterCount {
    NSUInteger count = self.message.characterCount;
    if (count <= 500) {
        return 500 - count;
    } else {
        return -(count - 500);
    }
}

+ (NSSet *)keyPathsForValuesAffectingRemainingCharacterCount {
    return [NSSet setWithObject:@"message"];
}

- (void)insertObject:(DONPicture *)object inPicturesAtIndex:(NSUInteger)index {
    [self.pictures insertObject:object atIndex:index];
}

- (void)removeObjectFromPicturesAtIndex:(NSUInteger)index {
    [self.pictures removeObjectAtIndex:index];
}

- (void)removeAllPictures {
    [self willChangeValueForKey:@"pictures"];
    [self.pictures removeAllObjects];
    [self didChangeValueForKey:@"pictures"];
}

@end
