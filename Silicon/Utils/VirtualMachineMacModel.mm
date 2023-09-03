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
@dynamic CPUCount;
@dynamic memorySize;
@dynamic MACAddress;
@dynamic diskImageURL;
@dynamic displayWidthInPixels;
@dynamic displayHeightInPixels;
@dynamic displayPixelsForInch;
@dynamic hardwareModel;
@dynamic axiliaryStorageURL;
@dynamic machineIdentifier;

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
    
    NSAttributeDescription *CPUCountAttributeDescription = [NSAttributeDescription new];
    CPUCountAttributeDescription.name = @"CPUCount";
    CPUCountAttributeDescription.optional = NO;
    CPUCountAttributeDescription.attributeType = NSInteger16AttributeType;
    
    //
    
    NSAttributeDescription *memorySizeAttributeDescription = [NSAttributeDescription new];
    memorySizeAttributeDescription.name = @"memorySize";
    memorySizeAttributeDescription.optional = NO;
    memorySizeAttributeDescription.attributeType = NSInteger64AttributeType;
    
    //
    
    NSAttributeDescription *MACAddressAttributeDescription = [NSAttributeDescription new];
    MACAddressAttributeDescription.name = @"MACAddress";
    MACAddressAttributeDescription.optional = NO;
    MACAddressAttributeDescription.attributeType = NSTransformableAttributeType;
    MACAddressAttributeDescription.attributeValueClassName = NSStringFromClass(VZMACAddress.class);
    MACAddressAttributeDescription.valueTransformerName = NSStringFromClass(VZMACAddressValueTransformer.class);
    
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
    
    entity.properties = @[
        createdDateAttributeDescription,
        bundleURLAttributeDescription,
        CPUCountAttributeDescription,
        memorySizeAttributeDescription,
        MACAddressAttributeDescription,
        diskImageURLAttributeDescription,
        displayWidthInPixelsAttributeDescription,
        displayHeightInPixelsAttributeDescription,
        displayPixelsForInchAttributeDescription,
        hardwareModelAttributeDescription,
        axiliaryStorageURLAttributeDescription,
        machineIdentifierAttributeDescription
    ];
    
    [createdDateAttributeDescription release];
    [bundleURLAttributeDescription release];
    [CPUCountAttributeDescription release];
    [memorySizeAttributeDescription release];
    [MACAddressAttributeDescription release];
    [diskImageURLAttributeDescription release];
    [displayWidthInPixelsAttributeDescription release];
    [displayHeightInPixelsAttributeDescription release];
    [displayPixelsForInchAttributeDescription release];
    [hardwareModelAttributeDescription release];
    [axiliaryStorageURLAttributeDescription release];
    [machineIdentifierAttributeDescription release];
    
    return [entity autorelease];
}

