//
// Copyright (c) 2020 shibafu
//

#import "PostBox.h"
#import "PostBoxTextView.h"
#import "PostBoxLayoutManagerDelegatee.h"

@interface PostBox () <NSTextViewDelegate>

@property (unsafe_unretained) IBOutlet PostBoxTextView *tootInput;
@property (nonatomic, weak) IBOutlet NSTextField *flashMessageView;
@property (nonatomic, weak) IBOutlet NSButton *showSpoilerTextButton;
@property (nonatomic, weak) IBOutlet NSTextField *spoilerTextInput;
@property (weak) IBOutlet NSLayoutConstraint *topConstraintOfTootInput;

@property (nonatomic) PostBoxLayoutManagerDelegatee *layoutManagerDelegatee;
@property (nonatomic) MRBPin *commands;
@property (nonatomic) NSTimer *flashMessageTimer;
@property (nonatomic) NSArray<DONEmoji *> *customEmojiCache;
@property (nonatomic) AnyPromise *customEmojiPromise;

@end

@implementation PostBox

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _draft = [[PostBoxDraft alloc] init];
        _posting = NO;
        [self loadNib];
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
        
        self.layoutManagerDelegatee = [[PostBoxLayoutManagerDelegatee alloc] initWithTextView:self.tootInput];
        self.tootInput.font = [NSFont systemFontOfSize:NSFont.systemFontSize];
        self.tootInput.layoutManager.delegate = self.layoutManagerDelegatee;
        self.tootInput.textContainerInset = NSMakeSize(0, 4);
        self.tootInput.delegate = self;
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [NSColor.controlBackgroundColor setFill];
    NSRectFill(dirtyRect);
    
    switch (self.borderStyle) {
        case PostBoxBorderStyleRect: {
            NSBezierPath *border = [NSBezierPath bezierPathWithRect:self.bounds];
            [NSColor.separatorColor set];
            border.lineWidth = 1;
            [border stroke];
            break;
        }
        case PostBoxBorderStyleBottomLine: {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [NSColor.separatorColor set];
            [path moveToPoint:NSMakePoint(0, 0)];
            [path lineToPoint:NSMakePoint(self.bounds.size.width, 0)];
            path.lineWidth = 1;
            [path stroke];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - public

- (void)setDraft:(PostBoxDraft *)draft {
    _draft = draft;
    NSString *spoilerText = draft.spoilerText;
    if (spoilerText.length) {
        // setShowSpoilerText: で一度消しちゃうので (そっちを直したほうがいいんだけどねえ)
        self.showSpoilerText = YES;
        self.draft.spoilerText = spoilerText;
    } else {
        self.showSpoilerText = NO;
    }
}

- (void)clear {
    PostBoxDraft *newDraft = [[PostBoxDraft alloc] init];
    newDraft.visibility = self.draft.visibility;
    self.draft = newDraft;
}

- (void)attachPicture:(DONPicture *)picture {
    [self.draft insertObject:[[PostBoxAttachment alloc] initWithPicture:picture] inAttachmentsAtIndex:self.draft.attachments.count];
    [self flashMessage:@"画像を添付しました"];
}

- (void)focus {
    [self.window makeFirstResponder:self.tootInput];
}

- (void)setSelectedRange:(NSRange)charRange {
    self.tootInput.selectedRange = charRange;
}

- (void)setShowSpoilerText:(BOOL)showSpoilerText {
    _showSpoilerText = showSpoilerText;
    if (showSpoilerText) {
        self.draft.spoilerText = @"";
        self.showSpoilerTextButton.contentTintColor = NSColor.controlAccentColor;
        self.topConstraintOfTootInput.constant = 1 + self.spoilerTextInput.frame.size.height + 4;
    } else {
        self.showSpoilerTextButton.contentTintColor = NSColor.controlTextColor;
        self.topConstraintOfTootInput.constant = 1;
    }
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.25;
        context.allowsImplicitAnimation = YES;
        [self layoutSubtreeIfNeeded];
    }];
}

#pragma mark - private

- (IBAction)clickSend:(id)sender {
    if (!self.showSpoilerText) {
        self.draft.spoilerText = @"";
    }
    [self sendAction:self.action to:self.target];
}

