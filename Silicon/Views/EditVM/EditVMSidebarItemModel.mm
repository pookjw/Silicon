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
    
}

- (NSString *)text

@end
