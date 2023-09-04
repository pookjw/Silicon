//
//  SVTextField.h
//  Silicon
//
//  Created by Jinwoo Kim on 9/4/23.
//

#import <Cocoa/Cocoa.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class SVTextField;
@protocol SVTextFieldDelegate <NSTextFieldDelegate>
@optional - (BOOL)textField:(SVTextField *)textField shouldChangeTextInRange:(NSRange)range replacementString:(NSString *)string;
@end

@interface SVTextField : NSTextField
@end

NS_HEADER_AUDIT_END(nullability, sendability)