- (IBAction)clickAttach:(id)sender {
    if (self.draft.attachments.count == 0) {
        [self attachImage:nil];
        return;
    }
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    [menu addItemWithTitle:@"画像を添付..." action:@selector(attachImage:) keyEquivalent:@""].target = self;
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *sensitiveItem = [[NSMenuItem alloc] initWithTitle:@"閲覧注意にする" action:@selector(toggleSensitive:) keyEquivalent:@""];
    sensitiveItem.state = self.draft.isSensitive ? NSControlStateValueOn : NSControlStateValueOff;
    sensitiveItem.target = self;
    [menu addItem:sensitiveItem];
    [self.draft.attachments enumerateObjectsUsingBlock:^(PostBoxAttachment * _Nonnull attachment, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *item = [menu addItemWithTitle:@"この画像を取り除く" action:@selector(removeAttachment:) keyEquivalent:@""];
        NSImage *image = [attachment thumbnail];
        
        item.target = self;
        item.image = [image resizeToScreenSize:NSMakeSize(64, 48)];
        item.representedObject = [NSNumber numberWithUnsignedInteger:idx];
    }];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"すべての添付画像を取り除く" action:@selector(removeAllAttachments:) keyEquivalent:@""].target = self;
    
    [menu popUpMenuPositioningItem:nil atLocation:((NSButton*)sender).frame.origin inView:self];
}

- (void)toggleSensitive:(NSMenuItem*)sender {
    self.draft.sensitive = !self.draft.isSensitive;
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
    
    [self.draft removeObjectFromAttachmentsAtIndex:index.unsignedIntegerValue];
    if (self.draft.attachments.count == 0) {
        self.draft.sensitive = NO;
    }
}

- (void)removeAllAttachments:(NSMenuItem*)sender {
    [self.draft removeAllAttachments];
    self.draft.sensitive = NO;
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
        mrb_value buffer_text = mrb_str_new_cstr(mrb, self.draft.message.UTF8String);
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
        if (![self.draft.message isEqualToString:changed]) {
            self.draft.message = changed;
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
    self.draft.visibility = DONStatusPublic;
}

- (IBAction)changeVisibilityToUnlisted:(id)sender {
    self.draft.visibility = DONStatusUnlisted;
}

- (IBAction)changeVisibilityToPrivate:(id)sender {
    self.draft.visibility = DONStatusPrivate;
}

- (IBAction)changeVisibilityToDirect:(id)sender {
    self.draft.visibility = DONStatusDirect;
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

#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertTab:)) {
        [self.window selectNextKeyView:nil];
        return YES;
    }
    return NO;
}

#pragma mark - PostBoxAutocompleteDelegate

- (void)autocomplete:(id<PostBoxAutocompletable>)autocompletable didRequestCandidatesForKeyword:(NSString *)keyword {
    if (keyword.length <= 1) {
        return;
    }
    NSLog(@"autocomplete:didRequestCandidatesForKeyword:%@", keyword);
    AnyPromise *promise = nil;
    switch ([keyword characterAtIndex:0]) {
        case '@': // account name
            promise = [self autocompleteDidRequestAccountCandidatesForKeyword:keyword];
            break;
        case '#': // hashtag
            promise = [self autocompleteDidRequestHashtagCandidatesForKeyword:keyword];
            break;
        case ':': // emoji shortcode
            promise = [self autocompleteDidRequestCustomEmojiCandidatesForKeyword:keyword];
            break;
    }
    if (promise) {
        __weak typeof(autocompletable) weakAutocompletable = autocompletable;
        promise.then(^(NSArray<NSString *> *candidates) {
            [weakAutocompletable setCandidates:candidates forKeyword:keyword];
        }).catch(^(NSError *error) {
            WriteAFNetworkingErrorToLog(error);
        });
    }
}

