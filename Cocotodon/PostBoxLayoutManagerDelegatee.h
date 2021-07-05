//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostBoxLayoutManagerDelegatee : NSObject <NSLayoutManagerDelegate>

- (instancetype)initWithTextView:(NSTextView*)textView;

@end

NS_ASSUME_NONNULL_END
