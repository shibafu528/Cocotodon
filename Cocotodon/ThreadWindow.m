//
// Copyright (c) 2021 shibafu
//

#import "ThreadWindow.h"
#import "TimelineViewController.h"

@interface ThreadWindow ()

@property (nonatomic) NSString *statusID;

@end

@implementation ThreadWindow

- (instancetype)initWithStatusID:(NSString *)identity {
    if (self = [super initWithContentRect:NSZeroRect
                                styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable
                                  backing:NSBackingStoreBuffered
                                    defer:NO]) {
        _statusID = identity;
        
        TimelineViewController *vc = [[TimelineViewController alloc] init];
        vc.timelineReloader = ^AnyPromise *(TimelineViewController *vc) {
            AnyPromise *p = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
                [App.client getStatus:identity success:^(NSURLSessionDataTask * _Nonnull task, DONStatus * _Nonnull result) {
                    resolver(result);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    resolver(error);
                }];
            }];
            p = p.then(^(DONStatus *status) {
                return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
                    [App.client getStatusContext:identity success:^(NSURLSessionDataTask * _Nonnull task, DONStatusContext * _Nonnull result) {
                        NSMutableArray *thread = [NSMutableArray arrayWithObject:status];
                        [result.ancestors enumerateObjectsWithOptions:NSEnumerationReverse
                                                           usingBlock:^(DONStatus * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [thread addObject:obj];
                        }];
                        resolver(thread);
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                        resolver(error);
                    }];
                }];
            });
            return p;
        };
        self.contentViewController = vc;
        self.title = @"会話";
        self.releasedWhenClosed = NO;
    }
    return self;
}

@end