- (VZVirtualMachineConfiguration * _Nullable)virtualMachineConfigurationWithError:(NSError * _Nullable *)error {
    VZVirtualMachineConfiguration *virtualMachineConfiguration = [VZVirtualMachineConfiguration new];
    [virtualMachineConfiguration autorelease];
    
    VZMacOSBootLoader *bootLoader = [[VZMacOSBootLoader alloc] init];
    virtualMachineConfiguration.bootLoader = bootLoader;
    [bootLoader release];
    
    virtualMachineConfiguration.CPUCount = self.CPUCount.unsignedIntegerValue;
    virtualMachineConfiguration.memorySize = self.memorySize.unsignedLongLongValue;
    
    VZVirtioNetworkDeviceConfiguration *networkConfiguration = [[VZVirtioNetworkDeviceConfiguration alloc] init];
    VZNATNetworkDeviceAttachment *networkAttachment = [[VZNATNetworkDeviceAttachment alloc] init];
    networkConfiguration.attachment = networkAttachment;
    [networkAttachment release];
    networkConfiguration.MACAddress = self.MACAddress;
    virtualMachineConfiguration.networkDevices = @[networkConfiguration];
    [networkConfiguration release];
    
    VZDiskImageStorageDeviceAttachment *storageDeviceAttachment = [[VZDiskImageStorageDeviceAttachment alloc] initWithURL:self.diskImageURL
                                                                                                                 readOnly:NO
                                                                                                              cachingMode:VZDiskImageCachingModeAutomatic
                                                                                                      synchronizationMode:VZDiskImageSynchronizationModeNone
                                                                                                                    error:error];
    [storageDeviceAttachment autorelease];
    if (*error) {
        return nullptr;
    }
    
    VZVirtioBlockDeviceConfiguration *storageDeviceConfiguration = [[VZVirtioBlockDeviceConfiguration alloc] initWithAttachment:storageDeviceAttachment];
    virtualMachineConfiguration.storageDevices = @[storageDeviceConfiguration];
    [storageDeviceConfiguration release];
    
    //
    
    VZMacGraphicsDeviceConfiguration *graphicsDeviceConfiguration = [[VZMacGraphicsDeviceConfiguration alloc] init];
    VZMacGraphicsDisplayConfiguration *graphicsDisplayConfiguration = [[VZMacGraphicsDisplayConfiguration alloc] initWithWidthInPixels:self.displayWidthInPixels.integerValue
                                                                                                                        heightInPixels:self.displayHeightInPixels.integerValue
                                                                                                                         pixelsPerInch:self.displayPixelsForInch.integerValue];
    graphicsDeviceConfiguration.displays = @[graphicsDisplayConfiguration];
    [graphicsDisplayConfiguration release];
    virtualMachineConfiguration.graphicsDevices = @[graphicsDeviceConfiguration];
    [graphicsDeviceConfiguration release];
    
    //
    
    VZMacAuxiliaryStorage *auxiliaryStorage = [[VZMacAuxiliaryStorage alloc] initWithContentsOfURL:self.axiliaryStorageURL];
    
    VZMacPlatformConfiguration *platformConfiguration = [[VZMacPlatformConfiguration alloc] init];
    platformConfiguration.hardwareModel = self.hardwareModel;
    platformConfiguration.auxiliaryStorage = auxiliaryStorage;
    [auxiliaryStorage release];
    platformConfiguration.machineIdentifier = self.machineIdentifier;
    
    virtualMachineConfiguration.platform = platformConfiguration;
    [platformConfiguration release];
    
    return virtualMachineConfiguration;
}

- (void)setPropertiesFromVirtualMachineConfiguration:(VZVirtualMachineConfiguration *)virtualMachineConfiguration {
    self.CPUCount = @(virtualMachineConfiguration.CPUCount);
    self.memorySize = @(virtualMachineConfiguration.memorySize);
    self.MACAddress = static_cast<VZVirtioNetworkDeviceConfiguration *>(virtualMachineConfiguration.networkDevices.firstObject).MACAddress;
    self.diskImageURL = static_cast<VZDiskImageStorageDeviceAttachment *>(static_cast<VZVirtioBlockDeviceConfiguration *>(virtualMachineConfiguration.storageDevices.firstObject).attachment).URL;
    
    VZMacGraphicsDisplayConfiguration *graphicsDisplayConfiguration = static_cast<VZMacGraphicsDeviceConfiguration *>(virtualMachineConfiguration.graphicsDevices.firstObject).displays.firstObject;
    
    self.displayWidthInPixels = @(graphicsDisplayConfiguration.widthInPixels);
    self.displayHeightInPixels = @(graphicsDisplayConfiguration.heightInPixels);
    self.displayPixelsForInch = @(graphicsDisplayConfiguration.pixelsPerInch);
    
    VZMacPlatformConfiguration *platform = static_cast<VZMacPlatformConfiguration *>(virtualMachineConfiguration.platform);
    self.hardwareModel = platform.hardwareModel;
    self.axiliaryStorageURL = platform.auxiliaryStorage.URL;
    self.machineIdentifier = platform.machineIdentifier;
}

@end
