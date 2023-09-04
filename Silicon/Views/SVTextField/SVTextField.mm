//
//  SVTextField.m
//  Silicon
//
//  Created by Jinwoo Kim on 9/4/23.
//

#import "SVTextField.hpp"
#import <objc/message.h>

@implementation SVTextField

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)range
replacementString:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeTextInRange:replacementString:)]) {
        return [static_cast<id<SVTextFieldDelegate>>(self.delegate) textField:self shouldChangeTextInRange:range replacementString:string];
    } else {
        objc_super superInfo = { self, [self superclass] };
        return reinterpret_cast<BOOL (*)(objc_super *, SEL, id, NSRange, id)>(objc_msgSendSuper)(&superInfo, _cmd, textView, range, string);
    }
}

@end
