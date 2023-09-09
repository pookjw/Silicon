//
//  SVStorageSizeEditor.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import <Cocoa/Cocoa.h>
#import <cinttypes>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface SVStorageSizeEditor : NSControl <NSCoding>
@property (assign, nonatomic) std::uint64_t storageSize;
@property (copy, nonatomic) NSArray<NSUnitInformationStorage *> *storageUnits;
@property (copy, nonatomic) NSUnitInformationStorage *selectedStorageUnit;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
