//
// Copyright (c) 2020 shibafu
//

#import "PostBox.h"

@interface PostBox () <NSTextViewDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *tootInput;
@property (nonatomic, weak) IBOutlet NSTextField *counter;
@property (nonatomic, weak) IBOutlet NSButton *sendButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *visibilityPopUp;
@property (nonatomic, weak) IBOutlet NSTextField *flashMessageView;

@property (nonatomic, readwrite, getter=isSensitive) BOOL sensitive;
@property (nonatomic) NSMutableArray<DONPicture*> *attachedPictures;
@property (nonatomic) MRBPin *commands;
@property (nonatomic) NSTimer *flashMessageTimer;

@end

@implementation PostBox

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self loadNib];
        _attachedPictures = [NSMutableArray array];
    }
    return self;
}

- (void)loadNib {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"PostBox" bundle:[NSBundle mainBundle]];
    if (nib) {
        NSArray *objs;
        [nib instantiateWithOwner:self topLevelObjects:&objs];
        
        __block NSView *view = nil;
        [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSView.class]) {
                view = obj;
                *stop = YES;
            }
        }];
        NSAssert(view, @"NSView not found!");
        [self addSubview:view];
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [view.topAnchor constraintEqualToAnchor:self.topAnchor],
            [view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        self.tootInput.textContainerInset = NSMakeSize(0, 4);
    }
}

#pragma mark - public

- (NSString *)message {
    return self.tootInput.string;
}

- (void)setMessage:(NSString *)message {
    self.tootInput.string = message;
    [self updateContentCounter];
    [self updateSendEnabledState];
}

- (DONStatusVisibility)visibility {
    return self.visibilityPopUp.indexOfSelectedItem;
}

- (void)setVisibility:(DONStatusVisibility)visibility {
    [self.visibilityPopUp selectItemAtIndex:visibility];
}

- (void)clear {
    self.tootInput.string = @"";
    self.sendButton.enabled = NO;
    self.sensitive = NO;
    [self.attachedPictures removeAllObjects];
    [self updateContentCounter];
}

- (NSArray<DONPicture *> *)pictures {
    return self.attachedPictures;
}

- (void)attachPicture:(DONPicture *)picture {
    [self.attachedPictures addObject:picture];
    [self updateSendEnabledState];
    [self flashMessage:@"画像を添付しました"];
}

- (void)focus {
    [self.window makeFirstResponder:self.tootInput];
}

- (void)setSelectedRange:(NSRange)charRange {
    self.tootInput.selectedRange = charRange;
}

#pragma mark - private

- (void)updateContentCounter {
    NSUInteger count = self.tootInput.string.characterCount;
    if (count <= 500) {
        self.counter.stringValue = @(500 - count).stringValue;
    } else {
        self.counter.stringValue = [NSString stringWithFormat:@"-%lu", count - 500];
    }
}

- (void)updateSendEnabledState {
    self.sendButton.enabled = self.tootInput.string.characterCount != 0 || self.attachedPictures.count != 0;
}

- (void)textDidChange:(NSNotification *)notification {
    [self updateContentCounter];
    [self updateSendEnabledState];
}

- (IBAction)clickSend:(id)sender {
    [self sendAction:self.action to:self.target];
}

- (IBAction)clickAttach:(id)sender {
    if (self.attachedPictures.count == 0) {
        [self attachImage:nil];
        return;
    }
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    [menu addItemWithTitle:@"画像を添付..." action:@selector(attachImage:) keyEquivalent:@""].target = self;
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *sensitiveItem = [[NSMenuItem alloc] initWithTitle:@"閲覧注意にする" action:@selector(toggleSensitive:) keyEquivalent:@""];
    sensitiveItem.state = self.sensitive ? NSControlStateValueOn : NSControlStateValueOff;
    sensitiveItem.target = self;
    [menu addItem:sensitiveItem];
    [self.attachedPictures enumerateObjectsUsingBlock:^(DONPicture * _Nonnull picture, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *item = [menu addItemWithTitle:@"この画像を取り除く" action:@selector(removeAttachment:) keyEquivalent:@""];
        NSImage *image = [[NSImage alloc] initWithData:picture.data];
        
        item.target = self;
        item.image = [image resizeToScreenSize:NSMakeSize(64, 48)];
        item.representedObject = [NSNumber numberWithUnsignedInteger:idx];
    }];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"すべての添付画像を取り除く" action:@selector(removeAllAttachments:) keyEquivalent:@""].target = self;
    
    [menu popUpMenuPositioningItem:nil atLocation:((NSButton*)sender).frame.origin inView:self];
}

