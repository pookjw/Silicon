//
//  CreateVirtualMachineInstallationViewController.h
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import <Cocoa/Cocoa.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface CreateVirtualMachineInstallationViewController : NSViewController
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSNibName)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithIPSWURL:(NSURL *)ipswURL;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
