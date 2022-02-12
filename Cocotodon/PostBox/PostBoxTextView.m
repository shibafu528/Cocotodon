//
// Copyright (c) 2021 shibafu
//

#import "PostBoxTextView.h"
#import "DONPicture.h"

@interface PostBoxTextView ()

@property (nonatomic) NSRange complementRange;
@property (nonatomic, copy) NSString *complementKeyword;

@end

@implementation PostBoxTextView

- (instancetype)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)container {
    if (self = [super initWithFrame:frameRect textContainer:container]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _complementRange = NSMakeRange(NSNotFound, 0);
    _complementKeyword = nil;
}

#pragma mark - Paste support

- (NSArray<NSPasteboardType> *)readablePasteboardTypes {
    return [[super readablePasteboardTypes] arrayByAddingObject:NSPasteboardTypePNG];
}

- (IBAction)paste:(id)sender {
    if ([self tryPasteImagesFromPasteboard:NSPasteboard.generalPasteboard]) {
        return;
    }
    
    [super paste:sender];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    if ([self tryPasteImagesFromPasteboard:sender.draggingPasteboard]) {
        return YES;
    } else {
        return [super performDragOperation:sender];
    }
}

- (BOOL)tryPasteImagesFromPasteboard:(NSPasteboard*)pasteboard {
    NSArray *classes = @[NSURL.class, NSImage.class];
    NSDictionary *options = @{
        NSPasteboardURLReadingFileURLsOnlyKey: @YES,
        NSPasteboardURLReadingContentsConformToTypesKey: @[@"public.image"],
    };
    if ([pasteboard canReadObjectForClasses:classes options:options]) {
        NSArray *objects = [pasteboard readObjectsForClasses:classes options:options];
        if (objects.count) {
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
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Autocomplete support

- (void)keyUp:(NSEvent *)event {
    [super keyUp:event];
    
    NSString *input = self.string;
    NSUInteger length = input.length;
    if (length < 1) {
        return;
    }
    
    NSUInteger location = self.selectedRange.location;
    NSRange anchor = [input rangeOfCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet
                                            options:NSBackwardsSearch
                                              range:NSMakeRange(0, location)];
    NSUInteger lead = anchor.location == NSNotFound ? 0 : anchor.location + 1;
    if (lead >= length || lead == location) {
        return;
    }
    
    unichar leadchar = [input characterAtIndex:lead];
    switch (leadchar) {
        case '#':
        case '@':
        case ':': {
            NSRange complementRange = NSMakeRange(lead, location - lead);
            NSString *substring = [input substringWithRange:complementRange];
            NSLog(@"(%lu, %lu) %@", complementRange.location, complementRange.length, substring);
            if (!NSEqualRanges(self.complementRange, complementRange) || ![self.complementKeyword isEqualToString:substring]) {
                self.complementRange = complementRange;
                self.complementKeyword = substring;
                [self.autocompleteDelegate autocompleteDidRequestCandidatesForKeyword:substring];
            }
            break;
        }
    }
}

- (NSRange)rangeForUserCompletion {
    return self.complementRange;
}

- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    [super insertCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
    if (flag) {
        self.complementRange = NSMakeRange(NSNotFound, 0);
        self.complementKeyword = nil;
    }
}

@end
