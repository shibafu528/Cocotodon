//
// Copyright (c) 2020 shibafu
//

#import "DONPicture.h"

@interface DONPicture ()

@end

@implementation DONPicture

- (instancetype)initWithData:(nonnull NSData *)data format:(DONPictureFormat)format {
    if (self = [super init]) {
        _data = data;
        _format = format;
    }
    return self;
}

- (NSString*)extension {
    switch (self.format) {
        case DONPicturePNG:
            return @".png";
        case DONPictureJPEG:
            return @".jpg";
    }
    return @"";
}

- (NSString*)mimeType {
    switch (self.format) {
        case DONPicturePNG:
            return @"image/png";
        case DONPictureJPEG:
            return @"image/jpeg";
    }
    return @"application/octet-stream";
}

@end
