//
// Copyright (c) 2020 shibafu
//

#import "MRBProc.h"
#import "mruby/proc.h"

static mrb_value proc_with_block_callback(mrb_state *mrb, mrb_value self) {
    __auto_type block = (__bridge MRBProcBlock) mrb_cptr(mrb_proc_cfunc_env_get(mrb, 0));
    return block(mrb);
}

@interface MRBProc ()

@property (nonatomic, readwrite) mrb_state *mrb;
@property (nonatomic, readwrite) mrb_value value;
@property (nonatomic, readwrite, copy) MRBProcBlock block;

@end

@implementation MRBProc

- (instancetype)initWithBlock:(MRBProcBlock)block by:(mrb_state *)mrb {
    if (self = [super init]) {
        self.mrb = mrb;
        self.block = block;
        
        mrb_value ptr = mrb_cptr_value(mrb, (__bridge void*) self.block);
        struct RProc *proc = mrb_proc_new_cfunc_with_env(mrb, proc_with_block_callback, 1, &ptr);
        self.value = mrb_obj_value(proc);
        mrb_gc_register(self.mrb, self.value);
    }
    return self;
};

- (void)dealloc {
    mrb_gc_unregister(self.mrb, self.value);
}

@end
