//
// Copyright (c) 2021 shibafu
//

#import "MainViewController.h"
#import "PostBox.h"
#import "NSString+ReplaceLineBreaks.h"
#import "TimelineViewController.h"

static NSArray<DONStatus *> *mergeTimeline(NSArray<DONStatus *> *tl0, NSArray<DONStatus *> *tl1) {
    if (!tl0.count && !tl1.count) {
        return @[];
    } else if (!tl0.count) {
        return tl1;
    } else if (!tl1.count) {
        return tl0;
    }
    
    tl0 = [tl0 sortedArrayUsingComparator:^NSComparisonResult(DONStatus * _Nonnull obj1, DONStatus * _Nonnull obj2) {
        return [obj2.createdAt compare:obj1.createdAt];
    }];
    tl1 = [tl1 sortedArrayUsingComparator:^NSComparisonResult(DONStatus * _Nonnull obj1, DONStatus * _Nonnull obj2) {
        return [obj2.createdAt compare:obj1.createdAt];
    }];
    
    NSMutableArray<DONStatus *> *merged = [NSMutableArray arrayWithCapacity:tl0.count + tl1.count];
    for (int i0 = 0, i1 = 0;;) {
        DONStatus *s0 = nil, *s1 = nil;
        if (i0 < tl0.count) {
            s0 = tl0[i0];
        }
        if (i1 < tl1.count) {
            s1 = tl1[i1];
        }
        
        DONStatus *last = [merged lastObject];
        if (s0 != nil && s1 != nil) {
            switch ([s0.createdAt compare:s1.createdAt]) {
                case NSOrderedAscending: // s0.createdAt < s1.createdAt
                    if (!last || ![last.identity isEqualToString:s1.identity]) {
                        [merged addObject:s1];
                    }
                    i1++;
                    break;
                case NSOrderedSame:
                case NSOrderedDescending: // s0.createdAt >= s1.createdAt
                    if (!last || ![last.identity isEqualToString:s0.identity]) {
                        [merged addObject:s0];
                    }
                    i0++;
                    break;
            }
        } else if (s0 != nil) {
            if (!last || ![last.identity isEqualToString:s0.identity]) {
                [merged addObject:s0];
            }
            i0++;
        } else if (s1 != nil) {
            if (!last || ![last.identity isEqualToString:s1.identity]) {
                [merged addObject:s1];
            }
            i1++;
        } else {
            break;
        }
    }
    return (NSArray<DONStatus *> *) merged;
}

@implementation NSTabViewItem (WithVCAndLabel)

+ (instancetype)tabViewItemWithViewController:(nonnull NSViewController *)viewController label:(NSString *)label {
    NSTabViewItem *item = [NSTabViewItem tabViewItemWithViewController:viewController];
    item.label = label;
    return item;
}

@end

@interface MainViewController ()

@property (nonatomic, weak) IBOutlet PostBox *postbox;
@property (nonatomic, weak) NSTabViewController *tabVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.postbox.borderStyle = PostBoxBorderStyleBottomLine;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embeddedTabs"]) {
        self.tabVC = segue.destinationController;
        
        // make default tabs
        TimelineViewController *homeVC = [[TimelineViewController alloc] init];
        homeVC.timelineReloader = ^AnyPromise *(TimelineViewController *vc) {
            return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
                [App.client homeTimeline:^(NSURLSessionDataTask * _Nonnull task, NSArray<DONStatus *> * _Nonnull results) {
                    resolver(results);
                }
                                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    resolver(error);
                }];
            }];
        };
        homeVC.streamingInitiator = ^DONWebSocketStreaming *(id<DONStreamingEventDelegate> vc) {
            return [App.client userStreamingViaWebSocketWithDelegate:vc];
        };
        [self.tabVC addTabViewItem:[NSTabViewItem tabViewItemWithViewController:homeVC label:@"ホーム"]];
        
        TimelineViewController *localVC = [[TimelineViewController alloc] init];
        localVC.timelineReloader = ^AnyPromise *(TimelineViewController *vc) {
            return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
                [App.client publicTimelineOnlyLocal:YES
                                            success:^(NSURLSessionDataTask * _Nonnull task, NSArray<DONStatus *> * _Nonnull results) {
                    resolver(results);
                }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    resolver(error);
                }];
            }];
        };
        localVC.streamingInitiator = ^DONWebSocketStreaming *(id<DONStreamingEventDelegate> vc) {
            return [App.client localPublicStreamingViaWebSocketWithDelegate:vc];
        };
        [self.tabVC addTabViewItem:[NSTabViewItem tabViewItemWithViewController:localVC label:@"ローカル"]];
        
        TimelineViewController *homeLocalVC = [[TimelineViewController alloc] init];
        homeLocalVC.timelineReloader = ^AnyPromise *(TimelineViewController *vc) {
            AnyPromise *fetchHome = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
                [App.client homeTimeline:^(NSURLSessionDataTask * _Nonnull task, NSArray<DONStatus *> * _Nonnull results) {
                    resolver(results);
                }
                                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    resolver(error);
                }];
            }];
            AnyPromise *fetchLocal = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
                [App.client publicTimelineOnlyLocal:YES
                                            success:^(NSURLSessionDataTask * _Nonnull task, NSArray<DONStatus *> * _Nonnull results) {
                    resolver(results);
                }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    resolver(error);
                }];
            }];
            return PMKWhen(@[fetchHome, fetchLocal]).then(^(NSArray<NSArray<DONStatus *> *> *results) {
                return mergeTimeline(results[0], results[1]);
            });
        };
        homeLocalVC.streamingInitiator = ^DONWebSocketStreaming *(id<DONStreamingEventDelegate> vc) {
            return [App.client streamingViaWebsocketSubscribeChannels:@[DONStreamingChannelUser, DONStreamingChannelPublicLocal] delegate:vc];
        };
        homeLocalVC.dismissNotification = YES;
        [self.tabVC addTabViewItem:[NSTabViewItem tabViewItemWithViewController:homeLocalVC label:@"ホーム+ローカル"]];
        
        TimelineViewController *federatedVC = [[TimelineViewController alloc] init];
        federatedVC.timelineReloader = ^AnyPromise *(TimelineViewController *vc) {
            return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
                [App.client publicTimelineOnlyLocal:NO
                                            success:^(NSURLSessionDataTask * _Nonnull task, NSArray<DONStatus *> * _Nonnull results) {
                    resolver(results);
                }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    resolver(error);
                }];
            }];
        };
        federatedVC.streamingInitiator = ^DONWebSocketStreaming *(id<DONStreamingEventDelegate> vc) {
            return [App.client publicStreamingViaWebSocketWithDelegate:vc];
        };
        [self.tabVC addTabViewItem:[NSTabViewItem tabViewItemWithViewController:federatedVC label:@"連合"]];
    }
}