- (void)toggleSensitive:(NSMenuItem*)sender {
    self.sensitive = !self.isSensitive;
}

- (void)attachImage:(NSMenuItem*)sender {
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.canChooseFiles = YES;
    open.canChooseDirectories = NO;
    open.allowsMultipleSelection = YES;
    open.allowedFileTypes = @[@"public.image"];
    [open beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK) {
            return;
        }
        
        [open.URLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
            NSError *error;
            NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
            if (error) {
                NSLog(@"attach error: %@", error.localizedDescription);
                *stop = YES;
                return;
            }
            
            NSString *extension = (url.pathExtension ?: @"").lowercaseString;
            DONPictureFormat format = [extension isEqualToString:@"png"] ? DONPicturePNG : DONPictureJPEG;
            DONPicture *picture = [[DONPicture alloc] initWithData:data format:format];
            [self attachPicture:picture];
        }];
    }];
}

- (void)removeAttachment:(NSMenuItem*)sender {
    NSNumber *index = (NSNumber*) sender.representedObject;
    if (!index) {
        return;
    }
    
    [self.attachedPictures removeObjectAtIndex:index.unsignedIntegerValue];
    if (self.attachedPictures.count == 0) {
        self.sensitive = NO;
    }
    [self updateSendEnabledState];
}

- (void)removeAllAttachments:(NSMenuItem*)sender {
    [self.attachedPictures removeAllObjects];
    self.sensitive = NO;
    [self updateSendEnabledState];
}

- (IBAction)openPostboxMenu:(id)sender {
    NSMenu *menu = [[NSMenu alloc] init];
    
    mrb_state *mrb = App.mrb;
    int ai = mrb_gc_arena_save(mrb);
    mrb_value commands = mix_plugin_filtering_arg1(mrb, "command", mrb_hash_new(mrb));
    if (mrb->exc) {
        [menu addItemWithTitle:@"mruby error" action:nil keyEquivalent:@""];
        exc2log(mrb);
        mrb->exc = 0;
        mrb_gc_arena_restore(mrb, ai);
        return;
    }
    
    mrb_value messages = mrb_ary_new(mrb);
    mrb_value world = App.world.value;
    mrb_value opt = mix_gui_event_new(mrb, "contextmenu", mrb_nil_value(), messages, world);
    
    [self enumerateMikuCommands:commands roleOf:@"postbox" options:opt usingBlock:^(mrb_value hash, NSString * _Nonnull slug, NSString * _Nonnull name) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:name
                                                      action:@selector(performPostboxCommand:)
                                               keyEquivalent:@""];
        item.target = self;
        item.representedObject = slug;
        [menu addItem:item];
    }];
    
    mrb_gc_arena_restore(mrb, ai);
    mrb_gc_register(mrb, commands);
    self.commands = [[MRBPin alloc] initWithValue:commands by:mrb];
    
    [menu popUpMenuPositioningItem:nil atLocation:((NSButton*)sender).frame.origin inView:self];
}

