//
//  EditVMSidebarSectionModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/6/23.
//

#import <Foundation/Foundation.h>
#import <concepts>
#import <variant>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSUInteger, EditVMSidebarSectionModelType) {
    EditVMSidebarSectionModelTypeDemo
};

@interface EditVMSidebarSectionModel : NSObject
@property (readonly, assign) EditVMSidebarSectionModelType sectionType;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSectionType:(EditVMSidebarSectionModelType)sectionType NS_DESIGNATED_INITIALIZER;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
