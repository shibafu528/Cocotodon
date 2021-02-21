//
// Copyright (c) 2020 shibafu
//

#import "MRBSettingFileSelect.h"

@implementation MRBSettingFileSelect

- (instancetype)initWithFrame:(NSRect)frameRect config:(mrb_sym)config {
    if (self = [super initWithFrame:frameRect config:config]) {
        [self loadNibWithName:self.className];
        _label = @"";
        _path = @"";
        _cwd = nil;
    }
    return self;
}

- (IBAction)browse:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = NO;
    if (self.cwd && ![self.cwd isEqualToString:@""]) {
        panel.directoryURL = [NSURL fileURLWithPath:self.cwd];
    }
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            self.path = panel.URL.path;
        }
    }];
}

@end
