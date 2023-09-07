//
//  EditVMSidebarSectionModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/6/23.
//

#import "EditVMSidebarSectionModel.hpp"

@interface EditVMSidebarSectionModel ()
@property (assign) EditVMSidebarSectionModelType sectionType;
@end

@implementation EditVMSidebarSectionModel

- (instancetype)initWithSectionType:(EditVMSidebarSectionModelType)sectionType {
    if (self = [super init]) {
        _sectionType = EditVMSidebarSectionModelTypeDemo;
    }
    
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        auto toCompare = static_cast<EditVMSidebarSectionModel *>(other);
        return _sectionType == toCompare->_sectionType;
    }
}

- (NSUInteger)hash {
    return _sectionType;
}

@end
