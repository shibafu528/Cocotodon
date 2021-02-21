#import "mrb_setting_dsl.h"
#import "MRBSettingFileSelect.h"

#define VIEW ((__bridge NSStackView*) mrb_cptr(mrb_iv_get(mrb, self, mrb_intern_lit(mrb, "view"))))

void mrb_cf_release(mrb_state *mrb, void *ref) {
    CFRelease(ref);
}

static const struct mrb_data_type mrb_setting_dsl_type = { "SettingDSL", mrb_cf_release };

@interface SettingDSLCallback : NSObject

@property (nonatomic, weak) NSWindow *window;

@end

@implementation SettingDSLCallback

- (instancetype)initWithWindow:(NSWindow *)window {
    if (self = [super init]) {
        _window = window;
    }
    return self;
}

- (void)beginFileSelection:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = NO;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            mrb_sym config = (mrb_sym)((NSControl*) sender).tag;
            NSLog(@"Config: %s", mrb_sym2name(App.mrb, config));
            NSLog(@"File: %@", panel.URL.path);
        }
    }];
}

@end

static mrb_value setting_dsl_init(mrb_state *mrb, mrb_value self) {
    mrb_value view_pointer = mrb_get_arg1(mrb);
    mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "view"), view_pointer);
    
    DATA_TYPE(self) = &mrb_setting_dsl_type;
    DATA_PTR(self) = (__bridge_retained void*) [[SettingDSLCallback alloc] initWithWindow:VIEW.window];
    
    return self;
}

static mrb_value setting_dsl_stub(mrb_state *mrb, mrb_value self) {
    mrb_value *argv;
    mrb_int argc;
    mrb_get_args(mrb, "*", &argv, &argc);
    
    NSMutableString *sig = [NSMutableString string];
    for (int i = 0; i < argc; i++) {
        if (i != 0) {
            [sig appendString:@", "];
        }
        [sig appendString:[NSString stringWithUTF8String:mrb_str_to_cstr(mrb, mrb_obj_as_string(mrb, argv[i]))]];
    }
    
    NSTextField *label = [NSTextField wrappingLabelWithString:sig];
    [VIEW addArrangedSubview:label];
    
    return mrb_nil_value();
}

static mrb_value setting_dsl_settings(mrb_state *mrb, mrb_value self) {
    const char *title;
    mrb_value block;
    mrb_get_args(mrb, "z&!", &title, &block);
    
    NSBox *box = [[NSBox alloc] init];
    box.translatesAutoresizingMaskIntoConstraints = NO;
    box.title = [NSString stringWithUTF8String:title];
    [VIEW addArrangedSubview:box];
    [NSLayoutConstraint activateConstraints:@[
        [box.leadingAnchor constraintEqualToAnchor:VIEW.leadingAnchor constant:4],
        [box.trailingAnchor constraintEqualToAnchor:VIEW.trailingAnchor constant:4]
    ]];
   
    NSStackView *stackView = [[NSStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.orientation = VIEW.orientation;
    stackView.alignment = VIEW.alignment;
    stackView.distribution = VIEW.distribution;
    stackView.spacing = VIEW.spacing;
    stackView.edgeInsets = NSEdgeInsetsMake(4, 4, 4, 4);
    [box.contentView addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leadingAnchor constraintEqualToAnchor:box.contentView.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:box.contentView.trailingAnchor],
        [stackView.topAnchor constraintEqualToAnchor:box.contentView.topAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:box.contentView.bottomAnchor]
    ]];
    
    mrb_value inner = mrb_setting_dsl_new(mrb, stackView);
    mrb_funcall_with_block(mrb, inner, mrb_intern_lit(mrb, "instance_eval"), 0, NULL, block);
    
    return mrb_nil_value();
}

static mrb_value setting_dsl_input(mrb_state *mrb, mrb_value self) {
    const char *label;
    mrb_sym config;
    mrb_get_args(mrb, "zn", &label, &config);
    
    NSStackView *stackView = [[NSStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stackView.alignment = NSLayoutAttributeCenterY;
    stackView.distribution = NSStackViewDistributionFillEqually;
    [VIEW addArrangedSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leadingAnchor constraintEqualToAnchor:VIEW.leadingAnchor constant:4],
        [stackView.trailingAnchor constraintEqualToAnchor:VIEW.trailingAnchor constant:4]
    ]];
    
    NSTextField *labelView = [NSTextField labelWithString:[NSString stringWithUTF8String:label]];
    [stackView addArrangedSubview:labelView];
    
    NSTextField *input = [NSTextField textFieldWithString:@""];
    [stackView addArrangedSubview:input];
    
    return mrb_nil_value();
}

static mrb_value setting_dsl_fileselect(mrb_state *mrb, mrb_value self) {
    const char *label;
    mrb_sym config;
    const char *current;
    mrb_bool current_given_p = false;
    mrb_get_args(mrb, "zn|z?", &label, &config, &current, &current_given_p);
    
    MRBSettingFileSelect *fileselect = [[MRBSettingFileSelect alloc] initWithFrame:VIEW.frame config:config];
    fileselect.label = [NSString stringWithUTF8String:label];
    if (current_given_p) {
        fileselect.cwd = [NSString stringWithUTF8String:current];
    }
    fileselect.translatesAutoresizingMaskIntoConstraints = NO;
    [VIEW addArrangedSubview:fileselect];
    [NSLayoutConstraint activateConstraints:@[
        [fileselect.leadingAnchor constraintEqualToAnchor:VIEW.leadingAnchor constant:4],
        [fileselect.trailingAnchor constraintEqualToAnchor:VIEW.trailingAnchor constant:4]
    ]];
    
    return mrb_nil_value();
}

void mrb_setting_dsl_init(mrb_state *mrb) {
    int ai = mrb_gc_arena_save(mrb);
    
    struct RClass *cocotodon = mrb_define_module(mrb, "Cocotodon");
    struct RClass *setting_dsl = mrb_define_class_under(mrb, cocotodon, "SettingDSL", mrb->object_class);
    MRB_SET_INSTANCE_TT(setting_dsl, MRB_TT_DATA);
    
    mrb_define_method(mrb, setting_dsl, "initialize", setting_dsl_init, MRB_ARGS_REQ(1));
    mrb_define_method(mrb, setting_dsl, "multitext", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "adjustment", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "boolean", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "fileselect", setting_dsl_fileselect, MRB_ARGS_ARG(2, 1));
    mrb_define_method(mrb, setting_dsl, "photoselect", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "dirselect", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "input", setting_dsl_input, MRB_ARGS_REQ(2));
    mrb_define_method(mrb, setting_dsl, "inputpass", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "multi", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "settings", setting_dsl_settings, MRB_ARGS_REQ(1) | MRB_ARGS_BLOCK());
    mrb_define_method(mrb, setting_dsl, "about", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "font", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "color", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "fontcolor", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "listview", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "select", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "multiselect", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "keybind", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "label", setting_dsl_stub, MRB_ARGS_ANY());
    mrb_define_method(mrb, setting_dsl, "link", setting_dsl_stub, MRB_ARGS_ANY());
    
    mrb_gc_arena_restore(mrb, ai);
}

mrb_value mrb_setting_dsl_new(mrb_state *mrb, NSStackView *view) {
    struct RClass *cocotodon = mrb_module_get(mrb, "Cocotodon");
    struct RClass *setting_dsl = mrb_class_get_under(mrb, cocotodon, "SettingDSL");
    
    mrb_value ptr = mrb_cptr_value(mrb, (__bridge void*) view);
    return mrb_obj_new(mrb, setting_dsl, 1, &ptr);
}
