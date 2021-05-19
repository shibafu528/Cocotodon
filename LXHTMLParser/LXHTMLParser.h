//
// Copyright (c) 2021 shibafu
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// NSXMLParserの代替品。libxml2のHTMLparser APIを使ってドキュメントをパースし、NSXMLParserDelegateで結果を通知する。
/// エラーもNSXMLParserErrorDomainを借用して通知する。
@interface LXHTMLParser : NSObject

@property (nonatomic, nullable, weak) id<NSXMLParserDelegate> delegate;
@property (nonatomic, nullable) NSError *parserError;

- (instancetype)init __attribute__((unavailable("init is not available")));

- (nullable instancetype)initWithData:(NSData*)data;

- (BOOL)parse;

@end

NS_ASSUME_NONNULL_END
