//
//  VZMacHardwareModelValueTransformer.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VZMacHardwareModelValueTransformer.hpp"
#import <Virtualization/Virtualization.h>

@implementation VZMacHardwareModelValueTransformer

+ (BOOL)registerIfNeeded {
    if ([NSValueTransformer.valueTransformerNames containsObject:NSStringFromClass(self)]) {
        VZMacHardwareModelValueTransformer *transformer = [VZMacHardwareModelValueTransformer new];
        [NSValueTransformer setValueTransformer:transformer forName:NSStringFromClass(self)];
        [transformer release];
        
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return VZMacHardwareModel.class;
}

- (id)transformedValue:(id)value {
    return static_cast<VZMacHardwareModel *>(value).dataRepresentation;
}

- (id)reverseTransformedValue:(id)value {
    return [[[VZMacHardwareModel alloc] initWithDataRepresentation:value] autorelease];
}

@end
