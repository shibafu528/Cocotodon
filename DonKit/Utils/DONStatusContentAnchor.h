//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DONStatusContentAnchor : NSObject

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, copy, readonly) NSString *href;

- (instancetype)initWithRange:(NSRange)range href:(NSString *)href;

@end

NS_ASSUME_NONNULL_END
