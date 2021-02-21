//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import <mruby.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBPin : NSObject

@property (nonatomic, readonly) mrb_state *mrb;
@property (nonatomic, readonly) mrb_value value;

- (instancetype) init __attribute__((unavailable("init is not available")));

- (instancetype) initWithValue:(mrb_value)value by:(mrb_state*)mrb;

- (id)objectForKeyedSubscript:(id)key;

@end

NS_ASSUME_NONNULL_END
