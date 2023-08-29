//
//  RestoreImageModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import <CoreData/CoreData.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

namespace _RestoreImageModel {
namespace versionKeys {
static NSString * const buildVersionKey = @"buildVersion";
static NSString * const majorVersionKey = @"majorVersion";
static NSString * const minorVersionKey = @"minorVersion";
static NSString * const patchVersionKey = @"patchVersion";
}
}

@interface RestoreImageModel : NSManagedObject
@property (class, readonly, nonatomic) NSEntityDescription *_entity;
@property (assign) NSDictionary<NSString *, id> *versions;
@property (assign) NSURL *URL;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
