//
// Copyright (c) 2020 shibafu
//

#import "PreferencesViewController.h"
#import "mrb_setting_dsl.h"

@interface PreferencesViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, weak) IBOutlet NSStackView *settingsView;

@property (nonatomic) MRBPin *settings;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = [[MRBPin alloc] initWithValue:mix_plugin_filtering_arg1(App.mrb, "defined_settings", mrb_ary_new(App.mrb)) by:App.mrb];
    [self.outlineView reloadData];
    if (RARRAY_LEN(self.settings.value)) {
        [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil && self.settings) {
        return RARRAY_LEN(self.settings.value);
    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        mrb_value entry = mrb_ary_entry(self.settings.value, index);
        mrb_value title = mrb_ary_entry(entry, 0);
        return [NSString stringWithUTF8String:mrb_str_to_cstr(App.mrb, title)];
    }
    return nil;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *view = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    view.textField.stringValue = item;
    return view;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if (self.outlineView.selectedRow != -1) {
        [self.settingsView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        
        int ai = mrb_gc_arena_save(App.mrb);
        mrb_bool state;
        mrb_value res = mrb_protect_with_block(App.mrb, ^mrb_value(mrb_state *mrb) {
            mrb_value setting = mrb_ary_entry(self.settings.value, self.outlineView.selectedRow);
            mrb_value definition = mrb_ary_entry(setting, 1);
            
            mrb_value evaluator = mrb_setting_dsl_new(App.mrb, self.settingsView);
            mrb_funcall_with_block(App.mrb, evaluator, mrb_intern_lit(App.mrb, "instance_eval"), 0, NULL, definition);
            
            return mrb_nil_value();
        }, &state);
        if (state) {
            NSLog(@"%@", exc2str(App.mrb, res));
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.alertStyle = NSAlertStyleWarning;
            alert.messageText = @"プラグイン実行中にエラーが発生しました。";
            alert.informativeText = exc2str(App.mrb, res);
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        }
        mrb_gc_arena_restore(App.mrb, ai);
    }
}

@end
