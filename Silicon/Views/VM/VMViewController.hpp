//
//  VMViewController.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import <Cocoa/Cocoa.h>
#import "VirtualMachineMacModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface VMViewController : NSViewController
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSNibName)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
