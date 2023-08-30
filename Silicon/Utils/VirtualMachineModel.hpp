//
//  VirtualMachineModel.h
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import <CoreData/CoreData.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface VirtualMachineModel : NSManagedObject
@property (assign) NSURL *bundleURL;
+ (NSEntityDescription *)_entity;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
