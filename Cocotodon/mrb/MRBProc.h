//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import <mruby.h>

NS_ASSUME_NONNULL_BEGIN

typedef mrb_value (^MRBProcBlock)(mrb_state *mrb);

@interface MRBProc : NSObject

@property (nonatomic, readonly) mrb_state *mrb;
@property (nonatomic, readonly) mrb_value value;

- (instancetype) init __attribute__((unavailable("init is not available")));

- (instancetype) initWithBlock:(MRBProcBlock)block by:(mrb_state *)mrb;

@end

NS_ASSUME_NONNULL_END
