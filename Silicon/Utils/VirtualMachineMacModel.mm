//
//  VirtualMachineMacModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import "VirtualMachineMacModel.hpp"
#import "VZMacHardwareModelValueTransformer.hpp"
#import "VZMacMachineIdentifierValueTransformer.hpp"
#import "VZMACAddressValueTransformer.hpp"

@implementation VirtualMachineMacModel

@dynamic createdDate;
@dynamic bundleURL;
@dynamic hardwareModel;
@dynamic axiliaryStorageURL;
@dynamic machineIdentifier;
@dynamic diskImageURL;
@dynamic displayWidthInPixels;
@dynamic displayHeightInPixels;
@dynamic displayPixelsForInch;
@dynamic MACAddress;

+ (NSEntityDescription *)_entity {
    [VZMacHardwareModelValueTransformer registerIfNeeded];
    [VZMacMachineIdentifierValueTransformer registerIfNeeded];
    [VZMACAddressValueTransformer registerIfNeeded];
    
    //
    
    NSEntityDescription *entity = [NSEntityDescription new];
    entity.name = NSStringFromClass(self);
    entity.managedObjectClassName = NSStringFromClass(self);
    
    //
    
    NSAttributeDescription *createdDateAttributeDescription = [NSAttributeDescription new];
    createdDateAttributeDescription.name = @"createdDate";
    createdDateAttributeDescription.optional = NO;
    createdDateAttributeDescription.attributeType = NSDateAttributeType;
    
    //
    
    NSAttributeDescription *bundleURLAttributeDescription = [NSAttributeDescription new];
    bundleURLAttributeDescription.name = @"bundleURL";
    bundleURLAttributeDescription.optional = NO;
    bundleURLAttributeDescription.attributeType = NSURIAttributeType;
    
    //
    
    NSAttributeDescription *hardwareModelAttributeDescription = [NSAttributeDescription new];
    hardwareModelAttributeDescription.name = @"hardwareModel";
    hardwareModelAttributeDescription.optional = NO;
    hardwareModelAttributeDescription.attributeType = NSTransformableAttributeType;
    hardwareModelAttributeDescription.allowsExternalBinaryDataStorage = YES;
    hardwareModelAttributeDescription.attributeValueClassName = NSStringFromClass(VZMacHardwareModel.class);
    hardwareModelAttributeDescription.valueTransformerName = NSStringFromClass(VZMacHardwareModelValueTransformer.class);
    
    //
    
    NSAttributeDescription *axiliaryStorageURLAttributeDescription = [NSAttributeDescription new];
    axiliaryStorageURLAttributeDescription.name = @"axiliaryStorageURL";
    axiliaryStorageURLAttributeDescription.optional = NO;
    axiliaryStorageURLAttributeDescription.attributeType = NSURIAttributeType;
    
    //
    
    NSAttributeDescription *machineIdentifierAttributeDescription = [NSAttributeDescription new];
    machineIdentifierAttributeDescription.name = @"machineIdentifier";
    machineIdentifierAttributeDescription.optional = NO;
    machineIdentifierAttributeDescription.attributeType = NSTransformableAttributeType;
    machineIdentifierAttributeDescription.allowsExternalBinaryDataStorage = YES;
    machineIdentifierAttributeDescription.attributeValueClassName = NSStringFromClass(VZMacMachineIdentifier.class);
    machineIdentifierAttributeDescription.valueTransformerName = NSStringFromClass(VZMacMachineIdentifierValueTransformer.class);
    
    //
    
    NSAttributeDescription *diskImageURLAttributeDescription = [NSAttributeDescription new];
    diskImageURLAttributeDescription.name = @"diskImageURL";
    diskImageURLAttributeDescription.optional = NO;
    diskImageURLAttributeDescription.attributeType = NSURIAttributeType;
    
    //
    
    NSAttributeDescription *displayWidthInPixelsAttributeDescription = [NSAttributeDescription new];
    displayWidthInPixelsAttributeDescription.name = @"displayWidthInPixels";
    displayWidthInPixelsAttributeDescription.optional = NO;
    displayWidthInPixelsAttributeDescription.attributeType = NSInteger16AttributeType;
    
    //
    
    NSAttributeDescription *displayHeightInPixelsAttributeDescription = [NSAttributeDescription new];
    displayHeightInPixelsAttributeDescription.name = @"displayHeightInPixels";
    displayHeightInPixelsAttributeDescription.optional = NO;
    displayHeightInPixelsAttributeDescription.attributeType = NSInteger16AttributeType;
    
    //
    
    NSAttributeDescription *displayPixelsForInchAttributeDescription = [NSAttributeDescription new];
    displayPixelsForInchAttributeDescription.name = @"displayPixelsForInch";
    displayPixelsForInchAttributeDescription.optional = NO;
    displayPixelsForInchAttributeDescription.attributeType = NSInteger16AttributeType;
    
    //
    
    NSAttributeDescription *MACAddressAttributeDescription = [NSAttributeDescription new];
    MACAddressAttributeDescription.name = @"MACAddress";
    MACAddressAttributeDescription.optional = NO;
    MACAddressAttributeDescription.attributeType = NSTransformableAttributeType;
    MACAddressAttributeDescription.attributeValueClassName = NSStringFromClass(VZMACAddress.class);
    MACAddressAttributeDescription.valueTransformerName = NSStringFromClass(VZMACAddressValueTransformer.class);
    
    //
    
    entity.properties = @[
        createdDateAttributeDescription,
        bundleURLAttributeDescription,
        hardwareModelAttributeDescription,
        axiliaryStorageURLAttributeDescription,
        machineIdentifierAttributeDescription,
        diskImageURLAttributeDescription,
        displayWidthInPixelsAttributeDescription,
        displayHeightInPixelsAttributeDescription,
        displayPixelsForInchAttributeDescription,
        MACAddressAttributeDescription
    ];
    
    [createdDateAttributeDescription release];
    [bundleURLAttributeDescription release];
    [hardwareModelAttributeDescription release];
    [axiliaryStorageURLAttributeDescription release];
    [machineIdentifierAttributeDescription release];
    [diskImageURLAttributeDescription release];
    [displayWidthInPixelsAttributeDescription release];
    [displayHeightInPixelsAttributeDescription release];
    [displayPixelsForInchAttributeDescription release];
    [MACAddressAttributeDescription release];
    
    return [entity autorelease];
}

@end
