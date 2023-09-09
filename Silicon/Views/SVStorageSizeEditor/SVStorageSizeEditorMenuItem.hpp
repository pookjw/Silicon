//
//  SVStorageSizeEditorMenuItem.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import <Cocoa/Cocoa.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface SVStorageSizeEditorMenuItem : NSMenuItem
@property (readonly, copy) NSUnitInformationStorage *storageUnit;
- (instancetype)initWithTitle:(NSString *)string action:(nullable SEL)selector keyEquivalent:(NSString *)charCode NS_UNAVAILABLE;
- (instancetype)initWithStorageUnit:(NSUnitInformationStorage *)storageUnit action:(nullable SEL)selector keyEquivalent:(NSString *)charCode;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
