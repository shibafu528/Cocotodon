//  Original source code written by rinsuki (https://github.com/cinderella-project/iMast)
//
//  ----
//
//  Copyright 2017-2021 rinsuki and other contributors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "AutolayoutTextView.h"

@implementation AutolayoutTextView

- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero]) {
        // 横幅が狭くなったら即座に潰れる
        [self setContentCompressionResistancePriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
        // 横幅が広くなったら即座に広がる
        [self setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
        // 縦方向には絶対潰れないし必要以上に伸びもしない
        [self setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
        [self setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
    }
    return self;
}

- (NSSize)intrinsicContentSize {
    __auto_type layoutManager = self.layoutManager;
    __auto_type textContainer = self.textContainer;
    if (!layoutManager || !textContainer) {
        return CGSizeZero;
    }
    
    [layoutManager ensureLayoutForTextContainer:textContainer];
    __auto_type size = [layoutManager usedRectForTextContainer:textContainer].size;
    // 整数にしないと non-Retina ディスプレイでぼやける
    return NSMakeSize(ceil(size.width), ceil(size.height));
}

- (void)layout {
    // 現在の横幅に応じた必要高さを計算させなおす必要がある
    [self invalidateIntrinsicContentSize];
    return [super layout];
}

- (void)rightMouseDown:(NSEvent *)event {
    if (self.selectedRange.length == 0) {
        [self.nextResponder rightMouseDown:event];
    } else {
        [super rightMouseDown:event];
    }
}

@end
