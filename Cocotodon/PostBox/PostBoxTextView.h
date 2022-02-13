//
// Copyright (c) 2021 shibafu
//

#import <Cocoa/Cocoa.h>
#import "PostBoxAttachmentDelegate.h"
#import "PostBoxAutocompleteDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostBoxTextView : NSTextView

@property (nonatomic, weak) IBOutlet id<PostBoxAttachmentDelegate> attachmentDelegate;
@property (nonatomic, weak) IBOutlet id<PostBoxAutocompleteDelegate> autocompleteDelegate;

- (void)setCandidates:(NSArray<NSString *> *)candidates forKeyword:(NSString*)keyword;

@end

NS_ASSUME_NONNULL_END
