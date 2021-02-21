//
// Copyright (c) 2020 shibafu
//

#import "NSView+NibLoader.h"

@implementation NSView (NibLoader)

- (void)loadNibWithName:(NSString*)nibName {
    NSNib *nib = [[NSNib alloc] initWithNibNamed:nibName bundle:[NSBundle mainBundle]];
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
    }
}

@end
