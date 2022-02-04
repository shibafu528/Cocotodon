//
// Copyright (c) 2022 shibafu
//

#import "DONStatusContentAnchor.h"

@implementation DONStatusContentAnchor

- (instancetype)initWithRange:(NSRange)range href:(NSString *)href {
    if (self = [super init]) {
        _range = range;
        _href = [href copy];
    }
    return self;
}

@end
