//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "DONStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface DONStatusContext : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSArray<DONStatus*> *ancestors;
@property (nonatomic, readonly) NSArray<DONStatus*> *descendants;

@end

NS_ASSUME_NONNULL_END
