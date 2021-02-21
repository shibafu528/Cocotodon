//
// Copyright (c) 2020 shibafu
//

#import "MRBState.h"

@interface MRBState ()

@property (nonatomic, readwrite) mrb_state *mrb;

@end

@implementation MRBState

- (instancetype)init {
    if (self = [super init]) {
        self.mrb = mrb_open();
    }
    return self;
}

- (void)dealloc {
    mrb_close(self.mrb);
}

@end
