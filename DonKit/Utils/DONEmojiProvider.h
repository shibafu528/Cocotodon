//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import "DONEmoji.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DONEmojiProvider <NSObject>

@property (nonatomic, readonly) NSArray<DONEmoji*> *emojis;

@end

NS_ASSUME_NONNULL_END
