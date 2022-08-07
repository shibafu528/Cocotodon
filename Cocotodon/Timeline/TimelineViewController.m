//
// Copyright (c) 2020 shibafu
//

#import "TimelineViewController.h"
#import "ReplyViewController.h"
#import "PostBox.h"
#import "ExpandableCellView.h"
#import "DONEmojiExpander.h"
#import "MainWindowController.h"
#import "IntentManager.h"
#import "ThreadWindow.h"
#import "TimelineAvatarCellView.h"
#import <UserNotifications/UserNotifications.h>

/// TLの最大要素数
static const NSInteger kTimelineMaxItems = 1000;

static NSString* SummarizeContent(DONStatus *status) {
    NSString *content;
    if (status.spoilerText.length) {
        content = [status.spoilerText stringByAppendingString:@" | (選択して続きを表示...)"];
    } else {
        content = status.plainContent;
    }
    return [content stringByRemovingLineBreaksAndJoinedByString:@" "];
}

// ----------

@interface TimelineViewController () <NSTextViewDelegate, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate, DONStreamingEventDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic) BOOL subscribedStream;

@property (nonatomic) NSArray<DONStatus*> *statuses;

@property (nonatomic) MRBPin *commands;

@property (nonatomic) NSInteger prevSelection;
@property (nonatomic) bool presentationMode;

@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *favoriteStateOverrides;
@property (nonatomic) NSMutableSet<NSString *> *deletedStatusIDs;

@end

@implementation TimelineViewController

- (void)dealloc {
    self.commands = nil;
    if (self.unsubscribeStream) {
        self.unsubscribeStream(self);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.statuses = @[];
    self.commands = nil;
    self.prevSelection = -1;
    self.presentationMode = NO;
    self.favoriteStateOverrides = [NSMutableDictionary dictionary];
    self.deletedStatusIDs = [NSMutableSet set];

    if (self.subscribeStream) {
        self.subscribeStream(self);
        self.subscribedStream = YES;
    } else {
        self.subscribedStream = NO;
    }
    
    [self reload:nil];
}

- (void)viewDidAppear {
    [self updateToolbarStreamingItem];
}

- (void)viewWillLayout {
    [super viewWillLayout];
    [self.tableView sizeLastColumnToFit];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)reload:(id)sender {
    NSAssert(self.timelineReloader, @"timelineReloader is nil!!");
    __weak typeof(self) weakSelf = self;
    self.timelineReloader(self).then(^(NSArray<DONStatus *> * _Nonnull results) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.statuses = results;
        [strongSelf.favoriteStateOverrides removeAllObjects];
        [strongSelf.tableView reloadData];
    }).catch(^(NSError *error) {
        WriteAFNetworkingErrorToLog(error);
    });
}

- (IBAction)toggleStreamingStatus:(id)sender {
    if (!self.subscribeStream) {
        return;
    }
    
    if (self.subscribedStream) {
        self.unsubscribeStream(self);
    } else {
        self.subscribeStream(self);
    }
    self.subscribedStream = !self.subscribedStream;
    
    [self updateToolbarStreamingItem];
}

- (IBAction)togglePresentationMode:(id)sender {
    self.presentationMode = !self.presentationMode;
    ((NSMenuItem*) sender).state = self.presentationMode ? NSControlStateValueOn : NSControlStateValueOff;
    [self.tableView reloadData];
}

- (void)favoriteStatus:(DONStatus *)status {
    [App.client favoriteStatus:status.identity
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success favorite! : %@", status.identity);
        [self didUpdateFavoriteState:YES forStatusID:status.originalStatus.identity];
    }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        WriteAFNetworkingErrorToLog(error);
    }];
}

- (NSIndexSet *)indexesForStatusID:(NSString *)statusID {
    NSMutableIndexSet *rowIndexes = [NSMutableIndexSet indexSet];
    [self.statuses enumerateObjectsUsingBlock:^(DONStatus * _Nonnull status, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([status.originalStatus.identity isEqualToString:statusID]) {
            [rowIndexes addIndex:idx];
        }
    }];
    return rowIndexes;
}

