//
// Copyright (c) 2020 shibafu
//

#import "AppDelegate.h"
#import "ReplyViewController.h"
#import "IntentManager.h"
#import "mrb_setting_dsl.h"
#import <UserNotifications/UserNotifications.h>

/// 認証情報を ~/.cocotodon.json から読み込む。何かおかしかったらその場でAppを終了する。
///
/// TODO: まともなアカウント管理を付ける
static void fetch_credential(NSString **host, NSString **accessToken) {
    NSError *error;
    NSURL *credfile = [NSFileManager.defaultManager.homeDirectoryForCurrentUser URLByAppendingPathComponent:@".cocotodon.json"];
    NSData *data = [NSData dataWithContentsOfURL:credfile options:0 error:&error];
    if (error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        [NSApp terminate:nil];
    }
    NSDictionary *cred = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
        [NSApp terminate:nil];
    }
    
    *host = cred[@"host"];
    *accessToken = cred[@"accessToken"];
    
    if ([*host length] == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleCritical;
        alert.messageText = @"~/.cocotodon.json に \"host\" が書き込まれていません。";
        [alert runModal];
        [NSApp terminate:nil];
    }
    if ([*accessToken length] == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleCritical;
        alert.messageText = @"~/.cocotodon.json に \"accessToken\" が書き込まれていません。";
        [alert runModal];
        [NSApp terminate:nil];
    }
}

static mrb_value mix_run_f(mrb_state *mrb, mrb_value self) {
    mix_run(mrb);
    return mrb_nil_value();
}

static void mrb_log_handler(const char* msg) {
    // 長すぎると出力できんかった
    //NSLog(@"[MRB] %@", [NSString stringWithUTF8String:msg]);
    printf("[MRB] %s\n", msg);
}

static void mrb_remain_handler(mrb_state *mrb) {
    NSLog(@"[MRB] Callbacked remain_handler");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[MRB] mix_run!");
        
        int ai = mrb_gc_arena_save(mrb);
        mrb_bool state = 0;
        mrb_value result = mrb_protect(mrb, mix_run_f, mrb_nil_value(), &state);
        if (state) {
            NSLog(@"Exception: %@", exc2str(mrb, result));
        }
        mrb_gc_arena_restore(mrb, ai);
    });
}

static void mrb_reserve_handler(mrb_state *mrb, mrb_float delay) {
    NSLog(@"[MRB] Callbacked reserve_handler");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[MRB] mix_run!");
        
        int ai = mrb_gc_arena_save(mrb);
        mrb_bool state = 0;
        mrb_value result = mrb_protect(mrb, mix_run_f, mrb_nil_value(), &state);
        if (state) {
            NSLog(@"Exception: %@", exc2str(mrb, result));
        }
        mrb_gc_arena_restore(mrb, ai);
    });
}

static mrb_value gui_handler_callback(mrb_state *mrb, mrb_value self) {
    mrb_value obj = mrb_get_arg1(mrb);
    mrb_value name = mrb_funcall_argv(mrb, obj, mrb_intern_lit(mrb, "name"), 0, NULL);
    mrb_value event_name = mix_plugin_event_env(mrb, MIX_EVENT_ENV_NAME);
    NSLog(@"[MRB] gui_handler: %@ %@",
          [NSString stringWithUTF8String:mrb_sym_name(mrb, mrb_symbol(event_name))],
          [NSString stringWithUTF8String:mrb_sym_name(mrb, mrb_obj_to_sym(mrb, name))]);
    return mrb_nil_value();
}

