//
// Copyright (c) 2021 shibafu
//

#import "PreviewViewController.h"
#import "DONMastodonAttachment.h"
#import "ClickableImageView.h"

@interface PreviewViewController ()

@property (nonatomic, weak) IBOutlet ClickableImageView *imageView;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progress;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self.view.window makeFirstResponder:self];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self.spinner startAnimation:nil];
    [self.progress startAnimation:nil];
    
    __weak typeof(self) weakSelf = self;
    DONMastodonAttachment *attachment = (DONMastodonAttachment*) representedObject;
    [self downloadAttachment:attachment].then(^(NSImage * _Nonnull image) {
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
            [strongSelf.spinner stopAnimation:nil];
            strongSelf.spinner.hidden = YES;
            [strongSelf.progress stopAnimation:nil];
            strongSelf.progress.hidden = YES;
            [window setFrame:newFrame display:YES animate:YES];
        }
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

- (IBAction)openPreview:(id)sender {
    [self.view.window close];
}

- (void)keyDown:(NSEvent *)event {
    if ([event.characters isEqualToString:@" "]) {
        [self.view.window close];
    } else {
        [super keyDown:event];
    }
}

- (AnyPromise *)downloadAttachment:(DONMastodonAttachment *)attachment {
    if (![attachment.type isEqualToString:@"image"]) {
        return [AnyPromise promiseWithValue:[NSImage imageNamed:NSImageNameSlideshowTemplate]];
    }
    
    __weak typeof(self) weakSelf = self;
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver _Nonnull resolver) {
        NSURL *url = attachment.remoteURL ? attachment.remoteURL : attachment.URL;
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
        AFImageResponseSerializer *serializer = [AFImageResponseSerializer serializer];
        // Big Sur以降ならWebPのデコードに対応しているはず
        serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"image/webp"];
        manager.responseSerializer = serializer;
        [manager GET:[url absoluteString]
          parameters:nil
             headers:nil
            progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                if (strongSelf) {
                    strongSelf.progress.doubleValue = downloadProgress.completedUnitCount * 100 / downloadProgress.totalUnitCount;
                }
            });
        }
             success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
            resolver(responseObject);
        }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            WriteAFNetworkingErrorToLog(error);
            resolver([NSImage imageNamed:NSImageNameCaution]);
        }];
    }];
}

@end
