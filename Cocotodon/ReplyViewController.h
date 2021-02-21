//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>
#import "DONStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReplyViewController : NSViewController

- (void)setReplyToAndAutoPopulate:(DONStatus*)status;

- (void)setReplyTo:(DONStatus*)status withHeader:(nullable NSString*)header footer:(nullable NSString*)footer;

- (void)setHeader:(nullable NSString*)header andFooter:(nullable NSString*)footer;

@end

NS_ASSUME_NONNULL_END
