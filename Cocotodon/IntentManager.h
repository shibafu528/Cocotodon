//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^IntentCallback)(NSString *_Nonnull link);

#pragma mark -

@interface IntentHandler : NSObject

- (NSString*)label;

- (void)invokeWithLink:(NSString*)link;

@end

#pragma mark -

@interface IntentManager : NSObject

+ (instancetype)sharedManager;

- (void)registerHandlerWithRegex:(NSRegularExpression*)regex label:(NSString*)label usingBlock:(IntentCallback)block;

- (NSArray<IntentHandler*>*)candidatesForLink:(NSString*)link;

@end

NS_ASSUME_NONNULL_END
