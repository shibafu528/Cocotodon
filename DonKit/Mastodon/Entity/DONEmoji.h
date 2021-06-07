//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DONEmoji : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSString *shortcode;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSURL *staticURL;
@property (nonatomic, readonly) BOOL visibleInPicker;
@property (nonatomic, readonly, nullable) NSString *category;

@end

NS_ASSUME_NONNULL_END
