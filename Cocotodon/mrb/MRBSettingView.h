//
// Copyright (c) 2020 shibafu
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBSettingView : NSView

@property (nonatomic, readonly) mrb_sym config;

- (instancetype)initWithFrame:(NSRect)frameRect config:(mrb_sym)config;

@end

NS_ASSUME_NONNULL_END
