//
//  EditVMSidebarViewController.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/5/23.
//

#import <Cocoa/Cocoa.h>
#import "EditVMSidebarItemModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class EditVMSidebarViewController;
@protocol EditVMSidebarViewControllerDelegate <NSObject>
- (void)editVMSidebarViewController:(EditVMSidebarViewController *)viewController didSelectItemModel:(EditVMSidebarItemModel * _Nullable)itemModel;
@end

@interface EditVMSidebarViewController : NSViewController
@property (readonly, retain) EditVMSidebarItemModel *selectedItemModel;
@property (assign) id<EditVMSidebarViewControllerDelegate> delegate;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
