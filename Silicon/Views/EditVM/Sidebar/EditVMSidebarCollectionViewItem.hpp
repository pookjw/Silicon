//
//  EditVMSidebarCollectionViewItem.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/7/23.
//

#import <Cocoa/Cocoa.h>
#import "EditVMSidebarItemModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface EditVMSidebarCollectionViewItem : NSCollectionViewItem
- (void)configureWithItemModel:(EditVMSidebarItemModel *)itemModel;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
