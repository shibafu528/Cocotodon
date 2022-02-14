//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>
#import <PromiseKit/PromiseKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DONPromisifyCompletionHandler)(NSURLSessionDataTask *_Nonnull task, id _Nullable result, NSError *_Nullable error);
typedef void (^DONPromisifyBlock)(DONPromisifyCompletionHandler completionHandler);

/// Completion handlerを受け取る形式のDonKit APIをPromiseに変換する
AnyPromise *DONPromisify(DONPromisifyBlock block);

NS_ASSUME_NONNULL_END
