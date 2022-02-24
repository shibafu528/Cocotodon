//
// Copyright (c) 2022 shibafu
//

#import <Cocoa/Cocoa.h>
#import "TimelineAvatarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationCellView : NSTableCellView

@property (nonatomic) IBOutlet TimelineAvatarView *avatarView;
@property (nonatomic) IBOutlet NSTextField *summaryField;
@property (nonatomic) IBOutlet NSTextField *detailField;

@end

NS_ASSUME_NONNULL_END
