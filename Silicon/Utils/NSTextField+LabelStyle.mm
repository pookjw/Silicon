//
//  NSTextField+LabelStyle.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/20/23.
//

#import "NSTextField+LabelStyle.hpp"

@implementation NSTextField (LabelStyle)

- (void)applyLabelStyle {
    self.editable = NO;
    self.selectable = NO;
    self.bezeled = NO;
    self.preferredMaxLayoutWidth = 0.f;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.drawsBackground = NO;
}

@end
