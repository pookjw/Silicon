//
//  NSTextField+LabelStyle.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/20/23.
//

#import <Cocoa/Cocoa.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSTextField (LabelStyle)
- (void)applyLabelStyle;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