- (void)didUpdateFavoriteState:(BOOL)favorited forStatusID:(NSString *)statusID {
    self.favoriteStateOverrides[statusID] = @(favorited);
    [self.tableView reloadDataForRowIndexes:[self indexesForStatusID:statusID] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
}

#pragma mark - DONStreamingEventDelegate

- (void)donStreamingDidReceiveUpdate:(DONStatus *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 簡易的な重複排除
        for (int i = 0; i < 8 && i < self.statuses.count; i++) {
            if ([self.statuses[i].identity isEqualToString:status.identity]) {
                return;
            }
        }
        
        if (self.statuses.count < kTimelineMaxItems) {
            self.statuses = [@[status] arrayByAddingObjectsFromArray:self.statuses];
        } else {
            NSUInteger removes = self.statuses.count - kTimelineMaxItems + 1;
            self.statuses = [@[status] arrayByAddingObjectsFromArray:[self.statuses subarrayWithRange:NSMakeRange(0, kTimelineMaxItems - 1)]];
            [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(kTimelineMaxItems - 1, removes)]
                                  withAnimation:NSTableViewAnimationSlideDown];
        }
        
        [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideDown];
        if (self.prevSelection != -1) {
            self.prevSelection++;
        }
    });
}

- (void)donStreamingDidReceiveDelete:(NSString *)statusID {
    [self.deletedStatusIDs addObject:statusID];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadDataForRowIndexes:[self indexesForStatusID:statusID] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    });
}

- (void)donStreamingDidReceiveNotification:(DONMastodonNotification *)notification {}

- (void)donStreamingDidReceiveStatusUpdate:(DONStatus *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<DONStatus *> *newStatuses = self.statuses.mutableCopy;
        NSMutableIndexSet *changes = [NSMutableIndexSet indexSet];
        [newStatuses enumerateObjectsUsingBlock:^(DONStatus * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.identity isEqualToString:status.identity]) {
                newStatuses[idx] = status;
                [changes addIndex:idx];
            }
        }];
        
        self.statuses = newStatuses;
        [self.tableView reloadDataForRowIndexes:changes columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    });
}

- (void)donStreamingDidFailWithError:(NSError *)error {
    NSLog(@"ws error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateToolbarStreamingItem];
    });
}

- (void)donStreamingDidCompleteWithCloseCode:(NSURLSessionWebSocketCloseCode)closeCode error:(NSError *)error {
    NSLog(@"ws close: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateToolbarStreamingItem];
    });
}

- (void)updateToolbarStreamingItem {
    NSString *sym = self.subscribedStream && self.isConnectedStream(self) ? @"bolt.fill" : @"bolt.slash";
    MainWindowController *wc = (MainWindowController*) self.view.window.windowController;
    [wc.toolbarStreamingItem setImage:[NSImage imageWithSystemSymbolName:sym accessibilityDescription:nil] forSegment:0];
}

