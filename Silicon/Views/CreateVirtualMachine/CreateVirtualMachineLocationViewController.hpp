//
//  CreateVirtualMachineLocationViewController.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import <Cocoa/Cocoa.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class CreateVirtualMachineLocationViewController;
@protocol CreateVirtualMachineLocationViewControllerDelegate <NSObject>
- (void)locationViewControllerCreateNewVirtualMachine:(CreateVirtualMachineLocationViewController *)viewController;
- (void)locationViewController:(CreateVirtualMachineLocationViewController *)viewController didSelectLocalBundleURL:(NSURL *)localBundleURL;
@end

@interface CreateVirtualMachineLocationViewController : NSViewController
@property (assign) id<CreateVirtualMachineLocationViewControllerDelegate> delegate;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
