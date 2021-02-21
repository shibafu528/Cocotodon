//
// Copyright (c) 2020 shibafu
//

#import "MRBSettingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MRBSettingFileSelect : MRBSettingView

@property (nonatomic) NSString *label;
@property (nonatomic) NSString *path;
@property (nonatomic, nullable) NSString *cwd;

@end

NS_ASSUME_NONNULL_END
