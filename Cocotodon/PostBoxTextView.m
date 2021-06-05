//
// Copyright (c) 2021 shibafu
//

#import "PostBoxTextView.h"
#import "DONPicture.h"

@implementation PostBoxTextView

- (NSArray<NSPasteboardType> *)readablePasteboardTypes {
    return [[super readablePasteboardTypes] arrayByAddingObject:NSPasteboardTypePNG];
}

- (IBAction)paste:(id)sender {
    NSPasteboard *pb = NSPasteboard.generalPasteboard;
    NSArray *classes = @[NSURL.class, NSImage.class];
    NSDictionary *options = @{
        NSPasteboardURLReadingFileURLsOnlyKey: @YES,
        NSPasteboardURLReadingContentsConformToTypesKey: @[@"public.image"],
    };
    if ([pb canReadObjectForClasses:classes options:options]) {
        NSArray *objects = [pb readObjectsForClasses:classes options:options];
        [objects enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSURL.class]) {
                // NSURL
                NSURL *url = obj;
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
                [self.postbox attachPicture:picture];
            } else {
                // NSImage
                NSImage *image = obj;
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:image.TIFFRepresentation];
                NSData *data = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
                DONPicture *picture = [[DONPicture alloc] initWithData:data format:DONPicturePNG];
                [self.postbox attachPicture:picture];
            }
        }];
    } else {
        [super paste:sender];
    }
}

@end
