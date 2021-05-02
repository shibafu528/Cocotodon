//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

static inline void WriteAFNetworkingErrorToLog(NSError *error) {
    NSData* data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (data) {
        NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", body);
    }
}
