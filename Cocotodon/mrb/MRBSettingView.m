//
// Copyright (c) 2020 shibafu
//

#import "MRBSettingView.h"

@interface MRBSettingView ()

@property (nonatomic, readwrite) mrb_sym config;

@end

@implementation MRBSettingView

- (instancetype)initWithFrame:(NSRect)frame config:(mrb_sym)config
{
    if (self = [super initWithFrame:frame]) {
        _config = config;
    }
    return self;
}

@end
