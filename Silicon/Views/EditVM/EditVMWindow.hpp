//
//  EditVMWindow.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/4/23.
//

#import <Cocoa/Cocoa.h>
#import "VirtualMachineMacModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface EditVMWindow : NSWindow
- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
