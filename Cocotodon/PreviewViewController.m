//
// Copyright (c) 2021 shibafu
//

#import "PreviewViewController.h"
#import "DONMastodonAttachment.h"
#import "ClickableImageView.h"

@interface PreviewViewController ()

@property (nonatomic, weak) IBOutlet ClickableImageView *imageView;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self.progressIndicator startAnimation:nil];
    
    __weak typeof(self) weakSelf = self;
    DONMastodonAttachment *attachment = (DONMastodonAttachment*) representedObject;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        NSImage *image;
        if ([attachment.type isEqualToString:@"image"]) {
            NSURL *url = attachment.remoteURL ? attachment.remoteURL : attachment.URL;
            image = [[NSImage alloc] initWithContentsOfURL:url];
        } else {
            image = [NSImage imageNamed:NSImageNameSlideshowTemplate];
        }
        if (!image) {
            image = [NSImage imageNamed:NSImageNameCaution];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                NSWindow *window = strongSelf.view.window;
                CGFloat titleHeight = window.frame.size.height - [window contentRectForFrameRect:window.frame].size.height;
                
                NSRect screenFrame = window.screen.visibleFrame;
                CGSize maxSize = screenFrame.size;
                maxSize.width *= 0.75f;
                maxSize.height *= 0.75f;
                
                NSImageRep *rep = image.representations[0];
                CGSize newSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                if (CGSizeEqualToSize(newSize, CGSizeZero)) {
                    newSize = CGSizeMake(120, 120);
                }
                if (maxSize.width < rep.pixelsWide || maxSize.height < rep.pixelsHigh) {
                    CGFloat scaleW = maxSize.width / rep.pixelsWide;
                    CGFloat scaleH = maxSize.height / rep.pixelsHigh;
                    CGFloat scale = MIN(scaleW, scaleH);
                    newSize.width *= scale;
                    newSize.height *= scale;
                }
                newSize.height += titleHeight;
                NSRect newFrame = NSMakeRect(screenFrame.origin.x + (screenFrame.size.width / 2.0f) - (newSize.width / 2.0f),
                                             screenFrame.origin.y + (screenFrame.size.height / 2.0f) - (newSize.height / 2.0f),
                                             newSize.width, newSize.height);
                
                strongSelf.imageView.image = image;
                [strongSelf.progressIndicator stopAnimation:nil];
                [window setFrame:newFrame display:YES animate:YES];
            }
        });
    });
}

- (IBAction)clickThumbnail:(id)sender {
    if (self.representedObject) {
        DONMastodonAttachment *attachment = (DONMastodonAttachment*) self.representedObject;
        NSURL *url = attachment.remoteURL ? attachment.remoteURL : attachment.URL;
        [NSWorkspace.sharedWorkspace openURL:url];
        [self.view.window close];
    }
}

@end
