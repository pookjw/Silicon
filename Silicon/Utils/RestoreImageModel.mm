//
//  RestoreImageModel.m
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "RestoreImageModel.hpp"

@implementation RestoreImageModel

@dynamic versions;
@dynamic URL;

+ (NSEntityDescription *)entity {
    NSEntityDescription *entity = [NSEntityDescription new];
    entity.name = NSStringFromClass(self);
    entity.managedObjectClassName = NSStringFromClass(self);
    
    //
    
    NSAttributeDescription *buildVersionDescription = [NSAttributeDescription new];
    buildVersionDescription.name = _RestoreImageModel::versionKeys::buildVersionKey;
    buildVersionDescription.optional = NO;
    buildVersionDescription.attributeType = NSStringAttributeType;
    
    NSAttributeDescription *majorVersionDescription = [NSAttributeDescription new];
    buildVersionDescription.name = _RestoreImageModel::versionKeys::majorVersionKey;
    buildVersionDescription.optional = NO;
    buildVersionDescription.attributeType = NSInteger64AttributeType;
    
    NSAttributeDescription *minorVersionDescription = [NSAttributeDescription new];
    buildVersionDescription.name = _RestoreImageModel::versionKeys::minorVersionKey;
    buildVersionDescription.optional = NO;
    buildVersionDescription.attributeType = NSInteger64AttributeType;
    
    NSAttributeDescription *patchVersionDescription = [NSAttributeDescription new];
    buildVersionDescription.name = _RestoreImageModel::versionKeys::patchVersionKey;
    buildVersionDescription.optional = NO;
    buildVersionDescription.attributeType = NSInteger64AttributeType;
    
    NSCompositeAttributeDescription *versionsDescription = [NSCompositeAttributeDescription new];
    versionsDescription.name = @"versions";
    versionsDescription.optional = NO;
    versionsDescription.elements = @[
        buildVersionDescription,
        majorVersionDescription,
        minorVersionDescription,
        patchVersionDescription
    ];
    
    [buildVersionDescription release];
    [majorVersionDescription release];
    [minorVersionDescription release];
    [patchVersionDescription release];
    
    //
    
    NSAttributeDescription *URLAttributeDescription = [NSAttributeDescription new];
    URLAttributeDescription.name = @"URL";
    URLAttributeDescription.optional = NO;
    URLAttributeDescription.attributeType = NSURIAttributeType;
    
    //
    
    entity.properties = @[versionsDescription, URLAttributeDescription];
    [versionsDescription release];
    [URLAttributeDescription release];
    
    return [entity autorelease];
}

@end
