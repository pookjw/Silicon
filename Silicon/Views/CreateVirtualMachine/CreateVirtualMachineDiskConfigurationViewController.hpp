//
//  CreateVirtualMachineDiskConfigurationViewController.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/4/23.
//

#import <Cocoa/Cocoa.h>
#import <cinttypes>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class CreateVirtualMachineDiskConfigurationViewController;
@protocol CreateVirtualMachineDiskConfigurationViewControllerDelegate <NSObject>
- (void)createVirtualMachineDiskConfigurationViewController:(CreateVirtualMachineDiskConfigurationViewController *)diskConfigurationViewController didChangeStorageSize:(std::uint64_t)storageSize;
@end

@interface CreateVirtualMachineDiskConfigurationViewController : NSViewController
@property (nonatomic) std::uint64_t storageSize;
@property (assign) id<CreateVirtualMachineDiskConfigurationViewControllerDelegate> delegate;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
