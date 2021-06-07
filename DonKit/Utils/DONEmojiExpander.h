//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import "DONEmojiProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface DONEmojiExpander : NSObject

+ (NSAttributedString*)expandFromAttributedString:(NSAttributedString*)string providedBy:(id<DONEmojiProvider>)provider;

@end

NS_ASSUME_NONNULL_END
