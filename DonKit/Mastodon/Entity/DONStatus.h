//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "DONMastodonAccount.h"
#import "DONMastodonAttachment.h"
#import "DONStatusVisibility.h"
#import "DONEmoji.h"
#import "DONEmojiProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface DONStatus : MTLModel<MTLJSONSerializing, DONEmojiProvider>

@property (nonatomic, readonly) NSString *identity;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) DONMastodonAccount *account;
@property (nonatomic, readonly) BOOL sensitive;
@property (nonatomic, readonly) NSString *spoilerText;
@property (nonatomic, readonly) DONStatusVisibility visibility;
@property (nonatomic, readonly) NSURL *URI;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) DONStatus *reblog;
@property (nonatomic, readonly) NSArray<DONMastodonAttachment*> *mediaAttachments;
@property (nonatomic, readonly) NSArray<DONEmoji*> *emojis;
@property (nonatomic, readonly) NSDictionary *poll;
@property (nonatomic, readonly) BOOL favourited;
@property (nonatomic, readonly, nullable) NSDate *editedAt;

- (NSString*)expandContent;
- (NSAttributedString*)expandAttributedContent;
- (DONStatus*)originalStatus;

@end

NS_ASSUME_NONNULL_END
