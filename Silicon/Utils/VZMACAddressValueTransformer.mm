//
//  VZMACAddressValueTransformer.m
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VZMACAddressValueTransformer.hpp"
#import <Virtualization/Virtualization.h>

@implementation VZMACAddressValueTransformer

+ (BOOL)registerIfNeeded {
    if ([NSValueTransformer.valueTransformerNames containsObject:NSStringFromClass(self)]) {
        VZMACAddressValueTransformer *transformer = [VZMACAddressValueTransformer new];
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
    return VZMACAddress.class;
}

- (id)transformedValue:(id)value {
    return [static_cast<VZMACAddress *>(value).string dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)reverseTransformedValue:(id)value {
    NSString *string = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    VZMACAddress *result = [[VZMACAddress alloc] initWithString:string];
    [string release];
    
    return [result autorelease];
}

@end
