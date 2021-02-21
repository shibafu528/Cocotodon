//
// Copyright (c) 2020 shibafu
//

#import "MRBPin.h"

@interface MRBPin ()

@property (nonatomic, readwrite) mrb_state *mrb;
@property (nonatomic, readwrite) mrb_value value;

@end

@implementation MRBPin

- (instancetype)initWithValue:(mrb_value)value by:(mrb_state *)mrb {
    if (self = [super init]) {
        _mrb = mrb;
        _value = value;
        mrb_gc_register(mrb, value);
    }
    return self;
}

- (void)dealloc {
    mrb_gc_unregister(self.mrb, self.value);
}

- (id)objectForKeyedSubscript:(id)key {
    mrb_value k = [key mrubyValue:self.mrb];
    mrb_value v = mrb_funcall_argv(self.mrb, self.value, mrb_intern_lit(self.mrb, "[]"), 1, &k);
    if (mrb_nil_p(v) || mrb_exception_p(v)) {
        self.mrb->exc = 0;
        return nil;
    }
    if (mrb_string_p(v)) {
        return [NSString stringWithUTF8String:mrb_str_to_cstr(self.mrb, v)];
    }
    if (mrb_symbol_p(v)) {
        return [NSString stringWithUTF8String:mrb_sym_name(self.mrb, mrb_symbol(v))];
    }
    if (mrb_fixnum_p(v)) {
        return [NSNumber numberWithLongLong:mrb_fixnum(v)];
    }
    if (mrb_float_p(v)) {
        return [NSNumber numberWithDouble:mrb_float(v)];
    }
    return [[MRBPin alloc] initWithValue:v by:self.mrb];
}

@end