#pragma mark - TableView

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    // TODO: Cocoa Bindingsに置き換える
    NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    DONStatus *status = self.statuses[row];
    if ([tableColumn.identifier isEqualToString:@"Icon"]) {
        TimelineAvatarCellView *cell = (TimelineAvatarCellView*) view;
        NSSize size = cell.avatarView.fittingSize;
        NSSize fittingSize = NSMakeSize(size.width, size.width);
        cell.avatarView.primaryImage = [[[NSImage alloc] initWithContentsOfURL:status.originalStatus.account.avatar] resizeToScreenSize:fittingSize];
        if (status.reblog) {
            cell.avatarView.secondaryImage = [[[NSImage alloc] initWithContentsOfURL:status.account.avatar] resizeToScreenSize:fittingSize];
        } else {
            cell.avatarView.secondaryImage = nil;
        }
        cell.avatarView.statusVisibility = status.originalStatus.visibility;
    } else if ([tableColumn.identifier isEqualToString:@"Acct"]) {
        NSString *acct = status.reblog ? [NSString stringWithFormat:@"🔁 %@", status.reblog.account.fullAcct] : status.account.fullAcct;
        NSMutableAttributedString *attrAcct = [[NSMutableAttributedString alloc] initWithString:acct];
        NSRange atmark = [acct rangeOfString:@"@"];
        NSRange domainRange = NSMakeRange(atmark.location, attrAcct.length - atmark.location);
        [attrAcct addAttribute:NSForegroundColorAttributeName value:[NSColor secondaryLabelColor] range:domainRange];
        [attrAcct addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] range:domainRange];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        [attrAcct addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrAcct.length)];
        view.textField.attributedStringValue = attrAcct;
        view.textField.toolTip = status.reblog ? [NSString stringWithFormat:@"@%@ がブースト", status.account.fullAcct] : nil;
    } else if ([tableColumn.identifier isEqualToString:@"Body"]) {
        ExpandableCellView *expandable = (ExpandableCellView*) view;
        NSMutableAttributedString *summary;
        {
            NSAttributedString *content = [[NSAttributedString alloc] initWithString:SummarizeContent(status.originalStatus)];
            NSAttributedString *expanded = [DONEmojiExpander expandFromAttributedString:content providedBy:status.originalStatus];
            summary = [[NSMutableAttributedString alloc] initWithAttributedString:expanded];
        }
        NSMutableAttributedString *detail;
        {
            NSAttributedString *expanded = [DONEmojiExpander expandFromAttributedString:status.originalStatus.expandAttributedContent providedBy:status.originalStatus];
            detail = [[NSMutableAttributedString alloc] initWithAttributedString:expanded];
        }
        
        NSMutableString *indicators = [NSMutableString string];
        if ([self.deletedStatusIDs containsObject:status.originalStatus.identity]) {
            [indicators appendString:@"🗑"];
            [summary addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, summary.length)];
            [detail addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, detail.length)];
        }
        if (status.editedAt) {
            [indicators appendString:@"✏️"];
        }
        if (status.originalStatus.mediaAttachments.count != 0) {
            [indicators appendString:@"🖼"];
        }
        if (status.originalStatus.poll) {
            [indicators appendString:@"🗳"];
        }
        if (indicators.length) {
            [indicators appendString:@" "];
            NSAttributedString *attributedIndicators = [[NSAttributedString alloc] initWithString:indicators];
            [summary insertAttributedString:attributedIndicators atIndex:0];
            [detail insertAttributedString:attributedIndicators atIndex:0];
        }
        if (self.presentationMode && !(status.visibility == DONStatusPublic || status.visibility == DONStatusUnlisted)) {
            NSString *scrambled = @"****************";
            summary = detail = [[NSMutableAttributedString alloc] initWithString:scrambled];
        }
        
        expandable.summaryString = summary;
        expandable.expandedText.delegate = self;
        expandable.expandedString = detail;
        expandable.status = status;
        expandable.attachments = status.originalStatus.mediaAttachments;
        expandable.expanded = row == tableView.selectedRow;
        
        NSNumber *favorited = self.favoriteStateOverrides[status.originalStatus.identity];
        if (favorited) {
            [expandable setFavoriteState:favorited.boolValue];
        } else {
            [expandable setFavoriteState:status.favourited];
        }
    }
    return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.statuses.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
//    NSLog(@"tableViewSelectionDidChange: %ld (prev: %ld)", self.tableView.selectedRow, self.prevSelection);
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    if (self.prevSelection != -1) {
        [indexes addIndex:self.prevSelection];
    }
    if (self.tableView.selectedRow != -1) {
        [indexes addIndex:self.tableView.selectedRow];
    }
    [self.tableView reloadDataForRowIndexes:indexes columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    
    self.prevSelection = self.tableView.selectedRow;
}

#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    if (![link isKindOfClass:NSString.class]) {
        return NO;
    }

    __auto_type candidates = [IntentManager.sharedManager candidatesForLink:link];
    if (candidates.count == 0) {
        return NO;
    } else if (candidates.count == 1) {
        [candidates[0] invokeWithLink:link];
        return YES;
    }

    NSMenu *menu = [[NSMenu alloc] init];
    [candidates enumerateObjectsUsingBlock:^(IntentHandler * _Nonnull candidate, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *item = [menu addItemWithTitle:candidate.label action:@selector(invokeIntentFromContextMenu:) keyEquivalent:@""];
        item.target = self;
        item.representedObject = ^{
            [candidate invokeWithLink:link];
        };
    }];
    [menu popUpMenuPositioningItem:nil atLocation:NSEvent.mouseLocation inView:nil];

    return YES;
}

- (void)invokeIntentFromContextMenu:(NSMenuItem*)sender {
    void (^callback)(void) = sender.representedObject;
    if (callback) {
        callback();
    }
}

#pragma mark - Context menu

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

