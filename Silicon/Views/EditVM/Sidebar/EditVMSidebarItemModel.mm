//
//  EditVMSidebarItemModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/7/23.
//

#import "EditVMSidebarItemModel.hpp"

@interface EditVMSidebarItemModel ()
@property (assign) EditVMSidebarItemModelType itemType;
@end

@implementation EditVMSidebarItemModel

- (instancetype)initWithItemType:(EditVMSidebarItemModelType)itemType {
    if (self = [super init]) {
        _itemType = itemType;
    }
    
    return self;
}

- (NSImage *)image {
    switch (_itemType) {
        case EditVMSidebarItemModelTypeAudio:
            return [NSImage imageWithSystemSymbolName:@"speaker.wave.3" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeGraphics:
            return [NSImage imageWithSystemSymbolName:@"display.2" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeKeyboards:
            return [NSImage imageWithSystemSymbolName:@"keyboard" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypePointingDevices:
            return [NSImage imageWithSystemSymbolName:@"computermouse" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeMemory:
            return [NSImage imageWithSystemSymbolName:@"memorychip" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeSharedDirectory:
            return [NSImage imageWithSystemSymbolName:@"folder" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeStorage:
            return [NSImage imageWithSystemSymbolName:@"opticaldiscdrive" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeConsoles:
            return [NSImage imageWithSystemSymbolName:@"gamecontroller" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeClipboard:
            return [NSImage imageWithSystemSymbolName:@"doc.on.clipboard" accessibilityDescription:nullptr];
        default:
            return [NSImage imageWithSystemSymbolName:@"questionmark.app" accessibilityDescription:nullptr];
    }
}

- (NSImage *)selectedImage {
    switch (_itemType) {
        case EditVMSidebarItemModelTypeAudio:
            return [NSImage imageWithSystemSymbolName:@"speaker.wave.3.fill" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeGraphics:
            return [NSImage imageWithSystemSymbolName:@"display.2" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeKeyboards:
            return [NSImage imageWithSystemSymbolName:@"keyboard.fill" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypePointingDevices:
            return [NSImage imageWithSystemSymbolName:@"computermouse.fill" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeMemory:
            return [NSImage imageWithSystemSymbolName:@"memorychip.fill" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeSharedDirectory:
            return [NSImage imageWithSystemSymbolName:@"folder.fill" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeStorage:
            return [NSImage imageWithSystemSymbolName:@"opticaldiscdrive.fill" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeConsoles:
            return [NSImage imageWithSystemSymbolName:@"gamecontroller.fill" accessibilityDescription:nullptr];
        case EditVMSidebarItemModelTypeClipboard:
            return [NSImage imageWithSystemSymbolName:@"doc.on.clipboard.fill" accessibilityDescription:nullptr];
        default:
            return [NSImage imageWithSystemSymbolName:@"questionmark.app.fill" accessibilityDescription:nullptr];
    }
}

- (NSString *)text {
    switch (_itemType) {
        case EditVMSidebarItemModelTypeAudio:
            return @"Audio";
        case EditVMSidebarItemModelTypeGraphics:
            return @"Displays";
        case EditVMSidebarItemModelTypeKeyboards:
            return @"Keyboard";
        case EditVMSidebarItemModelTypePointingDevices:
            return @"Mouse";
        case EditVMSidebarItemModelTypeMemory:
            return @"Memory";
        case EditVMSidebarItemModelTypeSharedDirectory:
            return @"Shared Folder";
        case EditVMSidebarItemModelTypeStorage:
            return @"Storage";
        case EditVMSidebarItemModelTypeConsoles:
            return @"Game Controllers";
        case EditVMSidebarItemModelTypeClipboard:
            return @"Clipboard";
        default:
            return @"Unknown";
    }
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        auto toCompare = static_cast<EditVMSidebarItemModel *>(other);
        return _itemType == toCompare->_itemType;
    }
}

- (NSUInteger)hash {
    return _itemType;
}

@end
