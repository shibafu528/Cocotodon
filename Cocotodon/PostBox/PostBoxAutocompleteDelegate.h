//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PostBoxAutocompleteDelegate <NSObject>

- (void)autocompleteDidRequestCandidatesForKeyword:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
