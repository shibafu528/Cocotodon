//
// Copyright (c) 2021 shibafu
//

#import "LXHTMLParser.h"
@import libxml2.HTMLparser;

#pragma mark - C Callback

#define SELF(ctx) ((__bridge LXHTMLParser*) ctx)

static void LXHTMLParser_start_element_callback(void *ctx, const xmlChar* name, const xmlChar** attrs) {
    LXHTMLParser *self = SELF(ctx);
    if ([self.delegate respondsToSelector:@selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)]) {
        NSString *nsName = [NSString stringWithUTF8String:(const char*)name];
        NSMutableDictionary *nsAttrs = [NSMutableDictionary dictionary];
        if (attrs) {
            for (int i = 0; attrs[i]; i += 2) {
                nsAttrs[[NSString stringWithUTF8String:(const char*)attrs[i]]] = [NSString stringWithUTF8String:(const char*)attrs[i + 1]];
            }
        }
        [self.delegate parser:(NSXMLParser*)self didStartElement:nsName namespaceURI:nil qualifiedName:nil attributes:nsAttrs];
    }
}

static void LXHTMLParser_end_element_callback(void *ctx, const xmlChar* name) {
    LXHTMLParser *self = SELF(ctx);
    if ([self.delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)]) {
        NSString *nsName = [NSString stringWithUTF8String:(const char*)name];
        [self.delegate parser:(NSXMLParser*)self didEndElement:nsName namespaceURI:nil qualifiedName:nil];
    }
}

static void LXHTMLParser_characters_callback(void *ctx, const xmlChar* ch, int len) {
    LXHTMLParser *self = SELF(ctx);
    if ([self.delegate respondsToSelector:@selector(parser:foundCharacters:)]) {
        NSString *nsCh = [NSString stringWithUTF8String:(const char*)ch];
        [self.delegate parser:(NSXMLParser*)self foundCharacters:nsCh];
    }
}

#pragma mark - Class

@interface LXHTMLParser ()

@property (nonatomic) htmlParserCtxtPtr context;
@property (nonatomic) htmlSAXHandler handler;
@property (nonatomic) NSData *data;

@end

@implementation LXHTMLParser

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        _delegate = nil;
        _parserError = nil;
        _data = data;
        
        memset(&_handler, 0, sizeof(htmlSAXHandler));
        _handler.startElement = LXHTMLParser_start_element_callback;
        _handler.endElement = LXHTMLParser_end_element_callback;
        _handler.characters = LXHTMLParser_characters_callback;
        
        _context = htmlCreatePushParserCtxt(&_handler, (__bridge void*)self, NULL, 0, NULL, XML_CHAR_ENCODING_UTF8);
        if (_context == NULL) {
            return nil;
        }
        htmlCtxtUseOptions(_context, XML_PARSE_RECOVER | XML_PARSE_NONET);
    }
    return self;
}

- (void)dealloc {
    htmlFreeParserCtxt(_context);
}

- (BOOL)parse {
    int ret = htmlParseChunk(self.context, self.data.bytes, (int) self.data.length, 1);
    if (ret == XML_ERR_OK) {
        self.parserError = nil;
        return YES;
    } else {
        self.parserError = [NSError errorWithDomain:NSXMLParserErrorDomain code:ret userInfo:nil];
        return NO;
    }
}

@end
