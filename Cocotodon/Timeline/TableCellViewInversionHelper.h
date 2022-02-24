//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableCellViewInversionHelper : NSObject

@property (nonatomic, readonly, copy) NSDictionary<NSAttributedStringKey, id> *linkNormalAttributes;
@property (nonatomic, readonly, copy) NSDictionary<NSAttributedStringKey, id> *linkEmphasizedAttributes;

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle toTextView:(NSTextView *)textView;

@end

NS_ASSUME_NONNULL_END
