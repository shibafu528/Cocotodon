//
// Copyright (c) 2022 shibafu
//

#import "DONApiClient.h"
#import "DONEmoji.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONApiCustomEmojisCompletionHandler)(NSURLSessionDataTask *_Nonnull task, NSArray<DONEmoji *> *_Nullable results, NSError *_Nullable error);

@interface DONApiClient (Instance)

- (void)customEmojisWithCompletion:(DONApiCustomEmojisCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
