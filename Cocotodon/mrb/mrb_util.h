//
// Copyright (c) 2020 shibafu
//

#import <Foundation/Foundation.h>
#import <mruby.h>

NS_ASSUME_NONNULL_BEGIN

typedef mrb_value (^mrb_protect_body)(mrb_state *mrb);

mrb_value mrb_protect_with_block(mrb_state *mrb, mrb_protect_body body, mrb_bool *state);

NSString *exc2str(mrb_state *mrb, mrb_value exc);
void exc2log(mrb_state *mrb);

id ObjectFromMRubyValue(mrb_state *mrb, mrb_value value);

@interface NSObject (MRubyConverter)
- (mrb_value) mrubyValue:(mrb_state *)mrb;
@end

@interface NSString (MRubyConverter)
- (mrb_value) mrubyValue:(mrb_state *)mrb;
@end

@interface NSNumber (MRubyConverter)
- (mrb_value) mrubyValue:(mrb_state *)mrb;
@end

@interface NSArray (MRubyConverter)
- (mrb_value) mrubyValue:(mrb_state *)mrb;
@end

@interface NSDictionary (MRubyConverter)
- (mrb_value) mrubyValue:(mrb_state *)mrb;
@end

NS_ASSUME_NONNULL_END
