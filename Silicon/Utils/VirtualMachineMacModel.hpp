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
@property (assign) NSDate *createdDate;
@property (assign) NSURL *bundleURL;
@property (assign) VZMacHardwareModel *hardwareModel;
@property (assign) NSURL *axiliaryStorageURL;
@property (assign) VZMacMachineIdentifier *machineIdentifier;
@property (assign) NSURL *diskImageURL;
@property (assign) NSNumber *displayWidthInPixels;
@property (assign) NSNumber *displayHeightInPixels;
@property (assign) NSNumber *displayPixelsForInch;
@property (assign) VZMACAddress *MACAddress;
+ (NSEntityDescription *)_entity;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
