//
//  EditVMStorageViewController.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import <Cocoa/Cocoa.h>
#import "VirtualMachineMacModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface EditVMStorageViewController : NSViewController
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSNibName)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel NS_DESIGNATED_INITIALIZER;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
