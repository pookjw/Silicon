//
//  RestoreImageModel.m
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "RestoreImageModel.hpp"
#import "BookmarkURLValueTransformer.hpp"

@implementation RestoreImageModel

@dynamic versions;
@dynamic URL;

+ (NSEntityDescription *)_entity {
    [BookmarkURLValueTransformer registerIfNeeded];
    
    //
    
    NSEntityDescription *entity = [NSEntityDescription new];
    entity.name = NSStringFromClass(self);
    entity.managedObjectClassName = NSStringFromClass(self);
    
    //
    
    NSAttributeDescription *buildVersionDescription = [NSAttributeDescription new];
    buildVersionDescription.name = _RestoreImageModel::versionKeys::buildVersionKey;
    buildVersionDescription.optional = NO;
    buildVersionDescription.attributeType = NSStringAttributeType;
    
    NSAttributeDescription *majorVersionDescription = [NSAttributeDescription new];
    majorVersionDescription.name = _RestoreImageModel::versionKeys::majorVersionKey;
    majorVersionDescription.optional = NO;
    majorVersionDescription.attributeType = NSInteger64AttributeType;
    
    NSAttributeDescription *minorVersionDescription = [NSAttributeDescription new];
    minorVersionDescription.name = _RestoreImageModel::versionKeys::minorVersionKey;
    minorVersionDescription.optional = NO;
    minorVersionDescription.attributeType = NSInteger64AttributeType;
    
    NSAttributeDescription *patchVersionDescription = [NSAttributeDescription new];
    patchVersionDescription.name = _RestoreImageModel::versionKeys::patchVersionKey;
    patchVersionDescription.optional = NO;
    patchVersionDescription.attributeType = NSInteger64AttributeType;
    
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
    URLAttributeDescription.attributeType = NSTransformableAttributeType;
    URLAttributeDescription.attributeValueClassName = NSStringFromClass(NSURL.class);
    URLAttributeDescription.valueTransformerName = NSStringFromClass(BookmarkURLValueTransformer.class);
    
    //
    
    entity.properties = @[
        versionsDescription,
        URLAttributeDescription
    ];
    
    [versionsDescription release];
    [URLAttributeDescription release];
    
    return [entity autorelease];
}

@end
