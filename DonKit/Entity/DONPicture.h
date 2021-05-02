//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DONPictureFormat) {
    DONPicturePNG,
    DONPictureJPEG
};

@interface DONPicture : NSObject

@property (nonatomic, copy, readonly) NSData *data;
@property (nonatomic, readonly) DONPictureFormat format;

- (instancetype) init __attribute__((unavailable("init is not available")));

- (instancetype) initWithData:(NSData*)data format:(DONPictureFormat)format;

- (NSString*) extension;

- (NSString*) mimeType;

@end

NS_ASSUME_NONNULL_END
