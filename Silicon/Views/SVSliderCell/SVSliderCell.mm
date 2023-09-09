//
//  SVSliderCell.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import "SVSliderCell.hpp"

@interface SVSliderCell ()
@property (assign) double continuousDoubleValue;
@end

@implementation SVSliderCell

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView {
    BOOL result = [super continueTracking:lastPoint at:currentPoint inView:controlView];
    self.continuousDoubleValue = self.doubleValue;
    return result;
}

@end
