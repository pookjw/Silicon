//
//  VirtualMachineMacModel.h
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import <CoreData/CoreData.h>
#import <Virtualization/Virtualization.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface VirtualMachineMacModel : NSManagedObject
@property (class) int tmp_fd;
@property (assign) NSDate *createdDate;
@property (assign) NSURL *bundleURL;

@property (assign) NSNumber *CPUCount;
@property (assign) NSNumber *memorySize;

@property (assign) VZMACAddress *MACAddress;

@property (assign) NSURL *diskImageURL;

@property (assign) NSNumber *displayWidthInPixels;
@property (assign) NSNumber *displayHeightInPixels;
@property (assign) NSNumber *displayPixelsForInch;

@property (assign) VZMacHardwareModel *hardwareModel;
@property (assign) NSURL *axiliaryStorageURL;
@property (assign) VZMacMachineIdentifier *machineIdentifier;

+ (NSEntityDescription *)_entity;

- (VZVirtualMachineConfiguration * _Nullable)virtualMachineConfigurationWithError:(NSError * _Nullable *)error;
- (void)setPropertiesFromVirtualMachineConfiguration:(VZVirtualMachineConfiguration *)virtualMachineConfiguration;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