- (IBAction)newPost:(id)sender {
    [self.postbox focus];
}

#pragma mark - PostBox

- (IBAction)postMessage:(id)sender {
    self.postbox.posting = YES;
    PostBoxDraft *draft = self.postbox.draft;
    __block AnyPromise *promise = [AnyPromise promiseWithValue:@[]];
    [draft.pictures enumerateObjectsUsingBlock:^(DONPicture * _Nonnull picture, NSUInteger idx, BOOL * _Nonnull stop) {
        promise = promise.then(^(NSArray<NSNumber*>* mediaIds){
            return [AnyPromise promiseWithResolverBlock:^(PMKResolver _Nonnull resolve) {
                [App.client postMedia:picture description:nil success:^(NSURLSessionDataTask * _Nonnull task, NSNumber * _Nonnull mediaId) {
                    resolve([mediaIds arrayByAddingObject:mediaId]);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    resolve(error);
                }];
            }];
        });
    }];
    promise.then(^(NSArray<NSNumber*>* mediaIds) {
        return [AnyPromise promiseWithResolverBlock:^(PMKResolver _Nonnull resolve) {
            [App.client postStatus:[draft.message stringByReplacingLineBreaksWithString:@"\n"]
                           replyTo:nil
                          mediaIds:mediaIds
                         sensitive:draft.isSensitive
                       spoilerText:draft.spoilerText
                        visibility:draft.visibility
                           success:^(NSURLSessionDataTask * _Nonnull task, DONStatus * _Nonnull result) {
                resolve(result);
            }
                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                resolve(error);
            }];
        }];
    }).then(^(DONStatus *status) {
        [self.postbox clear];
        cct_mix_call_posted(status);
    }).catch(^(NSError *error) {
        WriteAFNetworkingErrorToLog(error);
    }).ensure(^{
        self.postbox.posting = NO;
        [self.postbox focus];
    });
}

#pragma mark - Delegate to ViewController

- (IBAction)reload:(id)sender {
    NSViewController *vc = self.tabVC.tabViewItems[self.tabVC.selectedTabViewItemIndex].viewController;
    if ([vc respondsToSelector:@selector(reload:)]) {
        [vc performSelector:@selector(reload:) withObject:sender];
    }
}

- (IBAction)toggleStreamingStatus:(id)sender {
    NSViewController *vc = self.tabVC.tabViewItems[self.tabVC.selectedTabViewItemIndex].viewController;
    if ([vc respondsToSelector:@selector(toggleStreamingStatus:)]) {
        [vc performSelector:@selector(toggleStreamingStatus:) withObject:sender];
    }
}

- (IBAction)togglePresentationMode:(id)sender {
    NSViewController *vc = self.tabVC.tabViewItems[self.tabVC.selectedTabViewItemIndex].viewController;
    if ([vc respondsToSelector:@selector(togglePresentationMode:)]) {
        [vc performSelector:@selector(togglePresentationMode:) withObject:sender];
    }
}

@end
