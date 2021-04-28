//
// Copyright (c) 2021 shibafu
//

#import "IntentManager.h"

#pragma mark - IntentHandler

@interface IntentHandler ()

@property (nonatomic) NSRegularExpression *regex;
@property (nonatomic) NSString *label;
@property (nonatomic) IntentCallback callback;

@end

@implementation IntentHandler

- (NSString *)label {
    return _label;
}

- (void)invokeWithLink:(NSString *)link {
    _callback(link);
}

@end

#pragma mark - IntentManager

@interface IntentManager ()

@property (nonatomic) NSMutableArray<IntentHandler*> *handlers;

@end

@implementation IntentManager

+ (instancetype)sharedManager {
    static IntentManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[IntentManager alloc] init];
        [shared registerHandlerWithRegex:[NSRegularExpression regularExpressionWithPattern:@"\\Ahttps?://" options:0 error:nil]
                                   label:@"ブラウザで開く"
                              usingBlock:^(NSString* link) {
            [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:link]];
        }];
    });
    return shared;
}

- (instancetype)init
{
    if (self = [super init]) {
        _handlers = [NSMutableArray array];
    }
    return self;
}

- (void)registerHandlerWithRegex:(NSRegularExpression *)regex label:(nonnull NSString *)label usingBlock:(IntentCallback)block {
    IntentHandler *handler = [[IntentHandler alloc] init];
    handler.regex = regex;
    handler.label = label;
    handler.callback = block;
    [self.handlers addObject:handler];
}

- (NSArray<IntentHandler *> *)candidatesForLink:(NSString *)link {
    NSMutableArray<IntentHandler *> *result = [NSMutableArray array];
    [self.handlers enumerateObjectsUsingBlock:^(IntentHandler * _Nonnull handler, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([handler.regex numberOfMatchesInString:link options:0 range:NSMakeRange(0, link.length)]) {
            [result addObject:handler];
        }
    }];
    return result;
}

@end