- (void)performPostboxCommand:(NSMenuItem*)sender {
    NSString *slug = sender.representedObject;
    if (slug == nil) {
        return;
    }
    
    NSLog(@"performTimelineCommand: %@", slug);
    
    mrb_state *mrb = App.mrb;
    int ai = mrb_gc_arena_save(mrb);
    mrb_sym sym_slug = mrb_intern_cstr(mrb, [slug UTF8String]);
    mrb_value command = mrb_hash_get(mrb, self.commands.value, mrb_symbol_value(sym_slug));
    if (mrb_nil_p(command)) {
        NSLog(@"command not found");
        mrb_gc_arena_restore(mrb, ai);
        return;
    }
    
    mrb_value exec = mrb_hash_get(mrb, command, mrb_symbol_value(mrb_intern_lit(mrb, "exec")));
    if (!mrb_proc_p(exec)) {
        NSLog(@"command[:exec] is not Proc");
        mrb_gc_arena_restore(mrb, ai);
        return;
    }
    
    MRBProc *ephemeral = [[MRBProc alloc] initWithBlock:^mrb_value(mrb_state * _Nonnull mrb) {
        // この辺は正直mruby側に書いたほうが楽。eventとして書くのが一番Pluggaloidらしいやり方。
        // しかし、ホスト側で書いたほうがPostboxの変更とかのハンドリングがやりやすいかもしれない。
        mrb_value main_gui_sym = mrb_symbol_value(mrb_intern_lit(mrb, "main"));
        struct RClass *cls_gui_postbox = mix_class_get(mrb, "Plugin", "GUI", "Postbox");
        mrb_value postbox = mrb_funcall_argv(mrb, mrb_obj_value(cls_gui_postbox), mrb_intern_lit(mrb, "instance"), 1, &main_gui_sym);
        
        // polyfill-gtkのオブジェクト生成待ち
        mix_run(mrb);
        
        mrb_value gtk = mix_plugin_get(mrb, "gtk");
        mrb_value gtk_postbox = mrb_funcall_argv(mrb, gtk, mrb_intern_lit(mrb, "widgetof"), 1, &postbox);
        mrb_value widget_post = mrb_funcall_argv(mrb, gtk_postbox, mrb_intern_lit(mrb, "widget_post"), 0, NULL);
        mrb_value post_buffer = mrb_funcall_argv(mrb, widget_post, mrb_intern_lit(mrb, "buffer"), 0, NULL);
        mrb_value buffer_text = mrb_str_new_cstr(mrb, self.tootInput.string.UTF8String);
        mrb_value cursor_position = mrb_fixnum_value(self.tootInput.selectedRange.location);
        mrb_funcall_argv(mrb, post_buffer, mrb_intern_lit(mrb, "text="), 1, &buffer_text);
        mrb_funcall_argv(mrb, post_buffer, mrb_intern_lit(mrb, "cursor_position="), 1, &cursor_position);
        
        mrb_value messages = mrb_ary_new(mrb);
        mrb_value world = App.world.value;
        mrb_value opt = mix_gui_event_new(mrb, "contextmenu", postbox, messages, world);
        mrb_value response = mrb_funcall_argv(mrb, exec, mrb_intern_lit(mrb, "call"), 1, &opt);
        
        // 戻り値がDelayer::Deferredだったら、エラーハンドラを仕掛ける
        if (mrb_respond_to(mrb, response, mrb_intern_lit(mrb, "trap"))) {
            mrb_value error_sym = mrb_symbol_value(mrb_intern_lit(mrb, "error"));
            mrb_value error_method = mrb_funcall_argv(mrb, mrb_obj_value(mrb->kernel_module), mrb_intern_lit(mrb, "method"), 1, &error_sym);
            response = mrb_funcall_with_block(mrb, response, mrb_intern_lit(mrb, "trap"), 0, NULL, error_method);
        }
        
        buffer_text = mrb_funcall_argv(mrb, post_buffer, mrb_intern_lit(mrb, "text"), 0, NULL);
        NSString *changed = [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, buffer_text)];
        if (![self.tootInput.string isEqualToString:changed]) {
            self.tootInput.string = changed;
            [self updateContentCounter];
            [self updateSendEnabledState];
        }
        
        return response;
    } by:mrb];
    struct RClass *cls_gui_ephemeral_session = mix_class_get(mrb, "Plugin", "GUI", "EphemeralSession");
    mrb_funcall_with_block(mrb, mrb_obj_value(cls_gui_ephemeral_session), mrb_intern_lit(mrb, "begin"), 0, NULL, ephemeral.value);
    if (mrb->exc) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleWarning;
        alert.messageText = @"プラグインコマンドの実行中にエラーが発生しました。";
        alert.informativeText = exc2str(mrb, mrb_obj_value(mrb->exc));
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        
        exc2log(mrb);
        mrb->exc = 0;
    }
    mrb_gc_arena_restore(mrb, ai);
}