- (void)menuNeedsUpdate:(NSMenu *)menu {
    if (self.tableView.clickedRow < 0) {
        return;
    }
    
    [menu removeAllItems];
    [menu addItemWithTitle:@"返信" action:@selector(reply:) keyEquivalent:@""];
    [menu addItemWithTitle:@"お気に入りに追加" action:@selector(favorite:) keyEquivalent:@""];
    [menu addItemWithTitle:@"お気に入りに追加してブースト" action:@selector(favoriteAndBoost:) keyEquivalent:@""];
    [menu addItemWithTitle:@"ブースト" action:@selector(boost:) keyEquivalent:@""];
    [menu addItemWithTitle:@"ブックマークに追加" action:@selector(bookmark:) keyEquivalent:@""];
    [menu addItemWithTitle:@"会話を見る" action:@selector(openThread:) keyEquivalent:@""];
    [menu addItemWithTitle:@"URLをコピー" action:@selector(copyURL:) keyEquivalent:@""];
    [menu addItemWithTitle:@"ブラウザで開く" action:@selector(openInBrowser:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"削除" action:@selector(deleteStatus:) keyEquivalent:@""];
    [menu addItemWithTitle:@"編集" action:@selector(recomposeStatus:) keyEquivalent:@""];
    [menu addItemWithTitle:@"通報" action:@selector(report:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];

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
    
    __auto_type status = self.statuses[self.tableView.clickedRow];
    mrb_value cct_message = [self statusAsMessage:status];
    if (mrb->exc) {
        [menu addItemWithTitle:@"mruby error" action:nil keyEquivalent:@""];
        exc2log(mrb);
        mrb->exc = 0;
        mrb_gc_arena_restore(mrb, ai);
        return;
    }
    
    mrb_value messages = mrb_ary_new_from_values(mrb, 1, &cct_message);
    mrb_value world = App.world.value;
    mrb_value opt = mix_gui_event_new(mrb, "contextmenu", mrb_nil_value(), messages, world);
    
    [self enumerateMikuCommands:commands roleOf:@"timeline" options:opt usingBlock:^(mrb_value hash, NSString * _Nonnull slug, NSString * _Nonnull name) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:name
                                                      action:@selector(performTimelineCommand:)
                                               keyEquivalent:@""];
        item.representedObject = slug;
        [menu addItem:item];
    }];
    
    mrb_gc_arena_restore(mrb, ai);
    mrb_gc_register(mrb, commands);
    self.commands = [[MRBPin alloc] initWithValue:commands by:mrb];
}

- (mrb_value)statusAsMessage:(DONStatus *)status {
    mrb_state *mrb = App.mrb;
    int ai = mrb_gc_arena_save(mrb);
    mrb_value hash_status = [status mrubyValue:mrb];
    hash_status = mrb_funcall_argv(mrb, hash_status, mrb_intern_lit(mrb, "symbolize"), 0, NULL);
    struct RClass *cocototon_message = mix_class_get(mrb, "Cocotodon", "Message");
    mrb_value message = mrb_obj_new(mrb, cocototon_message, 1, &hash_status);
    mrb_gc_arena_restore(mrb, ai);
    mrb_gc_protect(mrb, message);
    return message;
}

