//
// Copyright (c) 2020 shibafu
//

#import "DONStatusContentParser.h"
#import "LXHTMLParser.h"

@interface DONStatusContentParser () <NSXMLParserDelegate>

@property (nonatomic) LXHTMLParser *parser;
@property (nonatomic) NSInteger linkBegin;
@property (nonatomic) NSString *linkRef;
@property (nonatomic) BOOL insertLineSpacing;

@property (nonatomic, readwrite) NSMutableString *textContent;
@property (nonatomic, readwrite) NSMutableArray<DONStatusContentAnchor*> *anchors;

@end

@implementation DONStatusContentParser

- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        string = [NSString stringWithFormat:@"<div>%@</div>", [string stringByReplacingOccurrencesOfString:@"\u00A0" withString:@" "]];
        
        _parser = [[LXHTMLParser alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        _parser.delegate = self;
        _textContent = [NSMutableString string];
        _anchors = [NSMutableArray array];
        _linkBegin = -1;
    }
    return self;
}

- (BOOL)parse {
    return [self.parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    [self insertLineSpacingIfNeeded];
    if ([elementName isEqualToString:@"br"]) {
        [_textContent appendString:@"\n"];
    } else if ([elementName isEqualToString:@"a"]) {
        _linkBegin = _textContent.length;
        _linkRef = attributeDict[@"href"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"a"] && _linkBegin > -1) {
        NSRange range = NSMakeRange(_linkBegin, _textContent.length - _linkBegin);
        [_anchors addObject:[[DONStatusContentAnchor alloc] initWithRange:range href:_linkRef]];
        _linkBegin = -1;
        _linkRef = nil;
    } else if ([elementName isEqualToString:@"p"]) {
        _insertLineSpacing = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self insertLineSpacingIfNeeded];
    [_textContent appendString:string];
}

- (void)insertLineSpacingIfNeeded {
    if (_insertLineSpacing) {
        if (_textContent.length) {
            [_textContent appendString:@"\n\n"];
        }
        _insertLineSpacing = NO;
    }
}

@end
