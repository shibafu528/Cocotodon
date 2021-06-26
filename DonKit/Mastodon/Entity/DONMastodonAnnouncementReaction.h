//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DONMastodonAnnouncementReaction : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSNumber *count;
@property (nonatomic, readonly) BOOL me;
@property (nonatomic, readonly, nullable) NSURL *URL;
@property (nonatomic, readonly, nullable) NSURL *staticURL;

@end

NS_ASSUME_NONNULL_END