- (void)performTimelineCommand:(NSMenuItem *)sender {
    NSInteger row = self.tableView.clickedRow;
    if (row < 0) {
        return;
    }
    
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
    
    __auto_type status = self.statuses[row];
    mrb_value cct_message = [self statusAsMessage:status];
    if (mrb->exc) {
        exc2log(mrb);
        mrb->exc = 0;
        mrb_gc_arena_restore(mrb, ai);
        return;
    }
    
    MRBProc *ephemeral = [[MRBProc alloc] initWithBlock:^mrb_value(mrb_state * _Nonnull mrb) {
        // この辺は正直mruby側に書いたほうが楽。eventとして書くのが一番Pluggaloidらしいやり方。
        // しかし、ホスト側で書いたほうがPostboxの変更とかのハンドリングがやりやすいかもしれない。
        mrb_value main_gui_sym = mrb_symbol_value(mrb_intern_lit(mrb, "main"));
        struct RClass *cls_gui_timeline = mix_class_get(mrb, "Plugin", "GUI", "Timeline");
        mrb_value timeline = mrb_funcall_argv(mrb, mrb_obj_value(cls_gui_timeline), mrb_intern_lit(mrb, "instance"), 1, &main_gui_sym);
        
        struct RClass *cls_gui_postbox = mix_class_get(mrb, "Plugin", "GUI", "Postbox");
        mrb_value postbox = mrb_funcall_argv(mrb, mrb_obj_value(cls_gui_postbox), mrb_intern_lit(mrb, "instance"), 1, &main_gui_sym);
        
        // polyfill-gtkのオブジェクト生成待ち
        mix_run(mrb);
        
        mrb_value messages = mrb_ary_new_from_values(mrb, 1, &cct_message);
        mrb_value world = App.world.value;
        mrb_value opt = mix_gui_event_new(mrb, "contextmenu", timeline, messages, world);
        mrb_value response = mrb_funcall_argv(mrb, exec, mrb_intern_lit(mrb, "call"), 1, &opt);
        
        // 戻り値がDelayer::Deferredだったら、エラーハンドラを仕掛ける
        if (mrb_respond_to(mrb, response, mrb_intern_lit(mrb, "trap"))) {
            mrb_value error_sym = mrb_symbol_value(mrb_intern_lit(mrb, "error"));
            mrb_value error_method = mrb_funcall_argv(mrb, mrb_obj_value(mrb->kernel_module), mrb_intern_lit(mrb, "method"), 1, &error_sym);
            response = mrb_funcall_with_block(mrb, response, mrb_intern_lit(mrb, "trap"), 0, NULL, error_method);
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
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        
        exc2log(mrb);
        mrb->exc = 0;
    }
    mrb_gc_arena_restore(mrb, ai);
}

/// イベント発生時に操作対象となっている行を判定し、行番号を返す
- (NSInteger)targetRowInAction:(id)sender {
    if ([sender isKindOfClass:NSMenuItem.class] && [((NSMenuItem*) sender).menu.identifier isEqualToString:@"context"]) {
        return self.tableView.clickedRow;
    } else {
        return self.tableView.selectedRow;
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(deleteStatus:) || menuItem.action == @selector(recomposeStatus:)) {
        NSInteger row = [self targetRowInAction:menuItem];
        if (row < 0) {
            return NO;
        }
        
        DONStatus *status = self.statuses[row];
        return [status.originalStatus.account.identity isEqualToString:App.currentAccount.identity];
    } else if (menuItem.action == @selector(report:)) {
        NSInteger row = [self targetRowInAction:menuItem];
        if (row < 0) {
            return NO;
        }
        
        DONStatus *status = self.statuses[row];
        return ![status.originalStatus.account.identity isEqualToString:App.currentAccount.identity];
    }
    
    return YES;
}

#pragma mark - Actions

- (IBAction)reply:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"ReplyWindow" bundle:nil];
    NSWindowController *wc = [storyboard instantiateInitialController];
    NSPoint mouseLocation = NSEvent.mouseLocation;
    [wc.window setFrameTopLeftPoint:NSMakePoint(mouseLocation.x - 8, mouseLocation.y - 8)];
    ReplyViewController *vc = (ReplyViewController*) wc.contentViewController;
    [vc setReplyToAndAutoPopulate:self.statuses[row].originalStatus];
    [wc showWindow:self];
}

- (IBAction)favorite:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row];
    [self favoriteStatus:status];
}

- (IBAction)boost:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row];
    [App.client reblogStatus:status.identity
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success boost! : %@", status.identity);
    }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        WriteAFNetworkingErrorToLog(error);
    }];
}

- (IBAction)favoriteAndBoost:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row];
    [App.client favoriteStatus:status.identity
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success favorite! : %@", status.identity);
        [self didUpdateFavoriteState:YES forStatusID:status.originalStatus.identity];
    }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        WriteAFNetworkingErrorToLog(error);
    }];
    [App.client reblogStatus:status.identity
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Success boost! : %@", status.identity);
    }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        WriteAFNetworkingErrorToLog(error);
    }];
}

- (IBAction)bookmark:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row];
    [App.client bookmarkStatus:status.identity
                withCompletion:^(NSURLSessionDataTask * _Nonnull task, DONStatus * _Nullable result, NSError * _Nullable error) {
        if (error) {
            WriteAFNetworkingErrorToLog(error);
            return;
        }
        NSLog(@"Success bookmark! : %@", status.identity);
    }];
}

- (IBAction)openThread:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row];
    ThreadWindow *window = [[ThreadWindow alloc] initWithStatusID:status.originalStatus.identity];
    NSPoint mouseLocation = NSEvent.mouseLocation;
    [window setFrameTopLeftPoint:NSMakePoint(mouseLocation.x - 8, mouseLocation.y - 8)];
    [window makeKeyAndOrderFront:self];
}

- (IBAction)copyURL:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row];
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb setString:[status.originalStatus.URL absoluteString] forType:NSPasteboardTypeString];
}

- (IBAction)openInBrowser:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row];
    [NSWorkspace.sharedWorkspace openURL:status.originalStatus.URL];
}