- (void)enumerateMikuCommands:(mrb_value)commands roleOf:(NSString *)role options:(mrb_value)opt
                   usingBlock:(nonnull void (^)(mrb_value hash, NSString * _Nonnull slug, NSString * _Nonnull name))block {
    mrb_state *mrb = App.mrb;
    int ai = mrb_gc_arena_save(mrb);
    mrb_value arr_commands = mrb_hash_values(mrb, commands);
    mrb_sym role_sym = mrb_intern_cstr(mrb, role.UTF8String);
    for (int i = 0; i < RARRAY_LEN(arr_commands); i++) {
        mrb_value command = mrb_ary_entry(arr_commands, i);
        mrb_value role = mrb_hash_get(mrb, command, mrb_symbol_value(mrb_intern_lit(mrb, "role")));
        if (mrb_obj_to_sym(mrb, role) != role_sym) {
            continue;
        }
        
        mrb_value slug = mrb_hash_get(mrb, command, mrb_symbol_value(mrb_intern_lit(mrb, "slug")));
        NSString *slug_string = [NSString stringWithUTF8String:mrb_sym2name(mrb, mrb_symbol(slug))];
        
        // command[:name] はcallに応答するオブジェクトであればoptを引数にして評価する必要がある
        mrb_value name = mrb_hash_get(mrb, command, mrb_symbol_value(mrb_intern_lit(mrb, "name")));
        NSString *name_string;
        if (mrb_respond_to(mrb, name, mrb_intern_lit(mrb, "call"))) {
            mrb_value respond_name = mrb_funcall_argv(mrb, name, mrb_intern_lit(mrb, "call"), 1, &opt);
            if (mrb->exc) {
                exc2log(mrb);
                NSString *ins = [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, mrb_inspect(mrb, mrb_obj_value(mrb->exc)))];
                name_string = [NSString stringWithFormat:@"%@ [mruby error: %@]", slug_string, ins];
                mrb->exc = 0;
            } else {
                name_string = [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, respond_name)];
            }
        } else {
            name_string = [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, name)];
        }
        
        block(command, slug_string, name_string);
    }
    mrb_gc_arena_restore(mrb, ai);
}

- (IBAction)tootMessage:(id)sender {
}

- (IBAction)changeVisibilityToPublic:(id)sender {
    [self.visibilityPopUp selectItemAtIndex:DONStatusPublic];
}

- (IBAction)changeVisibilityToUnlisted:(id)sender {
    [self.visibilityPopUp selectItemAtIndex:DONStatusUnlisted];
}

- (IBAction)changeVisibilityToPrivate:(id)sender {
    [self.visibilityPopUp selectItemAtIndex:DONStatusPrivate];
}

- (IBAction)changeVisibilityToDirect:(id)sender {
    [self.visibilityPopUp selectItemAtIndex:DONStatusDirect];
}

- (void)flashMessage:(NSString*)message {
    self.flashMessageView.stringValue = message;
    self.flashMessageView.hidden = NO;
    
    if (self.flashMessageTimer) {
        [self.flashMessageTimer invalidate];
    }
    self.flashMessageTimer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.3;
            self.flashMessageView.animator.alphaValue = 0;
        } completionHandler:^{
            self.flashMessageView.hidden = YES;
            self.flashMessageView.alphaValue = 1;
        }];
        self.flashMessageTimer = nil;
    }];
}

@end
