//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DONStatusContentParser : NSObject

@property (nonatomic, readonly) NSString *textContent;
@property (nonatomic, readonly) NSArray<NSValue*> *linkRanges;

- (instancetype)initWithString:(NSString*)string;

- (BOOL)parse;

@end

NS_ASSUME_NONNULL_END