- (IBAction)openPreview:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row];
    DONMastodonAttachment *attachment = status.originalStatus.mediaAttachments[0];
    if ([attachment.type isEqualToString:@"image"]) {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"PreviewWindow" bundle:nil];
        NSWindowController *wc = [storyboard instantiateInitialController];
        wc.contentViewController.representedObject = attachment;
        [wc showWindow:self];
    }
}

- (IBAction)deleteStatus:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row].originalStatus;
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    alert.messageText = @"失った信頼はもう戻ってきませんが、本当にこのトゥートを削除しますか？";
    alert.informativeText = [NSString stringWithFormat:@"%@\n%@", status.account.fullAcct, status.expandContent];
    NSButton *acceptButton = [alert addButtonWithTitle:@"削除"];
    acceptButton.hasDestructiveAction = YES;
    NSButton *cancelButton = [alert addButtonWithTitle:@"キャンセル"];
    cancelButton.keyEquivalent = @"\e";
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            [App.client deleteStatus:status.identity
                             success:^(NSURLSessionDataTask * _Nonnull task, DONStatus * _Nonnull result) {
                NSAlert *successAlert = [[NSAlert alloc] init];
                successAlert.alertStyle = NSAlertStyleInformational;
                successAlert.messageText = @"削除しました。";
                [successAlert addButtonWithTitle:@"OK"];
                [successAlert beginSheetModalForWindow:self.view.window completionHandler:nil];
            }
                             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                WriteAFNetworkingErrorToLog(error);
                NSAlert *successAlert = [[NSAlert alloc] init];
                successAlert.alertStyle = NSAlertStyleWarning;
                successAlert.messageText = @"削除中にエラーが発生しました。";
                [successAlert addButtonWithTitle:@"OK"];
                [successAlert beginSheetModalForWindow:self.view.window completionHandler:nil];
            }];
        }
    }];
}

- (IBAction)recomposeStatus:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"ReplyWindow" bundle:nil];
    NSWindowController *wc = [storyboard instantiateInitialController];
    NSPoint mouseLocation = NSEvent.mouseLocation;
    [wc.window setFrameTopLeftPoint:NSMakePoint(mouseLocation.x - 8, mouseLocation.y - 8)];
    ReplyViewController *vc = (ReplyViewController*) wc.contentViewController;
    [vc recomposeStatus:self.statuses[row].originalStatus];
    [wc showWindow:self];
}

- (IBAction)report:(id)sender {
    NSInteger row = [self targetRowInAction:sender];
    if (row < 0) {
        return;
    }
    
    DONStatus *status = self.statuses[row].originalStatus;
    BOOL isRemote = ![status.account.URL.host isEqualToString:App.client.host];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    alert.messageText = @"以下のトゥートをサーバーの管理者に通報します。よろしいですか？";
    alert.informativeText = [NSString stringWithFormat:@"%@\n%@", status.account.fullAcct, status.expandContent];
    NSButton *acceptButton = [alert addButtonWithTitle:@"通報"];
    acceptButton.hasDestructiveAction = YES;
    if (isRemote) {
        NSButton *forwardButton = [alert addButtonWithTitle:@"相手のサーバーにも通報"];
        forwardButton.hasDestructiveAction = YES;
    }
    NSButton *cancelButton = [alert addButtonWithTitle:@"キャンセル"];
    cancelButton.keyEquivalent = @"\e";
    NSTextField *comment = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 240, 20)];
    comment.placeholderString = @"コメント";
    alert.accessoryView = comment;
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn || (isRemote && returnCode == NSAlertSecondButtonReturn)) {
            [App.client reportAccount:status.account.identity
                            relatesTo:@[status.identity]
                              comment:comment.stringValue
                      forwardToRemote:isRemote && returnCode == NSAlertSecondButtonReturn
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSAlert *successAlert = [[NSAlert alloc] init];
                successAlert.alertStyle = NSAlertStyleInformational;
                successAlert.messageText = @"通報が完了しました。";
                [successAlert addButtonWithTitle:@"OK"];
                [successAlert beginSheetModalForWindow:self.view.window completionHandler:nil];
            }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                WriteAFNetworkingErrorToLog(error);
                NSAlert *successAlert = [[NSAlert alloc] init];
                successAlert.alertStyle = NSAlertStyleWarning;
                successAlert.messageText = @"通報中にエラーが発生しました。";
                [successAlert addButtonWithTitle:@"OK"];
                [successAlert beginSheetModalForWindow:self.view.window completionHandler:nil];
            }];
        }
    }];
}

@end
