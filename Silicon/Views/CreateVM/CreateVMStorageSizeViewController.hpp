//
//  CreateVMStorageSizeViewController.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/4/23.
//

#import <Cocoa/Cocoa.h>
#import <cinttypes>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class CreateVMStorageSizeViewController;
@protocol CreateVirtualMachineStorageSizeViewControllerDelegate <NSObject>
- (void)createVirtualMachineStorageSizeViewController:(CreateVMStorageSizeViewController *)viewController didChangeStorageSize:(std::uint64_t)storageSize;
@end

@interface CreateVMStorageSizeViewController : NSViewController
@property (readonly, nonatomic) std::uint64_t storageSize;
@property (assign) id<CreateVirtualMachineStorageSizeViewControllerDelegate> delegate;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
