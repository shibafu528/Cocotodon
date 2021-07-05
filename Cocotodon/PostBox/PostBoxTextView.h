//
// Copyright (c) 2021 shibafu
//

#import <Cocoa/Cocoa.h>
#import "PostBox.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostBoxTextView : NSTextView

@property (nonatomic, weak) IBOutlet PostBox *postbox;

@end

NS_ASSUME_NONNULL_END
