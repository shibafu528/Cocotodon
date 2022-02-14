//
// Copyright (c) 2022 shibafu
//

#import "DONPromise.h"

AnyPromise *DONPromisify(DONPromisifyBlock block) {
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver _Nonnull resolver) {
        block(^(NSURLSessionDataTask *_Nonnull task, id _Nullable result, NSError *_Nullable error) {
            if (error) {
                resolver(error);
                return;
            }
            resolver(result);
        });
    }];
}
