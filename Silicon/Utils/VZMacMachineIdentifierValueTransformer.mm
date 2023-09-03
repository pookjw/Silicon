//
//  VZMacMachineIdentifierValueTransformer.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VZMacMachineIdentifierValueTransformer.hpp"
#import <Virtualization/Virtualization.h>

@implementation VZMacMachineIdentifierValueTransformer

+ (BOOL)registerIfNeeded {
    if ([NSValueTransformer.valueTransformerNames containsObject:NSStringFromClass(self)]) {
        VZMacMachineIdentifierValueTransformer *transformer = [VZMacMachineIdentifierValueTransformer new];
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
    return VZMacMachineIdentifier.class;
}

- (id)transformedValue:(id)value {
    return static_cast<VZMacMachineIdentifier *>(value).dataRepresentation;
}

- (id)reverseTransformedValue:(id)value {
    return [[[VZMacMachineIdentifier alloc] initWithDataRepresentation:value] autorelease];
}

@end
