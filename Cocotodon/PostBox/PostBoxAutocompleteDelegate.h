//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PostBoxAutocompletable <NSObject>

- (void)setCandidates:(NSArray<NSString *> *)candidates forKeyword:(NSString*)keyword;

@end

@protocol PostBoxAutocompleteDelegate <NSObject>

- (void)autocomplete:(id<PostBoxAutocompletable>)autocompletable didRequestCandidatesForKeyword:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
