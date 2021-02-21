//
// Copyright (c) 2021 shibafu
//

#import "MainViewController.h"
#import "PostBox.h"
#import "NSString+ReplaceLineBreaks.h"
#import "TimelineViewController.h"

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
    // Do view setup here.
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
        homeVC.streamingInitiator = ^DONWebSocketStreaming *(TimelineViewController<DONStreamingEventDelegate> *vc) {
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
        localVC.streamingInitiator = ^DONWebSocketStreaming *(TimelineViewController<DONStreamingEventDelegate> *vc) {
            return [App.client localPublicStreamingViaWebSocketWithDelegate:vc];
        };
        [self.tabVC addTabViewItem:[NSTabViewItem tabViewItemWithViewController:localVC label:@"ローカル"]];
        
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
        federatedVC.streamingInitiator = ^DONWebSocketStreaming *(TimelineViewController<DONStreamingEventDelegate> *vc) {
            return [App.client publicStreamingViaWebSocketWithDelegate:vc];
        };
        [self.tabVC addTabViewItem:[NSTabViewItem tabViewItemWithViewController:federatedVC label:@"連合"]];
    }
}

#pragma mark - PostBox

- (IBAction)postMessage:(id)sender {
    __block AnyPromise *promise = [AnyPromise promiseWithValue:@[]];
    [self.postbox.pictures enumerateObjectsUsingBlock:^(DONPicture * _Nonnull picture, NSUInteger idx, BOOL * _Nonnull stop) {
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
            [App.client postStatus:[self.postbox.message stringByReplacingLineBreaksWithString:@"\n"]
                           replyTo:nil
                          mediaIds:mediaIds
                         sensitive:NO
                       spoilerText:nil
                        visibility:self.postbox.visibility
                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                resolve(nil);
            }
                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                resolve(error);
            }];
        }];
    }).then(^{
        [self.postbox clear];
    }).catch(^(NSError *error) {
        WriteAFNetworkingErrorToLog(error);
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
