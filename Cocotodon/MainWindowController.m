//
// Copyright (c) 2021 shibafu
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    // HACK: Catalinaでビルドする場合、xibで設定したtoolbarStyleは無視されるため、コード上で設定が必要
    if (@available(macOS 11.0, *)) {
        self.window.toolbarStyle = NSWindowToolbarStyleExpanded;
    }
}

@end
