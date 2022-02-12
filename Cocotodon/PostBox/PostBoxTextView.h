//
// Copyright (c) 2021 shibafu
//

#import <Cocoa/Cocoa.h>
#import "PostBox.h"
#import "PostBoxAutocompleteDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostBoxTextView : NSTextView

// FIXME: この依存関係は無いわー delegateに依存するべき
@property (nonatomic, weak) IBOutlet PostBox *postbox;
@property (nonatomic, weak) IBOutlet id<PostBoxAutocompleteDelegate> autocompleteDelegate;

@end

NS_ASSUME_NONNULL_END
