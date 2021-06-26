//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "DONEmoji.h"
#import "DONEmojiProvider.h"
#import "DONMastodonAnnouncementReaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface DONMastodonAnnouncement : MTLModel<MTLJSONSerializing, DONEmojiProvider>

@property (nonatomic, readonly) NSString *identity;
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly, nullable) NSDate *startsAt;
@property (nonatomic, readonly, nullable) NSDate *endsAt;
@property (nonatomic, readonly) BOOL allDay;
@property (nonatomic, readonly) NSDate *publishedAt;
@property (nonatomic, readonly) NSDate *updatedAt;
@property (nonatomic, readonly) BOOL read;
@property (nonatomic, readonly) NSArray<DONEmoji*> *emojis;
@property (nonatomic, readonly) NSArray<DONMastodonAnnouncementReaction*> *reactions;

- (NSAttributedString *)expandAttributedContent;

@end

NS_ASSUME_NONNULL_END
