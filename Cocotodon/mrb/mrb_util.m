//
// Copyright (c) 2020 shibafu
//

#import "mrb_util.h"
#import <mruby/array.h>
#import <mruby/hash.h>
#import <mruby/error.h>

static mrb_value mrb_protect_handler(mrb_state *mrb, mrb_value p) {
    mrb_protect_body body = (__bridge mrb_protect_body) mrb_cptr(p);
    return body(mrb);
}

mrb_value mrb_protect_with_block(mrb_state *mrb, mrb_protect_body body, mrb_bool *state) {
    return mrb_protect(mrb, mrb_protect_handler, mrb_cptr_value(mrb, (__bridge void*) body), state);
}

NSString *exc2str(mrb_state *mrb, mrb_value exc) {
    NSMutableString *bt = [NSMutableString string];
    [bt appendString:[NSString stringWithUTF8String:mrb_str_to_cstr(mrb, mrb_inspect(mrb, exc))]];
    [bt appendString:@"\n"];
    [bt appendString:[NSString stringWithUTF8String:mrb_str_to_cstr(mrb, mrb_ary_join(mrb,
                                                                                      mrb_exc_backtrace(mrb, exc),
                                                                                      mrb_str_new_lit(mrb, "\n")))]];
    return bt;
}

void exc2log(mrb_state *mrb) {
    if (mrb->exc) {
        mrb_value exc = mrb_obj_value(mrb->exc);
        NSLog(@"Exception: %@", exc2str(mrb, exc));
    }
}

int hash_each_and_put_to_dict(mrb_state *mrb, mrb_value key, mrb_value value, void *data) {
    __auto_type *dict = (__bridge NSMutableDictionary *) data;
    dict[ObjectFromMRubyValue(mrb, key)] = ObjectFromMRubyValue(mrb, value);
    return 0;
}

id ObjectFromMRubyValue(mrb_state *mrb, mrb_value value) {
    if (mrb_nil_p(value)) {
        return nil;
    }
    if (mrb_true_p(value)) {
        return [NSNumber numberWithBool:YES];
    }
    if (mrb_false_p(value)) {
        return [NSNumber numberWithBool:NO];
    }
    if (mrb_string_p(value)) {
        return [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, value)];
    }
    if (mrb_symbol_p(value)) {
        return [NSString stringWithUTF8String:mrb_sym2name(mrb, mrb_symbol(value))];
    }
    if (mrb_fixnum_p(value)) {
#ifdef MRB_INT64
        return [NSNumber numberWithLongLong:mrb_fixnum(value)];
#else
        return [NSNumber numberWithInt:mrb_fixnum(value)];
#endif
    }
    if (mrb_array_p(value)) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:RARRAY_LEN(value)];
        for (int i = 0; i < RARRAY_LEN(value); i++) {
            arr[i] = ObjectFromMRubyValue(mrb, mrb_ary_entry(value, i));
        }
        return arr;
    }
    if (mrb_hash_p(value)) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:mrb_hash_size(mrb, value)];
        mrb_hash_foreach(mrb, RHASH(value), hash_each_and_put_to_dict, (__bridge void*) dict);
        return dict;
    }
    if (mrb_proc_p(value)) {
        return [[MRBPin alloc] initWithValue:value by:mrb];
    }
    return [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, mrb_obj_as_string(mrb, value))];
}

@implementation NSObject (MRubyConverter)

- (mrb_value) mrubyValue:(mrb_state *)mrb {
    return mrb_str_new_cstr(mrb, [NSString stringWithFormat:@"<#%@: %p>", self.className, self].UTF8String);
}

@end

@implementation NSString (MRubyConverter)

- (mrb_value) mrubyValue:(mrb_state *)mrb {
    return mrb_str_new_cstr(mrb, self.UTF8String);
}

@end

@implementation NSNumber (MRubyConverter)

- (mrb_value) mrubyValue:(mrb_state *)mrb {
    const char *type = self.objCType;
    if (strcmp(type, @encode(BOOL)) == 0) {
        return mrb_bool_value(self.boolValue);
    } else if (strcmp(type, @encode(float)) == 0 || strcmp(type, @encode(double)) == 0) {
        return mrb_float_value(mrb, self.doubleValue);
    } else {
#ifdef MRB_INT64
        return mrb_fixnum_value(self.longLongValue);
#else
        return mrb_fixnum_value(self.intValue);
#endif
    }
}

@end

@implementation NSArray (MRubyConverter)

- (mrb_value) mrubyValue:(mrb_state *)mrb {
    mrb_value arr = mrb_ary_new_capa(mrb, self.count);
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        mrb_ary_push(mrb, arr, [obj mrubyValue:mrb]);
    }];
    return arr;
}

@end

@implementation NSDictionary (MRubyConverter)

- (mrb_value) mrubyValue:(mrb_state *)mrb {
    mrb_value hash = mrb_hash_new_capa(mrb, self.count);
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        mrb_hash_set(mrb, hash, [key mrubyValue:mrb], [obj mrubyValue:mrb]);
    }];
    return hash;
}

@end