- (AnyPromise *)autocompleteDidRequestAccountCandidatesForKeyword:(NSString *)keyword {
    NSString *query = [keyword substringFromIndex:1];
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver _Nonnull resolver) {
        [App.client searchWithQuery:query
                    requiresResolve:NO
                         completion:^(NSURLSessionDataTask * _Nonnull task, DONMastodonSearchResults * _Nullable results, NSError * _Nullable error) {
            if (error) {
                resolver(error);
                return;
            }
            NSMutableArray<NSString *> *candidates = [NSMutableArray arrayWithCapacity:results.accounts.count];
            [results.accounts enumerateObjectsUsingBlock:^(DONMastodonAccount * _Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
                [candidates addObject:[@"@" stringByAppendingString:account.acct]];
            }];
            resolver(candidates);
        }];
    }];
}

- (AnyPromise *)autocompleteDidRequestHashtagCandidatesForKeyword:(NSString *)keyword {
    NSString *query = [keyword substringFromIndex:1];
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver _Nonnull resolver) {
        [App.client searchWithQuery:query
                    requiresResolve:NO
                         completion:^(NSURLSessionDataTask * _Nonnull task, DONMastodonSearchResults * _Nullable results, NSError * _Nullable error) {
            if (error) {
                resolver(error);
                return;
            }
            NSMutableArray<NSString *> *candidates = [NSMutableArray arrayWithCapacity:results.hashtags.count];
            [results.hashtags enumerateObjectsUsingBlock:^(DONMastodonTag * _Nonnull tag, NSUInteger idx, BOOL * _Nonnull stop) {
                [candidates addObject:[@"#" stringByAppendingString:tag.name]];
            }];
            resolver(candidates);
        }];
    }];
}

- (AnyPromise *)autocompleteDidRequestCustomEmojiCandidatesForKeyword:(NSString *)keyword {
    NSString *query = [keyword substringFromIndex:1];
    return [self customEmojis].thenInBackground(^(NSArray<DONEmoji *> *emojis) {
        NSMutableArray<DONEmoji *> *matches = [NSMutableArray array];
        NSMutableDictionary<NSString *, NSNumber *> *scores = [NSMutableDictionary dictionary];
        [emojis enumerateObjectsUsingBlock:^(DONEmoji * _Nonnull emoji, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [emoji.shortcode rangeOfString:query];
            if (range.location != NSNotFound) {
                NSUInteger score = range.location + (query.length - range.length);
                [matches addObject:emoji];
                scores[emoji.shortcode] = @(score);
            }
        }];
        
        [matches sortUsingComparator:^NSComparisonResult(DONEmoji * _Nonnull lsh, DONEmoji * _Nonnull rsh) {
            NSUInteger lscore = scores[lsh.shortcode].unsignedIntegerValue;
            NSUInteger rscore = scores[rsh.shortcode].unsignedIntegerValue;
            if (lscore == rscore) {
                return [lsh.shortcode compare:rsh.shortcode];
            } else {
                return lscore - rscore;
            }
        }];
        
        NSMutableArray<NSString *> *candidates = [NSMutableArray arrayWithCapacity:matches.count];
        [matches enumerateObjectsUsingBlock:^(DONEmoji * _Nonnull emoji, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([emoji.shortcode containsString:query]) {
                [candidates addObject:[NSString stringWithFormat:@":%@:", emoji.shortcode]];
            }
        }];
        return candidates;
    });
}

- (AnyPromise *)customEmojis {
    NSArray<DONEmoji *> *cache = self.customEmojiCache;
    if (cache) {
        return [AnyPromise promiseWithValue:cache];
    }
    
    AnyPromise *previousPromise = self.customEmojiPromise;
    if (previousPromise) {
        return previousPromise;
    }
    
    __weak typeof(self) weakSelf = self;
    AnyPromise *promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver _Nonnull resolver) {
        [App.client customEmojisWithCompletion:^(NSURLSessionDataTask * _Nonnull task, NSArray<DONEmoji *> * _Nullable results, NSError * _Nullable error) {
            if (error) {
                resolver(error);
                return;
            }
            resolver(results);
        }];
    }].then(^(NSArray<DONEmoji *> *results) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.customEmojiPromise = nil;
            strongSelf.customEmojiCache = results;
        }
        return results;
    });
    self.customEmojiPromise = promise;
    return promise;
}

@end
