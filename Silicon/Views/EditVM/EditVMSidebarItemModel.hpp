//
//  EditVMSidebarItemModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/7/23.
//

#import <Cocoa/Cocoa.h>

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
@property (readonly, nonatomic) NSImage *image;
@property (readonly, nonatomic) NSString *text;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithItemType:(EditVMSidebarItemModelType)itemType NS_DESIGNATED_INITIALIZER;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
