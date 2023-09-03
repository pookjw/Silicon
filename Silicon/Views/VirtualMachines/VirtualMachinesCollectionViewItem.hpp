//
//  VirtualMachinesCollectionViewItem.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import <Cocoa/Cocoa.h>
#import "VirtualMachineMacModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface VirtualMachinesCollectionViewItem : NSCollectionViewItem
- (void)configureWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
