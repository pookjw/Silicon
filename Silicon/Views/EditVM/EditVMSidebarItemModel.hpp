//
//  EditVMSidebarItemModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/7/23.
//

#import <Foundation/Foundation.h>
#import <memory>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSUInteger, EditVMSidebarItemModelType) {
    EditVMSidebarItemModelTypeAudio,
    EditVMSidebarItemModelTypeGraphics,
    EditVMSidebarItemModelTypeKeyboards,
    EditVMSidebarItemModelTypePointingDevices,
    EditVMSidebarItemModelTypeMemory,
    EditVMSidebarItemModelTypeNetwork,
    EditVMSidebarItemModelTypeSharedDirectory,
    EditVMSidebarItemModelTypeStorage,
    EditVMSidebarItemModelTypeConsoles,
    EditVMSidebarItemModelTypeClipboard
};

@interface EditVMSidebarItemModel : NSObject
@property (readonly, assign) EditVMSidebarItemModelType itemType;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithItemType:(EditVMSidebarItemModelType)itemType NS_DESIGNATED_INITIALIZER;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
