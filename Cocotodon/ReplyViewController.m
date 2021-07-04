//
// Copyright (c) 2020 shibafu
//

#import "ReplyViewController.h"
#import "PostBox.h"
#import "NSString+ReplaceLineBreaks.h"

@interface ReplyViewController () <NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSView *replyToView;
@property (nonatomic, weak) IBOutlet NSTextField *replyToAcct;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *replyToContent;
@property (nonatomic, weak) IBOutlet PostBox *postbox;

@property (nonatomic) DONStatus *replyToStatus;

@end

@implementation ReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.postbox.borderStyle = PostBoxBorderStyleRect;
}

#pragma mark - Setter

-(void)setReplyToAndAutoPopulate:(DONStatus *)status {
    [self setReplyTo:status withSpoilerText:status.spoilerText header:[@"@" stringByAppendingString:status.account.fullAcct] footer:nil];
}

-(void)setReplyTo:(DONStatus *)status withHeader:(NSString *)header footer:(NSString *)footer {
    [self setReplyTo:status withSpoilerText:nil header:header footer:footer];
}

- (void)setReplyTo:(DONStatus *)status withSpoilerText:(NSString *)spoilerText header:(NSString *)header footer:(NSString *)footer {
    self.replyToStatus = status;
    self.replyToAcct.stringValue = status.account.fullAcct;
    [self.replyToContent setString:status.expandContent];
    
    // initial input
    NSMutableString *input = [NSMutableString string];
    if (header.length) {
        [input appendString:header];
        [input appendString:@" "];
    }
    if (footer.length) {
        [input appendString:footer];
    }
    PostBoxDraft *draft = [[PostBoxDraft alloc] init];
    draft.message = input;
    draft.spoilerText = spoilerText;
    draft.visibility = status.visibility;
    self.postbox.draft = draft;
    
    // focus
    [self.postbox focus];
    [self.postbox setSelectedRange: NSMakeRange(input.length, 0)];
}

- (void)setHeader:(NSString *)header andFooter:(NSString *)footer {
    // clear reply to
    self.replyToView.hidden = YES;
    self.replyToAcct.stringValue = @"";
    self.replyToContent.string = @"";
    
    // initial input
    NSMutableString *input = [NSMutableString string];
    if (header.length) {
        [input appendString:header];
        [input appendString:@" "];
    }
    if (footer.length) {
        [input appendString:footer];
    }
    PostBoxDraft *draft = [[PostBoxDraft alloc] init];
    draft.message = input;
    self.postbox.draft = draft;
    
    // focus
    [self.postbox focus];
    [self.postbox setSelectedRange: NSMakeRange(input.length, 0)];
}

#pragma mark - Postbox

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
                           replyTo:self.replyToStatus.identity
                          mediaIds:mediaIds
                         sensitive:draft.sensitive
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
        [self.view.window close];
        cct_mix_call_posted(status);
    }).catch(^(NSError *error) {
        WriteAFNetworkingErrorToLog(error);
    }).ensure(^{
        self.postbox.posting = NO;
    });
}

@end
