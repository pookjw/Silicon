//
//  SVStorageSizeEditorMenuItem.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import "SVStorageSizeEditorMenuItem.hpp"

@interface SVStorageSizeEditorMenuItem ()
@property (copy) NSUnitInformationStorage *storageUnit;
@end

@implementation SVStorageSizeEditorMenuItem

- (instancetype)initWithStorageUnit:(NSUnitInformationStorage *)storageUnit action:(SEL)selector keyEquivalent:(NSString *)charCode {
    NSString *title;
    if ([storageUnit isEqual:NSUnitInformationStorage.gigabytes]) {
        title = @"GB";
    } else if ([storageUnit isEqual:NSUnitInformationStorage.gibibytes]) {
        title = @"GiB";
    } else if ([storageUnit isEqual:NSUnitInformationStorage.terabytes]) {
        title = @"TB";
    } else if ([storageUnit isEqual:NSUnitInformationStorage.tebibytes]) {
        title = @"TiB";
    } else {
        title = [NSString string];
    }
    
    if (self = [super initWithTitle:title action:selector keyEquivalent:charCode]) {
        self.storageUnit = storageUnit;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.storageUnit = [coder decodeObjectForKey:@"SVStorageSizeEditorMenuItem.storageUnit"];
    }
    
    return self;
}

- (void)dealloc {
    [_storageUnit release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.storageUnit forKey:@"SVStorageSizeEditorMenuItem.storageUnit"];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    auto copy = static_cast<decltype(self)>([super copyWithZone:zone]);
    
    if (copy) {
        copy->_storageUnit = [_storageUnit copyWithZone:zone];
    }
    
    return copy;
}

@end
