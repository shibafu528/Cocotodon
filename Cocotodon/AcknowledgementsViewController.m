//
// Copyright (c) 2021 shibafu
//

#import "AcknowledgementsViewController.h"

@interface AcknowledgementsViewController ()

@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation AcknowledgementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableString *str = [NSMutableString string];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Pods-Cocotodon-acknowledgements" ofType:@"plist"]];
    [plist[@"PreferenceSpecifiers"] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0 || ![group[@"Title"] length]) {
            return;
        }
        
        [str appendString:group[@"Title"]];
        [str appendString:@"\n\n"];
        [str appendString:group[@"FooterText"]];
        [str appendString:@"\n\n----------------\n\n"];
    }];
    [self.textView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:str]];
}

@end
