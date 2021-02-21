//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MRBState : NSObject

@property (nonatomic, readonly) mrb_state *mrb;

@end

NS_ASSUME_NONNULL_END
