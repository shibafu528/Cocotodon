//
// Copyright (c) 2021 shibafu
//

#import "mrb_event_wrapper.h"

static mrb_value cct_mix_status_as_message(mrb_state *mrb, DONStatus * _Nonnull status) {
    int ai = mrb_gc_arena_save(mrb);
    mrb_value hash_status = [status mrubyValue:mrb];
    hash_status = mrb_funcall_argv(mrb, hash_status, mrb_intern_lit(mrb, "symbolize"), 0, NULL);
    struct RClass *cocototon_message = mix_class_get(mrb, "Cocotodon", "Message");
    mrb_value message = mrb_obj_new(mrb, cocototon_message, 1, &hash_status);
    mrb_gc_arena_restore(mrb, ai);
    mrb_gc_protect(mrb, message);
    return message;
}

void cct_mix_call_posted(DONStatus *status) {
    mrb_gc_arena_save_with_block(App.mrb, ^mrb_value(mrb_state * _Nonnull mrb, int arenaIndex) {
        mrb_bool state;
        mrb_value ret = mrb_protect_with_block(mrb, ^mrb_value(mrb_state * _Nonnull mrb) {
            mrb_value message = cct_mix_status_as_message(mrb, status);
            mrb_value args[] = {App.world.value, mrb_ary_new_from_values(mrb, 1, &message)};
            mix_plugin_call_argv(mrb, "posted", 2, args);
            return mrb_nil_value();
        }, &state);
        if (state) {
            NSLog(@"Exception: %@", exc2str(mrb, ret));
        }
        return mrb_nil_value();
    });
}
