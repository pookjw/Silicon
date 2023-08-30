//
//  VirtualMachineModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import "VirtualMachineModel.hpp"

@implementation VirtualMachineModel

@dynamic bundleURL;

+ (NSEntityDescription *)_entity {
    NSEntityDescription *entity = [NSEntityDescription new];
    entity.name = NSStringFromClass(self);
    entity.managedObjectClassName = NSStringFromClass(self);
    
    NSAttributeDescription *bundleURLAttributeDescription = [NSAttributeDescription new];
    bundleURLAttributeDescription.name = @"bundleURL";
    bundleURLAttributeDescription.optional = NO;
    bundleURLAttributeDescription.attributeType = NSURIAttributeType;
    
    entity.properties = @[bundleURLAttributeDescription];
    [bundleURLAttributeDescription release];
    
    return [entity autorelease];
}

@end
