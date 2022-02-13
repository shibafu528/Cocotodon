//
// Copyright (c) 2022 shibafu
//

#import <Foundation/Foundation.h>
#import "DONPicture.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PostBoxAttachmentDelegate <NSObject>

- (void)attachPicture:(DONPicture*)picture;

@end

NS_ASSUME_NONNULL_END
