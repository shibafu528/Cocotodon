//
// Copyright (c) 2020 shibafu
//

#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DONMastodonAccount : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSString *identity;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *acct;
@property (nonatomic, readonly) NSURL *avatar;
@property (nonatomic, readonly) NSURL *avatarStatic;

- (NSString*)fullAcct;

@end

NS_ASSUME_NONNULL_END