static mrb_value postbox_created_callback(mrb_state *mrb, mrb_value self) {
    mrb_value postbox = mrb_get_arg1(mrb);
    mrb_value name = mrb_funcall_argv(mrb, postbox, mrb_intern_lit(mrb, "name"), 0, NULL);
    if (mrb_obj_to_sym(mrb, name) == mrb_intern_lit(mrb, "main")) {
        return mrb_nil_value();
    }
    mrb_value options = mrb_funcall_argv(mrb, postbox, mrb_intern_lit(mrb, "options"), 0, NULL);
    printf("%s\n", mrb_str_to_cstr(mrb, mrb_inspect(mrb, options)));
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *wc = [storyboard instantiateControllerWithIdentifier:@"replyWindow"];
    ReplyViewController *vc = (ReplyViewController*)wc.contentViewController;
    
    mrb_value header_value = mrb_hash_get(mrb, options, mrb_symbol_value(mrb_intern_lit(mrb, "header")));
    NSString *header = nil;
    if (mrb_string_p(header_value) && RSTRING_LEN(header_value) > 0) {
        header = [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, header_value)];
    }
    
    mrb_value footer_value = mrb_hash_get(mrb, options, mrb_symbol_value(mrb_intern_lit(mrb, "footer")));
    NSString *footer = nil;
    if (mrb_string_p(footer_value) && RSTRING_LEN(footer_value) > 0) {
        footer = [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, footer_value)];
    }
    
    mrb_value to = mrb_hash_get(mrb, options, mrb_symbol_value(mrb_intern_lit(mrb, "to")));
    if (mrb_nil_p(to)) {
        [vc setHeader:header andFooter:footer];
    } else {
        const char *script =
        "recurse_to_hash = ->(model) do \n"
        "  h = model.to_hash \n"
        "  h.each do |k, v| \n"
        "    if v.is_a?(Diva::Model) \n"
        "      h[k] = recurse_to_hash.(v) \n"
        "    end \n"
        "  end \n"
        "  h \n"
        "end";
        mrb_value lambda = mrb_load_string(mrb, script);
        mrb_value hash = mrb_funcall_argv(mrb, lambda, mrb_intern_lit(mrb, "call"), 1, &to); // TODO: ほんとはto_hashとかto_jsonあたりで手を打ちたい
        NSDictionary<NSString *, id> *dict = ObjectFromMRubyValue(mrb, hash);
        NSError *error = nil;
        
        DONStatus *reply_to = [MTLJSONAdapter modelOfClass:DONStatus.class fromJSONDictionary:dict error:&error];
        if (error) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.alertStyle = NSAlertStyleWarning;
            alert.messageText = @"プラグインの実行中にエラーが発生しました。";
            alert.informativeText = [NSString stringWithFormat:@"%@", error];
            [alert runModal];
            return mrb_nil_value();
        }
        [vc setReplyTo:reply_to withHeader:header footer:footer];
    }

    NSPoint mouseLocation = NSEvent.mouseLocation;
    [wc.window setFrameTopLeftPoint:NSMakePoint(mouseLocation.x - 8, mouseLocation.y - 8)];
    [wc showWindow:nil];
    return mrb_nil_value();
}

#pragma mark -

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@property (nonatomic) DONApiClient *client;

@property (nonatomic) mrb_state *mrb;
@property (nonatomic) MRBPin *world;
@property (nonatomic) MRBProc *composeSpell;
@property (nonatomic) MRBProc *composeWithUserSpell;
@property (nonatomic) MRBProc *composeWithMessageSpell;
@property (nonatomic) MRBProc *worldCurrentFilter;

@property (nonatomic) NSWindowController *initialController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *host, *accessToken;
    fetch_credential(&host, &accessToken);
    self.client = [[DONApiClient alloc] initWithHost:host accessToken:accessToken];
    [self initializeMRuby];
    [self registerIntentHandlers];
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    self.initialController = [storyboard instantiateControllerWithIdentifier:@"mainWindow"];
    [self.initialController showWindow:self];
    [self.initialController.window makeKeyAndOrderFront:self];
    
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {}];
    center.delegate = self;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    self.composeSpell = nil;
    self.composeWithUserSpell = nil;
    self.composeWithMessageSpell = nil;
    self.worldCurrentFilter = nil;
    self.world = nil;
    mrb_close(self.mrb);
    self.mrb = NULL;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionSound);
}

