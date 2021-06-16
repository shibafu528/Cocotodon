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
    [self setReplyTo:status withHeader:[@"@" stringByAppendingString:status.account.fullAcct] footer:nil];
}

-(void)setReplyTo:(DONStatus *)status withHeader:(NSString *)header footer:(NSString *)footer {
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
    self.postbox.message = input;
    self.postbox.visibility = status.visibility;
    
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
    self.postbox.message = input;
    
    // focus
    [self.postbox focus];
    [self.postbox setSelectedRange: NSMakeRange(input.length, 0)];
}

#pragma mark - Postbox

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
                           replyTo:self.replyToStatus.identity
                          mediaIds:mediaIds
                         sensitive:self.postbox.sensitive
                       spoilerText:self.postbox.spoilerText
                        visibility:self.postbox.visibility
                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                resolve(nil);
            }
                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                resolve(error);
            }];
        }];
    }).then(^{
        [self.view.window close];
    }).catch(^(NSError *error) {
        WriteAFNetworkingErrorToLog(error);
    });
}

@end
