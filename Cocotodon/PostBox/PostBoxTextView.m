//
// Copyright (c) 2021 shibafu
//

#import "PostBoxTextView.h"
#import "DONPicture.h"

@interface PostBoxTextView ()

@property (nonatomic, copy) NSString *autocompleteKeyword;
@property (nonatomic, readonly) NSArray<NSString *> *autocompleteCandidates;

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
    _autocompleteKeyword = nil;
    _autocompleteCandidates = nil;
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

- (void)debounceComplete {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(complete:) object:nil];
    [self performSelector:@selector(complete:) withObject:nil afterDelay:0.2];
}

- (void)insertText:(id)string replacementRange:(NSRange)replacementRange {
    [super insertText:string replacementRange:replacementRange];
    [self debounceComplete];
}

- (NSRange)rangeForUserCompletion {
    NSString *input = self.string;
    NSUInteger length = input.length;
    if (length < 1) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    NSUInteger location = self.selectedRange.location;
    NSRange anchor = [input rangeOfCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet
                                            options:NSBackwardsSearch
                                              range:NSMakeRange(0, location)];
    NSUInteger lead = anchor.location == NSNotFound ? 0 : anchor.location + 1;
    if (lead >= length || lead == location) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    unichar leadchar = [input characterAtIndex:lead];
    switch (leadchar) {
        case '#':
        case '@':
        case ':': {
            NSRange complementRange = NSMakeRange(lead, location - lead);
            NSString *substring = [input substringWithRange:complementRange];
            NSLog(@"-[PostBoxTextView rangeForUserCompletion] (%lu, %lu) %@", complementRange.location, complementRange.length, substring);
            if (![self.autocompleteKeyword isEqualToString:substring]) {
                self.autocompleteKeyword = substring;
                _autocompleteCandidates = nil;
                [self.autocompleteDelegate autocompleteDidRequestCandidatesForKeyword:substring];
            }
            return complementRange;
        }
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSArray<NSString *> *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    // 0文字のrangeに対して候補を出すことは無い
    if (charRange.length == 0) {
        return nil;
    }
    // 候補の取得を要求した時点と指している文字列が変わっている場合、現在持っている候補データは使いものにならない可能性がある
    NSString *substring = [self.string substringWithRange:charRange];
    if (![substring isEqualToString:self.autocompleteKeyword]) {
        return nil;
    }
    return self.autocompleteCandidates;
}

- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    if (flag) {
        switch (movement) {
            case NSTextMovementReturn:
            case NSTextMovementTab:
                [self insertText:[word stringByAppendingString:@" "] replacementRange:charRange];
                break;
        }
    }
}

- (void)setCandidates:(NSArray<NSString *> *)candidates forKeyword:(NSString*)keyword {
    // 候補の取得を要求した時点と指している文字列が変わっている場合、候補データとして採用すべきでない
    if (![self.autocompleteKeyword isEqualToString:keyword]) {
        return;
    }
    _autocompleteCandidates = [candidates copy];
    if (candidates.count) {
        [self complete:nil];
    }
}

@end
