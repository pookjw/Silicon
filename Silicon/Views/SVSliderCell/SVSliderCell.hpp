//
//  SVSliderCell.h
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import <Cocoa/Cocoa.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface SVSliderCell : NSSliderCell
@property (readonly, assign) double continuousDoubleValue;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
