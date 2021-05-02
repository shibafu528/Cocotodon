//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DONMastodonAttachment : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSString *identity;
@property (nonatomic, readonly) NSString *type; // TODO: Enumにする?
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSURL *previewURL;
@property (nonatomic, readonly, nullable) NSURL *remoteURL;
@property (nonatomic, readonly, nullable) NSURL *textURL;
@property (nonatomic, readonly, nullable) NSString *attachmentDescription;
@property (nonatomic, readonly, nullable) NSString *blurhash;

@end

NS_ASSUME_NONNULL_END
