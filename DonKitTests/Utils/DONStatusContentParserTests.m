//
// Copyright (c) 2020 shibafu
//

#import <XCTest/XCTest.h>
#import "DONStatusContentParser.h"

@interface DONStatusContentParserTests : XCTestCase

@end

@implementation DONStatusContentParserTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSimply {
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:@"<p>hello world</p>"];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"hello world", parser.textContent);
}

- (void)testBreaks {
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:@"<p>hello<br>world</p>"];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"hello\nworld", parser.textContent);
}

- (void)testParagraphs {
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:@"<p>hello</p><p>new world</p>"];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"hello\n\nnew world", parser.textContent);
}

- (void)testSimplyJapanese {
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:@"<p>おはよう こんにちは　こんばんは</p>"];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"おはよう こんにちは　こんばんは", parser.textContent);
}

- (void)testTextOnly {
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:@"hello world"];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"hello world", parser.textContent);
}

- (void)testTextWithLineFeeds {
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:@"hello\nworld"];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"hello\nworld", parser.textContent);
}

- (void)testHasLink {
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:@"link is <a href=\"http://example.com/\">here</a>"];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"link is here", parser.textContent);
    XCTAssertEqual(1, parser.linkRanges.count);
    
    NSRange range = parser.linkRanges.firstObject.rangeValue;
    XCTAssertEqual(8, range.location);
    XCTAssertEqual(4, range.length);
}

- (void)testMiwpayou {
    // URLや改行がいい感じに入っているサンプル
    // https://miwkey.miwpayou0808.info/notes/8ibqretbdz
    NSString *ikipayo = @"<p><span>pgjones / quart · GitLab<br></span><a href=\"https://gitlab.com/pgjones/quart\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">https://gitlab.com/pgjones/quart</a><span><br>hae-</span></p>";
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:ikipayo];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"pgjones / quart · GitLab\nhttps://gitlab.com/pgjones/quart\nhae-", parser.textContent);
    XCTAssertEqual(1, parser.linkRanges.count);
}

- (void)testQuotedTextFromMisskey {
    // > quoted text
    // http://example.com
    // ----
    // https://misskey.io/notes/8igrplptqc
    NSString *text = @"<p></p><p><span>quoted text</span></p><a href=\"http://example.com\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">http://example.com</a><p></p>";
    __auto_type parser = [[DONStatusContentParser alloc] initWithString:text];
    XCTAssertTrue([parser parse]);
    XCTAssertEqualObjects(@"quoted text\n\nhttp://example.com", parser.textContent);
    XCTAssertEqual(1, parser.linkRanges.count);
}

@end