- (void)initializeMRuby {
    self.mrb = mrb_open();
    mrb_setting_dsl_init(self.mrb);
    mix_register_log_handler(self.mrb, mrb_log_handler);
    mix_register_remain_handler(self.mrb, mrb_remain_handler);
    mix_register_reserve_handler(self.mrb, mrb_reserve_handler);
    {
        int ai = mrb_gc_arena_save(self.mrb);
        
        {
            NSString *cocotodonPlugins = [NSHomeDirectory() stringByAppendingPathComponent:@"CocotodonPlugins/"];
            BOOL pathIsDir = NO;
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:cocotodonPlugins isDirectory:&pathIsDir];
            if (exists && pathIsDir) {
                mix_miquire_append_loadpath_cstr(self.mrb, cocotodonPlugins.UTF8String);
            }
        }
        mix_miquire_load_all(self.mrb);
        if (self.mrb->exc) {
            exc2log(self.mrb);
            NSAlert *alert = [[NSAlert alloc] init];
            alert.alertStyle = NSAlertStyleCritical;
            alert.messageText = @"プラグインの読み込み中にエラーが発生しました。";
            alert.informativeText = exc2str(self.mrb, mrb_obj_value(self.mrb->exc));
            [alert runModal];
            self.mrb->exc = 0;
            [NSApp terminate:self];
            return;
        } else {
            NSLog(@"Mix::Miquire.load_all success!");
        }
        
        if (mix_require(self.mrb, [[NSBundle mainBundle] pathForResource:@"mrb_cocotodon_model" ofType:@"rb"].UTF8String)) {
            NSLog(@"mrb_cocotodon_model.rb load success!");
            struct RClass *mod_cct = mrb_module_get(self.mrb, "Cocotodon");
            struct RClass *cls_world = mrb_class_get_under(self.mrb, mod_cct, "World");
            mrb_value val = mrb_hash_new(self.mrb);
            mrb_value world = mrb_obj_new(self.mrb, cls_world, 1, &val);
            if (self.mrb->exc) {
                exc2log(self.mrb);
                self.mrb->exc = 0;
            } else {
                NSLog(@"Cocotodon::World generated.");
                self.world = [[MRBPin alloc] initWithValue:world by:self.mrb];
            }
        } else {
            exc2log(self.mrb);
            self.mrb->exc = 0;
        }
        
        if (self.world) {
            self.worldCurrentFilter = [[MRBProc alloc] initWithBlock:^mrb_value(mrb_state * _Nonnull mrb) {
                mrb_value arg = mrb_get_arg1(mrb);
                if (mrb_test(arg)) {
                    return mrb_ary_new_from_values(mrb, 1, &arg);
                } else {
                    mrb_value world = self.world.value;
                    return mrb_ary_new_from_values(mrb, 1, &world);
                }
            } by:self.mrb];
            mrb_value plugin = mix_plugin_get(self.mrb, "cocotodon");
            mix_plugin_add_event_filter_proc(self.mrb, plugin, "world_current", self.worldCurrentFilter.value);
        }
        
        self.composeSpell = [[MRBProc alloc] initWithBlock:^mrb_value(mrb_state * _Nonnull mrb) {
            NSLog(@"compose(:cocotodon_world)");
            
            mrb_value world, kwrest;
            mrb_value kwvalues[1];
            const char *kwnames[] = { "body" };
            mrb_kwargs kwargs = { 1, kwvalues, kwnames, 1, &kwrest };
            mrb_get_args(mrb, "o:", &world, &kwargs);
            
            NSString *body = [NSString stringWithUTF8String:mrb_string_cstr(mrb, kwvalues[0])];
            
            [self.client postStatus:body
                            replyTo:nil
                           mediaIds:nil
                          sensitive:NO
                        spoilerText:nil
                         visibility:DONStatusPublic
                            success:nil
                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                WriteAFNetworkingErrorToLog(error);
            }];
            
            return mrb_true_value();
        } by:self.mrb];
        mrb_sym compose_slugs[] = { mrb_intern_lit(self.mrb, "cocotodon_world") };
        mix_define_spell(self.mrb, "compose", 1, compose_slugs, mrb_nil_value(), self.composeSpell.value);
        if (self.mrb->exc) {
            exc2log(self.mrb);
            self.mrb->exc = 0;
        } else {
            NSLog(@"defspell(:compose, :cocotodon_world)");
        }
        
        self.composeWithUserSpell = [[MRBProc alloc] initWithBlock:^mrb_value(mrb_state * _Nonnull mrb) {
            NSLog(@"compose(:cocotodon_world, :cocotodon_user)");
            mrb_raise(mrb, E_NOTIMP_ERROR, "WIP");
        } by:self.mrb];
        mrb_sym compose_with_user_slugs[] = { mrb_intern_lit(self.mrb, "cocotodon_world"), mrb_intern_lit(self.mrb, "cocotodon_user") };
        mix_define_spell(self.mrb, "compose", 2, compose_with_user_slugs, mrb_nil_value(), self.composeWithUserSpell.value);
        if (self.mrb->exc) {
            exc2log(self.mrb);
            self.mrb->exc = 0;
        } else {
            NSLog(@"defspell(:compose, :cocotodon_world, :cocotodon_user)");
        }
        
        self.composeWithMessageSpell = [[MRBProc alloc] initWithBlock:^mrb_value(mrb_state * _Nonnull mrb) {
            NSLog(@"compose(:cocotodon_world, :cocotodon_message)");
            
            mrb_value world, message, kwrest;
            mrb_value kwvalues[1];
            const char *kwnames[] = { "body" };
            mrb_kwargs kwargs = { 1, kwvalues, kwnames, 1, &kwrest };
            mrb_get_args(mrb, "oo:", &world, &message, &kwargs); // kwrestは明示的に受けとっておかないと引数不一致になる
            
//            mrb_value user = mrb_funcall(mrb, message, "user", 0);
            NSString *replyToId = [NSString stringWithUTF8String:mrb_str_to_cstr(mrb, mrb_funcall(mrb, message, "id", 0))];
//            NSString *acct = [NSString stringWithUTF8String:mrb_string_cstr(mrb, mrb_funcall(mrb, user, "idname", 0))];
            NSString *body = [NSString stringWithUTF8String:mrb_string_cstr(mrb, kwvalues[0])];
            
            [self.client postStatus:body
                            replyTo:replyToId
                           mediaIds:nil
                          sensitive:NO
                        spoilerText:nil
                         visibility:DONStatusPublic
                            success:nil
                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                WriteAFNetworkingErrorToLog(error);
            }];
            
            return mrb_true_value();
        } by:self.mrb];
        mrb_sym compose_with_message_slugs[] = { mrb_intern_lit(self.mrb, "cocotodon_world"), mrb_intern_lit(self.mrb, "cocotodon_message") };
        mix_define_spell(self.mrb, "compose", 2, compose_with_message_slugs, mrb_nil_value(), self.composeWithMessageSpell.value);
        if (self.mrb->exc) {
            exc2log(self.mrb);
            self.mrb->exc = 0;
        } else {
            NSLog(@"defspell(:compose, :cocotodon_world, :cocotodon_message)");
        }
        
        mrb_value gui_handler = mix_plugin_get(self.mrb, "gui_handler");
        mix_plugin_add_event_listener(self.mrb, gui_handler, "timeline_created", gui_handler_callback);
        mix_plugin_add_event_listener(self.mrb, gui_handler, "postbox_created", gui_handler_callback);
        mix_plugin_add_event_listener(self.mrb, gui_handler, "gui_destroy", gui_handler_callback);
        mix_plugin_add_event_listener(self.mrb, gui_handler, "postbox_created", postbox_created_callback);
        
        mix_plugin_call_arg0(self.mrb, "boot");
        mrb_gc_arena_restore(self.mrb, ai);
    }
}

- (void)registerIntentHandlers {
    IntentManager *manager = IntentManager.sharedManager;
    [manager registerHandlerWithRegex:[NSRegularExpression regularExpressionWithPattern:@"\\Ahttps?://shindanmaker\\.com/([0-9]+)\\z" options:0 error:nil]
                                label:@"診断メーカーで診断"
                           usingBlock:^(NSString * _Nonnull link) {
        // TODO: いいかんじに
        NSLog(@"Handle %@", link);
    }];
}

@end
